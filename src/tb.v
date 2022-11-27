`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
  // testbench is controlled by test.py
  input globclk,
  input clk,
  input rst,
  input [31:0] testnumber,
  input [31:0] select,
  input [3:0] io_ins,
  input mode,
  output [7:0] io_outs,
  output [3:0] io_outs2
   );

  // this part dumps the trace to a vcd file that can be viewed with GTKWave
  initial begin
    $dumpfile ("tb.vcd");
    $dumpvars (0, tb);
    #1;
  end

  // wire up the inputs and outputs
  wire [7:0] inputs = {1'b0, 1'b0, io_ins, rst, clk};
  wire [7:0] outputs;

  // dut 0x1 is cpu
  davidsiaw_stackcalc dut1(
    .io_in  (inputs),
    .io_out (outputs)
  );

  assign io_outs = outputs;

endmodule
