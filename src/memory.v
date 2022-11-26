`ifndef CONSTANTS
  `define CONSTANTS
  `include "constants.v"
`endif

module memory (
  input clk,
  input [1:0] mode,
  input [`MEMORY_ADDR_BITS-1:0] address,
  input [3:0] data_in,
  output reg [3:0] data_out);

  generate
    genvar i;
    for(i = 0; i < 2**`MEMORY_ADDR_BITS; i = i + 1) begin
      reg [3:0] memory_cell;

      always @ (posedge clk) begin
        if (address == i) begin
          case(mode)
            `MEMORY_MODE_NONE:  data_out <= data_out;
            `MEMORY_MODE_READ:  data_out <= memory_cell;
            `MEMORY_MODE_WRITE: memory_cell <= data_in;
            `MEMORY_MODE_CLEAR: data_out <= 0;
            default: data_out <= data_out;
          endcase;
        end
      end
    end
  endgenerate
endmodule
