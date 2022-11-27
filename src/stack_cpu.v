`ifndef CONSTANTS
  `define CONSTANTS
  `include "constants.v"
`endif

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

  // read-only pseudoregister
  wire [3:0]status_register;
  assign status_register = { 1'b0, 1'b0, error_flag, carry_flag };

  // see constants.v SELECT_*
  input_selector stack_input_select(
    .a(inbits),
    .b(v0),
    .c(v1),
    .d(result_register[3:0]),
    .e(user_selected_input),
    .f(user_selected_input2),
    .g(user_selected_input3),
    .h(ram_out),

    .s(input_select),
    .q(stack_input)
  );

  // for PUSF
  input_selector userinput_select1(
    .a(v0),               // dupl
    .b(v1),               // peek
    .c(status_register),  // flag
    .d(4'h0),
    .e(4'h0),
    .f(4'h0),
    .g(4'h0),
    .h(4'h0),

    .s(inbits[2:0]),
    .q(user_selected_input)
  );

  // for REPL
  input_selector userinput_select2(
    .a(~v0),                          // not
    .b(-v0),                          // neg
    .c(v0+4'h1),                      // incr
    .d(v0-4'h1),                      // decr
    .e(v0>>4'h1),                     // shr1
    .f(v0<<4'h1),                     // shl1
    .g({v0[0], v0[3:1]}),             // ror1
    .h({v0[2:0], v0[3]}),             // rol1

    .s(inbits[2:0]),
    .q(user_selected_input2)
  );

  wire [4:0]integer_sum;
  wire [4:0]integer_sum_c;

  wire [7:0]mul_result;
  wire [2:0]mod_result;

  assign integer_sum = v0 + v1;
  assign integer_sum_c = v0 + v1 + carry_flag;

  assign mul_result = v0 * v1;
  assign mod_result = v0 == 0 ? 0 : v1 % v0;

  // for BINA
  input_selector userinput_select3(
    .a(integer_sum[3:0]),
    .b(v0 & v1),
    .c(v0 | v1),
    .d(v0 ^ v1),
    .e(integer_sum_c[3:0]),   // addc
    .f(mul_result[3:0]),      // mull
    .g(mul_result[7:4]),      // mulh
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
  reg error_flag;             // error flag
  reg carry_flag;             // carry flag

  // RAM
  reg [1:0]ram_mode;
  reg [`MEMORY_ADDR_BITS-1:0]ram_addr;
  wire [3:0]ram_out;

  memory ram(
    .clk(clk),
    .mode(ram_mode),
    .address(ram_addr),
    .data_in(v1),
    .data_out(ram_out)
  );

  always @ (posedge clk) begin
    if (rst == 1) begin
      // reset processor state
      out_dff <= 0;
      fetch_flag <= 1;
      current_op <= 0;
      op_counter <= 0;
      stack_mode <= `STACK_MODE_RESET;
      input_select <= `SELECT_INPUT_BITS;
      error_flag <= 0;
      carry_flag <= 0;
      result_register <= 0;
      ram_mode <= `MEMORY_MODE_CLEAR;
      ram_addr <= 0;
    end
    else if (fetch_flag == 1) begin
      // spend one cycle to fetch the next op
      // and latch it in
      stack_mode <= `STACK_MODE_IDLE;
      current_op <= inbits;
      op_counter <= 0;
      fetch_flag <= 0;
      ram_mode <= `MEMORY_MODE_NONE;
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
        // BINA
        // binary operations

        if (op_counter == 0) begin
          input_select <= `SELECT_USERINPUT3;
          stack_mode <= `STACK_MODE_ROLL2;
        end
        else begin

          if (inbits == 0) begin
            // ADD
            carry_flag <= integer_sum[4];
          end
          if (inbits == 4) begin
            // ADDC
            carry_flag <= integer_sum_c[4];
          end

          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'h9) begin
        // MULT

        if (op_counter == 0) begin
          // first cycle, compute and move the low to the stack
          input_select <= `SELECT_RESULT_LOW;
          stack_mode <= `STACK_MODE_ROLL2;
          result_register <= v0 * v1;
        end
        else if (op_counter == 1) begin
          // second cycle, move the high to the stack
          result_register <= { 4'b0000, result_register[7:4] };
          stack_mode <= `STACK_MODE_PUSH;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'ha) begin
        // IDIV

        if (op_counter == 0) begin
          // first cycle, compute and move the high to the stack
          input_select <= `SELECT_RESULT_LOW;
          stack_mode <= `STACK_MODE_ROLL2;

          if (v0 == 0) begin
            // set the error flag on divide by zero
            error_flag <= 1;
            result_register <= 0; // refuse to perform
          end
          else begin
            result_register <= { v1 % v0, v1 / v0 };
          end

        end
        else if (op_counter == 1) begin
          // second cycle, move the mod to the stack
          result_register <= { 4'b0000, result_register[7:4] };
          stack_mode <= `STACK_MODE_PUSH;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end

      end
      else if (current_op == 4'hb) begin
        // CLFL
        // clear flags

        error_flag <= 0;
        carry_flag <= 0;
        fetch_flag <= 1; // complete
      end
      else if (current_op == 4'hc) begin
        // SAVE

        if (op_counter == 0) begin
          ram_addr <= v0;
          ram_mode <= `MEMORY_MODE_WRITE;
          stack_mode <= `STACK_MODE_POP;
        end
        else if (op_counter == 1) begin
          ram_mode <= `MEMORY_MODE_NONE;
          stack_mode <= `STACK_MODE_ROLL;
          input_select <= `STACK_MODE_POP;
        end
        else begin
          stack_mode <= `STACK_MODE_IDLE;
          fetch_flag <= 1; // complete
        end
      end
      else if (current_op == 4'hd) begin
        // LOAD

        if (op_counter == 0) begin
          ram_addr <= v0;
          ram_mode <= `MEMORY_MODE_READ;
        end
        else if (op_counter == 1) begin
          ram_mode <= `MEMORY_MODE_NONE;
          stack_mode <= `STACK_MODE_PUSH;
          input_select <= `SELECT_MEMORY_OUT;
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
