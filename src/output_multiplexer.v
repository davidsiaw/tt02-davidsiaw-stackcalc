module output_multiplexer (
  input wire [7:0] a, b, c, d,
  input wire [1:0] output_mode,
  output reg [7:0] q
);
  always @ (*) begin
    case (output_mode)
      2'b00: q = a;
      2'b01: q = b;
      2'b10: q = c;
      2'b11: q = d;
      default: q = 8'h00;
    endcase;
  end
endmodule
