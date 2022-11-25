

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
  reg move_flag, dir_flag;
  stack_register stack(
    .clk(clk),
    .rst(rst),
    .mode(dir_flag), // 1 push, 0 pop
    .move(move_flag),
    .in_word(inbits),
    .top_word(v0),
    .second_word(v1)
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
    end
    else if (fetch_flag == 1) begin
      // fetch the next op
      current_op <= inbits;
      op_counter <= 0;
      fetch_flag <= 0;
    end
    else begin
      op_counter <= op_counter + 1;

      // decode op
      if (current_op == 4'h01) begin
        // PUSH

        if (op_counter == 0) begin
          move_flag <= 1;
          dir_flag <= 1;
        end
        else begin
          move_flag <= 0;
          fetch_flag <= 1; // complete
        end
        
      end
      else if (current_op == 4'h02) begin
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
      else if (current_op == 4'h03) begin
        // OUT
        out_dff <= v0;
        fetch_flag <= 1; // complete
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
