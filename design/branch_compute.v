`define FUNCT3_BEQ 3'b000
`define FUNCT3_BNE 3'b001
`define FUNCT3_BLT 3'b100
`define FUNCT3_BGE 3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111

module branch_compute(
  input [6:0] opcode,
  input [2:0] branch_type,
  input [31:0] rs1,
  input [31:0] rs2,
  input x_jump,
  output reg branch_taken,
  output reg x_pc_select
);

always @(*) begin
  if (opcode == 7'b1100011) begin
    case (branch_type)
        `FUNCT3_BEQ:  branch_taken = (rs1 == rs2);
        `FUNCT3_BNE:  branch_taken = !(rs1 == rs2);
        `FUNCT3_BLT:  branch_taken = ($signed(rs1) < $signed(rs2));
        `FUNCT3_BGE:  branch_taken = !($signed(rs1) < $signed(rs2));
        `FUNCT3_BLTU: branch_taken = (rs1 < rs2);
        `FUNCT3_BGEU: branch_taken = !(rs1 < rs2);
        default: branch_taken = 1'b0;
    endcase
  end else begin
    branch_taken = 1'b0;
  end

  x_pc_select = x_jump | branch_taken;
end

endmodule
