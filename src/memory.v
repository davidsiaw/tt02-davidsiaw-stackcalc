`ifndef CONSTANTS
  `define CONSTANTS
  `include "constants.v"
`endif

module memory (
  input clk,
  input [1:0] mode,
  input [`MEMORY_ADDR_BITS-1:0] address,
  input [3:0] data_in,
  output reg [3:0] data_out
);
  
  reg [3:0] memory_cell0;
  reg [3:0] memory_cell1;
  reg [3:0] memory_cell2;
  reg [3:0] memory_cell3;
  reg [3:0] memory_cell4;
  reg [3:0] memory_cell5;
  reg [3:0] memory_cell6;
  reg [3:0] memory_cell7;

  always @ (posedge clk) begin
    if (mode == `MEMORY_MODE_CLEAR) begin
      memory_cell0 <= 0;
      memory_cell1 <= 0;
      memory_cell2 <= 0;
      memory_cell3 <= 0;
      memory_cell4 <= 0;
      memory_cell5 <= 0;
      memory_cell6 <= 0;
      memory_cell7 <= 0;
      data_out <= 0;
    end
    else if (mode == `MEMORY_MODE_READ) begin
      case(address)
        3'b000: data_out <= memory_cell0;
        3'b001: data_out <= memory_cell1;
        3'b010: data_out <= memory_cell2;
        3'b011: data_out <= memory_cell3;
        3'b100: data_out <= memory_cell4;
        3'b101: data_out <= memory_cell5;
        3'b110: data_out <= memory_cell6;
        3'b111: data_out <= memory_cell7;
      endcase;
    end
    else if (mode == `MEMORY_MODE_WRITE) begin
      case(address)
        3'b000: memory_cell0 <= data_in;
        3'b001: memory_cell1 <= data_in;
        3'b010: memory_cell2 <= data_in;
        3'b011: memory_cell3 <= data_in;
        3'b100: memory_cell4 <= data_in;
        3'b101: memory_cell5 <= data_in;
        3'b110: memory_cell6 <= data_in;
        3'b111: memory_cell7 <= data_in;
      endcase;
    end
    else begin
      data_out <= data_out;
    end
  end

endmodule
