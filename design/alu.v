// ALU Selection modes
// I've encoded these to have the lower 3 bits be the funct3 bits for less circuitry
`define ALU_SEL_ADD           4'b0000 // 000 is funct3
`define ALU_SEL_SUB           4'b1000 // 000 is funct3 and 1 is pulled from the upper bit
`define ALU_SEL_AND           4'b0111 // 111 is funct3
`define ALU_SEL_OR            4'b0110 // 110 is funct3
`define ALU_SEL_XOR           4'b0100 // 100 is funct3
`define ALU_SEL_SLT           4'b0010 // 010 is funct3 for SLT
`define ALU_SEL_SLTU          4'b0011 // 011 is funct3 for SLTU
`define ALU_SEL_SHIFT_LEFT    4'b0001 // SLL, 001 is funct3
`define ALU_SEL_SHIFT_RIGHT   4'b0101 // SRL, 101 is funct3
`define ALU_SEL_SHIFT_RIGHT_A 4'b1101 // SRA, 101 is funct3, MSB is 1 from the upper bit
`define ALU_SEL_B_ASSIGN      4'b1111 // Pass through the B input to the output (used for lui)

module alu (
    input [3:0] alu_select,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] out
);

always @(*) begin
    case (alu_select)
        `ALU_SEL_ADD: out = A + B;
        `ALU_SEL_SUB: out = A - B;
        `ALU_SEL_AND: out = A & B;
        `ALU_SEL_OR:  out = A | B;
        `ALU_SEL_XOR: out = A ^ B;
        `ALU_SEL_SLT: out = {31'b0, $signed(A) < $signed(B)};
        `ALU_SEL_SLTU: out = {31'b0, A < B};
        `ALU_SEL_SHIFT_LEFT: out = A << B[4:0];
        `ALU_SEL_SHIFT_RIGHT: out = A >> B[4:0];
        `ALU_SEL_SHIFT_RIGHT_A: out = $signed(A) >>> B[4:0];
        `ALU_SEL_B_ASSIGN: out = B;
        default: out = 32'b0;
    endcase
end

endmodule