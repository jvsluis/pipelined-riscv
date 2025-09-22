module register_mw (
    input clock,
    input reset,
    input [31:0] m_pc,
    input [4:0] m_rd,
    input m_reg_write_enabled,
    input [31:0] m_instruction,

    input [31:0] m_pc_plus_four,
    input [1:0] m_writeback_select,
    input [2:0] m_funct3,
    input [31:0] m_alu_out,
  
    output reg [31:0] w_pc,
    output reg [4:0] w_rd,
    output reg w_reg_write_enabled,
    output reg [31:0] w_instruction,
    
    output reg [31:0] w_pc_plus_four,
    output reg [1:0] w_writeback_select,
    output reg [2:0] w_funct3,
    output reg [31:0] w_alu_out
);

always @(posedge clock, posedge reset) begin
    if (reset) begin
        w_pc <= 0;
        w_rd <= 0;
        w_reg_write_enabled <= 0;
        w_instruction <= 0;
        w_pc_plus_four <= 0;
        w_writeback_select <= 0;
        w_funct3 <= 0;
        w_alu_out <= 0;
    end else begin
        w_pc <= m_pc;
        w_rd <= m_rd;
        w_reg_write_enabled <= m_reg_write_enabled;
        w_instruction <= m_instruction;
        w_pc_plus_four <= m_pc_plus_four;
        w_writeback_select <= m_writeback_select;
        w_funct3 <= m_funct3;
        w_alu_out <= m_alu_out;
    end
end

endmodule