`ifndef CONSTANTS
  `define CONSTANTS
  `include "constants.v"
`endif

module memory_cell(
  input rst,
  input write,
  input [3:0] data_in,
  output reg [3:0] data_out
);
  reg [3:0] memory_cell;

  always @ (*) begin
    if (rst) begin
      memory_cell = 0;
    end
    else if (write) begin
      memory_cell = data_in;
    end
    else begin
      data_out = memory_cell;
    end
  end
endmodule

module memory (
  input clk,
  input [1:0] mode,
  input [`MEMORY_ADDR_BITS-1:0] address,
  input [3:0] data_in,
  output reg [3:0] data_out);

  generate
  	genvar i;
  	for(i = 0; i < 2**`MEMORY_ADDR_BITS; i = i + 1) begin

      reg [3:0] cell_in;
      wire [3:0] cell_out;
      reg rst;
      reg write;

      memory_cell celll(
        .rst(rst),
        .write(write),
        .data_in(cell_in),
        .data_out(cell_out)
      );

      always @ (*) begin
        rst = mode == `MEMORY_MODE_CLEAR;
        if (address == i) begin
          write = mode == `MEMORY_MODE_WRITE;
          cell_in = data_in;
          if (!write) begin
            data_out = cell_out;
          end
        end
        else begin
          write = 0;
          cell_in = cell_out;
        end
      end

  	end
  endgenerate

  always @ (posedge clk) begin
	  case(mode)
  		`MEMORY_MODE_NONE:  data_out <= data_out;
  		`MEMORY_MODE_CLEAR: data_out <= 0;
  		default: data_out <= data_out;
	  endcase;
  end
endmodule
