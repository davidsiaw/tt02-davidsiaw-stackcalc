`default_nettype none
`timescale 1ns/1ps

module sky130_fd_sc_hd__clkdlybuf4s15_1(input A, output reg X);
  always @ (*) begin
    #100;
    X = A;
  end
endmodule

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input globclk,
    input clk,
    input rst,
    input [3:0] io_ins,

    output [3:0] io_outs
   );

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {clk, rst, 1'b0, 1'b0, io_ins};
    wire [7:0] outputs;
    assign io_outs = outputs[3:0];

    // instantiate the DUT
    davidsiaw_stackcalc dut(
        .io_in  (inputs),
        .io_out (outputs)
        );

endmodule
