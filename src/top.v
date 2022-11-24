
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


  wire delayedclk;
  wire delayedclk2;

  wire [7:0]w0;
  wire [7:0]w1;
  wire [7:0]w2;
  wire [7:0]w3;

  sky130_fd_sc_hd__clkdlybuf4s15_1 delay1 (.A( clk ),        .X( delayedclk ));
  sky130_fd_sc_hd__clkdlybuf4s15_1 delay2 (.A( delayedclk ), .X( delayedclk2 ));

  reg shiftflag;
  reg shiftdir;

  always @ (posedge clk) begin
    // The reset circuit
    if(rst == 1) begin
      shiftflag <= 0;
      shiftdir <= 0;
    end

    else begin
      if(shiftflag != 1) begin
        // pop
        if(inbits == 4'b0010) begin
          shiftflag = 1;
          shiftdir = 1;
        end
      end

    end

  end

  shiftreg #(.SIZE(`STACK_SIZE)) a0(.d(inbits[0]), .clk(delayedclk), .en(shiftflag), .dir(shiftdir), .rst(rst), .q(w0));
  shiftreg #(.SIZE(`STACK_SIZE)) a1(.d(inbits[1]), .clk(delayedclk), .en(shiftflag), .dir(shiftdir), .rst(rst), .q(w1));
  shiftreg #(.SIZE(`STACK_SIZE)) a2(.d(inbits[2]), .clk(delayedclk), .en(shiftflag), .dir(shiftdir), .rst(rst), .q(w2));
  shiftreg #(.SIZE(`STACK_SIZE)) a3(.d(inbits[3]), .clk(delayedclk), .en(shiftflag), .dir(shiftdir), .rst(rst), .q(w3));

  always @ (negedge delayedclk2) begin
    // The reset circuit
    if(rst == 1) begin
      shiftflag <= 0;
    end

    else begin
      // accept operation
      if(shiftflag == 1) begin
        // reset previous shiftflag
        shiftflag = 0;
      end
      else begin
        if(inbits == 4'b0001) begin
          shiftflag = 1;
          shiftdir = 0;
        end
      end

    end

  end

  assign io_out = { 4'b0000, w3[0], w2[0], w1[0], w0[0] };
endmodule
