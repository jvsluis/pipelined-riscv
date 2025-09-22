module register_dx (
  input clock,  
  input reset,
  input flush,
  input stall,

  // input
  input [31:0] d_pc,
  input [31:0] d_instruction,
  input d_memory_rw,
  input d_reg_write_enabled,
  input [1:0] d_writeback_select,
  input [4:0] d_rd,
  input [4:0] d_rs1,
  input [4:0] d_rs2,
  input [3:0] d_alu_select,
  input d_alu_mux_select_a,
  input d_alu_mux_select_b,
  input [2:0] d_instruction_type,
  input [6:0] d_opcode,
  input [2:0] d_funct3,
  input [31:0] d_data_rs1,
  input [31:0] d_data_rs2,
  input [31:0] d_imm,
  input d_jump,
  input d_comb_flush,
  input d_comb_stall,

  // output
  output reg [31:0] x_pc,
  output reg [31:0] x_instruction,
  output reg x_memory_rw,
  output reg x_reg_write_enabled,
  output reg [1:0] x_writeback_select,
  output reg [4:0] x_rd,
  output reg [4:0] x_rs1,
  output reg [4:0] x_rs2,
  output reg [3:0] x_alu_select,
  output reg x_alu_mux_select_a,
  output reg x_alu_mux_select_b,
  output reg [2:0] x_instruction_type,
  output reg [6:0] x_opcode,
  output reg [2:0] x_funct3,
  output reg [31:0] x_data_rs1,
  output reg [31:0] x_data_rs2,
  output reg [31:0] x_imm,
  output reg x_jump
);

always @(posedge clock, posedge reset) begin
  if (reset) begin
      x_pc <= 0;
      x_instruction <= 0;
      x_memory_rw <= 0;
      x_reg_write_enabled <= 0;
      x_writeback_select <= 0;
      x_rd <= 0;
      x_rs1 <= 0;
      x_rs2 <= 0;
      x_alu_select <= 0;
      x_alu_mux_select_a <= 0;
      x_alu_mux_select_b <= 0;
      x_instruction_type <= 0;
      x_opcode <= 0;
      x_funct3 <= 0;
      // x_data_rs1 <= 0;
      // x_data_rs2 <= 0;
      x_imm <= 0;
      x_jump <= 0;
  end else begin
    if (flush || stall) begin
      x_pc <= d_pc;
      x_instruction <= 32'h00000013;
      x_memory_rw <= 0;
      x_reg_write_enabled <= 1;
      x_writeback_select <= 1;
      x_rd <= 0;
      x_rs1 <= 0;
      x_rs2 <= 0;
      x_alu_select <= 0;
      x_alu_mux_select_a <= 0;
      x_alu_mux_select_b <= 0;
      x_instruction_type <= 0;
      x_opcode <= 0;
      x_funct3 <= 0;
      // x_data_rs1 <= 0;
      // x_data_rs2 <= 0;
      x_imm <= 0;
      x_jump <= 0;
    end else begin
      x_pc <= d_pc;
      x_instruction <= d_instruction;
      x_memory_rw <= d_memory_rw;
      x_reg_write_enabled <= d_reg_write_enabled;
      x_writeback_select <= d_writeback_select;
      x_rd <= d_rd;
      x_rs1 <= d_rs1;
      x_rs2 <= d_rs2;
      x_alu_select <= d_alu_select;
      x_alu_mux_select_a <= d_alu_mux_select_a;
      x_alu_mux_select_b <= d_alu_mux_select_b;
      x_instruction_type <= d_instruction_type;
      x_opcode <= d_opcode;
      x_funct3 <= d_funct3;
      // x_data_rs1 <= d_data_rs1;
      // x_data_rs2 <= d_data_rs2;
      x_imm <= d_imm;
      x_jump <= d_jump;
    end
  end
end

always @(*) begin
  if (reset) begin
      x_data_rs1 = 0;
      x_data_rs2 = 0;
  end else begin
    if (d_comb_flush || d_comb_stall) begin
      x_data_rs1 = 0;
      x_data_rs2 = 0;
    end else begin
      x_data_rs1 = d_data_rs1;
      x_data_rs2 = d_data_rs2;
    end
  end
end

endmodule