`define STACK_SIZE 8

module stack_register (
  input wire [3:0] in_word,
  input wire clk,
  input [2:0] mode,
  output wire [3:0] top_word,
  output wire [3:0] second_word
);
  
  wire [`STACK_SIZE-1:0] w0, w1, w2, w3;

  shift_register #(.SIZE(`STACK_SIZE)) a0(.d(in_word[0]), .clk(clk), .mode(mode), .q(w0));
  shift_register #(.SIZE(`STACK_SIZE)) a1(.d(in_word[1]), .clk(clk), .mode(mode), .q(w1));
  shift_register #(.SIZE(`STACK_SIZE)) a2(.d(in_word[2]), .clk(clk), .mode(mode), .q(w2));
  shift_register #(.SIZE(`STACK_SIZE)) a3(.d(in_word[3]), .clk(clk), .mode(mode), .q(w3));

  assign top_word    = { w3[0], w2[0], w1[0], w0[0] };
  assign second_word = { w3[1], w2[1], w1[1], w0[1] };

endmodule
