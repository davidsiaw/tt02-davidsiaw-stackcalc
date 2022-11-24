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
    input [31:0] select,
    input [3:0] io_ins,
    input mode,
    output [3:0] io_outs,
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

    // instantiate the DUT
    stackcpu dut1(
        .io_in  (inputs),
        .io_out (outputs)
    );

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

    assign io_outs = {4{select[0]}} & outputs[3:0] |
                     {4{select[1]}} & regout1;

endmodule
