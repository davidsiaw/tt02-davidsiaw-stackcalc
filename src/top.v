
`default_nettype none

`define STACK_SIZE 8

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

  reg [`STACK_SIZE * 4 - 1:0] stack;

  wire delayedclk;

  sky130_fd_sc_hd__clkdlybuf4s15_1 delay1 (.A( clk ),     .X( delayedclk ));

  always @ (posedge delayedclk) begin
    // The reset circuit
    if(rst == 1) begin
      pushflag <= 0;
      stack <= 0;
    end

    else begin

      // accept operation
      if(pushflag == 1) begin

        stack[31:28] <= stack[27:24];
        stack[27:24] <= stack[23:20];
        stack[23:20] <= stack[19:16];
        stack[19:16] <= stack[15:12];
        stack[15:12] <= stack[11:8];
        stack[11:8]  <= stack[7:4];
        stack[7:4]   <= stack[3:0];

        stack[3:0] <= inbits;
        pushflag = 0;
      end
      else begin
        if(inbits == 4'b0001) begin
          pushflag = 1;
        end
      end

    end

  end

  assign io_out = { 4'b0000, stack[3:0] };


endmodule
