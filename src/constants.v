`define STACK_SIZE 16

`define STACK_MODE_IDLE  3'b000
`define STACK_MODE_PUSH  3'b001
`define STACK_MODE_POP   3'b010
`define STACK_MODE_SWAP  3'b011
`define STACK_MODE_ROLL2 3'b100
`define STACK_MODE_ROLL  3'b101
`define STACK_MODE_RESET 3'b111

`define SELECT_INPUT_BITS 4'b0000
`define SELECT_STACK_TOP0 4'b0001
`define SELECT_STACK_TOP1 4'b0010
`define SELECT_RESULT_LOW 4'b0011
`define SELECT_USERINPUT1 4'b0100
`define SELECT_USERINPUT2 4'b0101
`define SELECT_USERINPUT3 4'b0110
`define SELECT_RESULTHIGH 4'b0111
`define SELECT_MATH_FLAGS 4'b1000