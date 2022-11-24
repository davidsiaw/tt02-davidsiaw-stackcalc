module shiftreg #(parameter SIZE=8) (
  input d,
  input clk,
  input en,
  input dir,
  input rst,
  output reg [SIZE-1:0] q);

   always @ (posedge clk) begin
      if (rst)
        q = 0;
      else begin
        if (en)
          case (dir)
            1'b0: q = { q[SIZE-2:0], d };
            1'b1: q = { 1'b0, q[SIZE-1:1] };
          endcase
        else
          q <= q;
      end
    end
endmodule
