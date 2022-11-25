
module shift_register #(parameter SIZE=8) (
  input d,
  input clk,
  input en,
  input dir,
  input rst,
  input swp,
  output reg [SIZE-1:0] q);

   always @ (posedge clk) begin
      if (rst) begin
        q <= 0;
      end
      else if (swp) begin
        q <= { q[SIZE-1:2], q[0], q[1] };
      end
      else begin
        if (en) begin
          case (dir)
            1'b1: q <= { q[SIZE-2:0], d };
            1'b0: q <= { 1'b0, q[SIZE-1:1] };
          endcase
        end
        else begin
          q <= q;
        end
      end
    end
endmodule
