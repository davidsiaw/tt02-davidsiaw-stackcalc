`ifndef CONSTANTS
  `define CONSTANTS
  `include "constants.v"
`endif  

module input_selector (
  input [3:0] a,
              b,
              c,
              d,
              e,
              f,
              g,
              h,
  input [2:0] s,
  output reg [3:0] q
);

  always @ (*) begin
    casez(s)
      3'b000: q = a;
      3'b001: q = b;
      3'b010: q = c;
      3'b011: q = d;
      3'b100: q = e;
      3'b101: q = f;
      3'b110: q = g;
      3'b111: q = h;
      default: q = 4'h0;
    endcase;
  end
endmodule

module output_multiplexer (
  input [7:0] a, b, c, d,
  input [1:0] output_mode,
  output reg [7:0] q
);
  always @ (*) begin
    casez(output_mode)
      2'b00: q = a;
      2'b01: q = b;
      2'b10: q = c;
      2'b11: q = d;
      default: q = 8'h00;
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
  wire [1:0] output_mode;

  // assign the inputs
  assign clk = io_in[0];
  assign rst = io_in[1];
  assign inbits = io_in[5:2];
  assign output_mode = io_in[7:6];

  // output latch
  reg [7:0] out_dff;

  wire [3:0] v0, v1;
  reg [2:0] stack_mode;

  wire [3:0] stack_input;
  stack_register stack(
    .in_word(stack_input),
    .clk(clk),
    .mode(stack_mode),
    .top_word(v0),
    .second_word(v1)
  );

  // stack input selection
  reg [2:0] input_select;
  wire [3:0] user_selected_input;
  wire [3:0] user_selected_input2;
  wire [3:0] user_selected_input3;
  input_selector stack_input_select(
    .a(inbits),
    .b(v0),
    .c(v1),
    .d(result_register[3:0]),
    .e(user_selected_input),
    .f(user_selected_input2),
    .g(user_selected_input3),
    .h(result_register[7:4]),
    .s(input_select),
    .q(stack_input)
  );

  input_selector userinput_select1(
    .a(v0),
    .b(v1),
    .c(4'h0),
    .d(4'h0),
    .e(4'h0),
    .f(4'h0),
    .g(4'h0),
    .h(4'h0),
    .s(inbits[2:0]),
    .q(user_selected_input)
  );

  input_selector userinput_select2(
    .a(~v0),
    .b(4'h0),
    .c(4'h0),
    .d(4'h0),
    .e(4'h0),
    .f(4'h0),
    .g(4'h0),
    .h(4'h0),
    .s(inbits[2:0]),
    .q(user_selected_input2)
  );

  input_selector userinput_select3(
    .a(v0 + v1),
    .b(v0 & v1),
    .c(v0 | v1),
    .d(v0 ^ v1),
    .e(4'h0),
    .f(4'h0),
    .g(4'h0),
    .h(4'h0),
    .s(inbits[2:0]),
    .q(user_selected_input3)
  );

  // processor state
  reg [3:0] current_op; // current opcode
  reg [2:0] op_counter; // cycle # of operation
  reg fetch_flag;       // waiting for operation

  // calculation registers
  reg [7:0] result_register;  // for results 8 bits wide

  always @ (posedge clk) begin
    if (rst == 1) begin
      // reset processor state
      out_dff <= 0;
      fetch_flag <= 1;
      current_op <= 0;
      op_counter <= 0;
      stack_mode <= `STACK_MODE_RESET;
      input_select <= `SELECT_INPUT_BITS;
    end
    else if (fetch_flag == 1) begin
      // spend one cycle to fetch the next op
      // and latch it in
      stack_mode <= `STACK_MODE_IDLE;
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
          input_select <= `SELECT_INPUT_BITS;
          stack_mode <= `STACK_MODE_PUSH;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end
        
      end
      else if (current_op == 4'h2) begin
        // POP

        if (op_counter == 0) begin
          stack_mode <= `STACK_MODE_POP;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
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
          stack_mode <= `STACK_MODE_SWAP;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h6) begin
        // PUSF

        if (op_counter == 0) begin
          input_select <= `SELECT_USERINPUT1;
          stack_mode <= `STACK_MODE_PUSH;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h7) begin
        // REPL

        if (op_counter == 0) begin
          input_select <= `SELECT_USERINPUT2;
          stack_mode <= `STACK_MODE_ROLL;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h8) begin
        // BIN

        if (op_counter == 0) begin
          input_select <= `SELECT_USERINPUT3;
          stack_mode <= `STACK_MODE_ROLL2;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h9) begin
        // MUL

        if (op_counter == 0) begin
          // first cycle, compute and move the high to the stack
          input_select <= `SELECT_RESULTHIGH;
          stack_mode <= `STACK_MODE_ROLL2;
          result_register <= v0 * v1;
        end
        else if (op_counter == 1) begin
          // second cycle, move the low to the stack
          input_select <= `SELECT_RESULT_LOW;
          stack_mode <= `STACK_MODE_PUSH;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
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

  wire [6:0]sevenseg;

  decoder seven_seg_decoder(
    .binary(v0),
    .segments(sevenseg)
  );

  output_multiplexer outputter(
    .a(out_dff),
    .b({ 1'b0, sevenseg }),
    .c(8'hff),
    .d(8'hff),
    .output_mode(output_mode),
    .q(io_out)
  );

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
