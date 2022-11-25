
module word_multiplexer (
  input [3:0] a, b, c, d,
  input [1:0] s,
  output reg [3:0] q
);

  always @ (*) begin
    casez(s)
      2'b00: q = a;
      2'b01: q = b;
      2'b10: q = c;
      2'b11: q = d;
      default: q = 3'b000;
    endcase;
  end

endmodule


module stack_cpu (
  input wire [7:0] io_in,
  output wire [7:0] io_out
);

  // define the inputs
  wire clk;
  wire rst;
  wire [3:0] inbits;

  // assign the inputs
  assign clk = io_in[0];
  assign rst = io_in[1];
  assign inbits = io_in[5:2];

  // output latch
  reg [7:0] out_dff;


  wire [3:0] v0, v1;
  reg move_flag, dir_flag, swap_flag;

  wire [3:0] stack_input;
  stack_register stack(
    .clk(clk),
    .rst(rst),
    .mode(dir_flag), // 1 push, 0 pop
    .move(move_flag),
    .swap(swap_flag),
    .in_word(stack_input),
    .top_word(v0),
    .second_word(v1)
  );

  // stack input selection
  reg [1:0] input_select;
  word_multiplexer stack_input_select(
    .a(inbits),
    .b(v0),
    .c(v1),
    .d({ 1'b0, 1'b0, 1'b0, 1'b0 }), // status register
    .s(input_select),
    .q(stack_input)
  );

  // processor state
  reg [3:0] current_op; // current opcode
  reg [2:0] op_counter; // cycle # of operation
  reg fetch_flag;       // waiting for operation

  always @ (posedge clk) begin
    if (rst == 1) begin
      // reset processor state
      out_dff <= 0;
      fetch_flag <= 1;
      current_op <= 0;
      op_counter <= 0;
      move_flag <= 0;
      dir_flag <= 0;
      swap_flag <= 0;
      input_select <= 0;
    end
    else if (fetch_flag == 1) begin
      // spend one cycle to fetch the next op
      // and latch it in
      current_op <= inbits;
      op_counter <= 0;
      fetch_flag <= 0;
    end
    else begin
      op_counter <= op_counter + 1;

      // decode op
      if (current_op == 4'h1) begin
        // PUSH

        if (op_counter == 0) begin
          input_select <= 0;
          move_flag <= 1;
          dir_flag <= 1;
        end
        else begin
          move_flag <= 0;
          fetch_flag <= 1; // complete
        end
        
      end
      else if (current_op == 4'h2) begin
        // POP

        if (op_counter == 0) begin
          move_flag <= 1;
          dir_flag <= 0;
        end
        else begin
          move_flag <= 0;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h3) begin
        // OUTL
        out_dff <= { out_dff[7:4], v0 };
        fetch_flag <= 1; // complete

      end
      else if (current_op == 4'h4) begin
        // OUTH
        out_dff <= { v0, out_dff[3:0] };
        fetch_flag <= 1; // complete

      end
      else if (current_op == 4'h5) begin
        // SWAP

        if (op_counter == 0) begin
          swap_flag <= 1;
        end
        else begin
          swap_flag <= 0;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h6) begin
        // PEEK

        if (op_counter == 0) begin
          input_select <= 2;
          move_flag <= 1;
          dir_flag <= 1;
        end
        else begin
          move_flag <= 0;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h7) begin
        // DUP

        if (op_counter == 0) begin
          input_select <= 1;
          move_flag <= 1;
          dir_flag <= 1;
        end
        else begin
          move_flag <= 0;
          fetch_flag <= 1; // complete
        end

      end
      else begin
        // all unknown instructions are NOOP
        // NOOP

        fetch_flag <= 1; // complete
      end

    end
  end

  assign io_out = out_dff;

endmodule

// ADD ADDC
// SUB SUBC
// AND
// OR
// XOR

// SHR
// SHL
// ROL
// ROR

// NOT
// INC
// DEC


// CMP
// EX extended opcodes
