
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

  wire delayedclk;
  wire delayedclk2;

  wire [7:0]w0;
  wire [7:0]w1;
  wire [7:0]w2;
  wire [7:0]w3;

  sky130_fd_sc_hd__clkdlybuf4s15_1 delay1 (.A( clk ),        .X( delayedclk ));
  sky130_fd_sc_hd__clkdlybuf4s15_1 delay2 (.A( delayedclk ), .X( delayedclk2 ));

  wire shiftdir;
  assign shiftdir = 1'b0;

  shiftreg a0(.d(inbits[0]), .clk(delayedclk), .en(pushflag), .dir(shiftdir), .rst(rst), .q(w0));
  shiftreg a1(.d(inbits[1]), .clk(delayedclk), .en(pushflag), .dir(shiftdir), .rst(rst), .q(w1));
  shiftreg a2(.d(inbits[2]), .clk(delayedclk), .en(pushflag), .dir(shiftdir), .rst(rst), .q(w2));
  shiftreg a3(.d(inbits[3]), .clk(delayedclk), .en(pushflag), .dir(shiftdir), .rst(rst), .q(w3));

  always @ (negedge delayedclk2) begin
    // The reset circuit
    if(rst == 1) begin
      pushflag <= 0;
    end

    else begin
      // accept operation
      if(pushflag == 1) begin
        pushflag = 0;
      end
      else begin
        if(inbits == 4'b0001) begin
          pushflag = 1;
        end
      end

    end

  end

  assign io_out = { 4'b0000, w3[0], w2[0], w1[0], w0[0] };
endmodule
