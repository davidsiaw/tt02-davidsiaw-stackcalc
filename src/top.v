
`default_nettype none

module stack_register (
  input wire clk,
  input wire rst,
  input wire mode, // 1 push, 0 pop
  input wire [3:0] in_word,
  output wire [3:0] top_word,
  output wire [3:0] second_word
);

  reg [4:0] word0;
  reg [4:0] word1;
  reg [4:0] word2;
  reg [4:0] word3;

  always @ (posedge clk) begin
    if (rst == 1'b1) begin
      word0 = 0;
      word1 = 0;
      word2 = 0;
      word3 = 0;
    end
    else begin
    
    end
  end

  assign top_word = word0[3:0];
  assign second_word = word1[3:0];

endmodule

module davidsiaw_stackcalc (
  input wire [7:0] io_in,
  output wire [7:0] io_out
);
  stackcpu cpu(.io_in(io_in), .io_out(io_out));
endmodule
