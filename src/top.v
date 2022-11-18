
`default_nettype none

module davidsiaw_stackcalc (
  input wire [7:0] io_in,
  output wire [7:0] io_out
);
  wire clk;
  wire rst;
  wire [3:0] inbits;

  assign clk = io_in[7];
  assign rst = io_in[6];

  assign inbits = io_in[3:0];

  reg pushflag;
  reg [3:0] stacktop;

  wire delayin;
  wire delayout;


  sky130_fd_sc_hd__clkdlybuf4s15_1 delay1 (.A( clk ),     .X( delayin ));
  sky130_fd_sc_hd__clkdlybuf4s15_1 delay2 (.A( delayin ), .X( delayout ));

  always @ (posedge delayout) begin
    // The reset circuit
    if(rst == 1) begin
      pushflag <= 0;
      stacktop <= 0;
    end
    else begin

      // accept operation
      if(pushflag == 0) begin
        if(inbits == 4'b0001) begin
          pushflag = 1;
        end
      end
      else begin
        stacktop = inbits;
        pushflag = 0;
      end

    end

  end

  assign io_out = { 4'b0000, stacktop };


endmodule
