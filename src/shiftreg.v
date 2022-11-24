
module shiftreg #(parameter SIZE=8) (
  input d,
  input clk,
  input en,
  input dir,
  input rst,
  output reg [SIZE-1:0] q);

   always @ (posedge clk) begin
      if (rst) begin
        q <= 0;
      end
      else begin
        if (en) begin
          case (dir)
            1'b0: q <= { q[SIZE-2:0], d };
            1'b1: q <= { d, q[SIZE-1:1] };
          endcase
        end
        else begin
          q <= q;
        end
      end
    end
endmodule
