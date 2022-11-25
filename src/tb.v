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
  stack_cpu dut1(
    .io_in  (inputs),
    .io_out (outputs)
  );

  // dut 0x2 is stack register alone
  wire [3:0]regout1;
  wire [3:0]regout2;
  stack_register dut2(
    .clk(clk),
    .rst(rst),
    .mode(mode), // 1 push, 0 pop
    .in_word(io_ins),
    .top_word(regout1),
    .second_word(regout2)
  );


  assign io_outs = {8{select[0]}} & outputs |
           {4{select[1]}} & regout1;

endmodule
