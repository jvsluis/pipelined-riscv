`define R_TYPE 3'b000
`define I_TYPE 3'b001
`define S_TYPE 3'b010
`define B_TYPE 3'b011
`define U_TYPE 3'b100
`define J_TYPE 3'b101

module immediate_gen (
    input [31:0] instruction,
    input [2:0] type,
    output reg [31:0] imm
);

always @(*) begin
    case (type)
        `R_TYPE: imm = 32'b0;
        `I_TYPE: imm = {{20{instruction[31]}}, instruction[31:20]};
        `S_TYPE: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        `B_TYPE: imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        `U_TYPE: imm = {instruction[31:12], 12'b0};
        `J_TYPE: imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        default: imm = 32'b0;
    endcase
end

endmodule