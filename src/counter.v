`default_nettype none

module seven_segment_seconds #( parameter MAX_COUNT = 1000 ) (
  input [7:0] io_in,
  output [7:0] io_out
);
    assign io_out = io_in;

endmodule
