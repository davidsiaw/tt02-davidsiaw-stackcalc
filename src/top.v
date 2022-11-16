`default_nettype none

module davidsiaw_stackcalc #( parameter MAX_COUNT = 1000 ) (
  input [7:0] io_in,
  output reg [7:0] io_out
);
  wire clk;
  wire rst;

  assign clk = io_in[0];
  assign rst = io_in[1];

  reg [5:0] a;
  reg [10:0] counter;

  always @ (posedge clk) begin

    if (rst == 1) begin
      counter = 10'b0;
      a = 5'b0;
    end
    else begin

      if (counter == 100) begin
        counter = 0;

        if (a == 4) begin
          a = 0;
        end
        else begin
          a += 1;
        end

      end
      else begin
        counter += 1;
      end

    end

    io_out = { 2'b0, a };
  end

endmodule
