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

  reg [3:0] memory_cell8;
  reg [3:0] memory_cell9;
  reg [3:0] memory_cella;
  reg [3:0] memory_cellb;
  reg [3:0] memory_cellc;
  reg [3:0] memory_celld;
  reg [3:0] memory_celle;
  reg [3:0] memory_cellf;

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

      memory_cell8 <= 0;
      memory_cell9 <= 0;
      memory_cella <= 0;
      memory_cellb <= 0;
      memory_cellc <= 0;
      memory_celld <= 0;
      memory_celle <= 0;
      memory_cellf <= 0;
      data_out <= 0;
    end
    else if (mode == `MEMORY_MODE_READ) begin
      case(address)
        4'b0000: data_out <= memory_cell0;
        4'b0001: data_out <= memory_cell1;
        4'b0010: data_out <= memory_cell2;
        4'b0011: data_out <= memory_cell3;
        4'b0100: data_out <= memory_cell4;
        4'b0101: data_out <= memory_cell5;
        4'b0110: data_out <= memory_cell6;
        4'b0111: data_out <= memory_cell7;

        4'b1000: data_out <= memory_cell8;
        4'b1001: data_out <= memory_cell9;
        4'b1010: data_out <= memory_cella;
        4'b1011: data_out <= memory_cellb;
        4'b1100: data_out <= memory_cellc;
        4'b1101: data_out <= memory_celld;
        4'b1110: data_out <= memory_celle;
        4'b1111: data_out <= memory_cellf;
      endcase;
    end
    else if (mode == `MEMORY_MODE_WRITE) begin
      case(address)
        4'b0000: memory_cell0 <= data_in;
        4'b0001: memory_cell1 <= data_in;
        4'b0010: memory_cell2 <= data_in;
        4'b0011: memory_cell3 <= data_in;
        4'b0100: memory_cell4 <= data_in;
        4'b0101: memory_cell5 <= data_in;
        4'b0110: memory_cell6 <= data_in;
        4'b0111: memory_cell7 <= data_in;

        4'b1000: memory_cell8 <= data_in;
        4'b1001: memory_cell9 <= data_in;
        4'b1010: memory_cella <= data_in;
        4'b1011: memory_cellb <= data_in;
        4'b1100: memory_cellc <= data_in;
        4'b1101: memory_celld <= data_in;
        4'b1110: memory_celle <= data_in;
        4'b1111: memory_cellf <= data_in;
      endcase;
    end
    else begin
      data_out <= data_out;
    end
  end

endmodule
