
module input_selector (
  input [3:0] a,
              b,
              c,
              d,
              e,
              f,
              g,
              h,
  input [3:0] i,
              j,
              k,
              l,
              m,
              n,
              o,
              p,
  input [3:0] s,
  output reg [3:0] q
);

  always @ (*) begin
    casez(s)
      4'b0000: q = a;
      4'b0001: q = b;
      4'b0010: q = c;
      4'b0011: q = d;

      4'b0100: q = e;
      4'b0101: q = f;
      4'b0110: q = g;
      4'b0111: q = h;

      4'b1000: q = i;
      4'b1001: q = j;
      4'b1010: q = k;
      4'b1011: q = l;

      4'b1100: q = m;
      4'b1101: q = n;
      4'b1110: q = o;
      4'b1111: q = p;

      default: q = 4'h0;
    endcase;
  end
endmodule
