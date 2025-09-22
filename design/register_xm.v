module register_xm (
    input clock,
    input reset,

    input [31:0] x_pc,
    input [31:0] x_data_rs2,
    input x_memory_rw,
    input [2:0] x_funct3,
    input [31:0] x_alu_out,
    input [1:0] x_writeback_select,
    input x_reg_write_enabled,
    input [4:0] x_rs2,
    input [4:0] x_rd,
    input [31:0] x_instruction,

    output reg [31:0] m_pc,
    output reg [31:0] m_data_rs2,
    output reg m_memory_rw,
    output reg [2:0] m_funct3,
    output reg [31:0] m_alu_out,
    output reg [1:0] m_writeback_select,
    output reg m_reg_write_enabled,
    output reg [4:0] m_rs2,
    output reg [4:0] m_rd,
    output reg [31:0] m_instruction
);

always @(posedge clock, posedge reset) begin
    if (reset) begin
        m_pc <= 0;
        m_data_rs2 <= 0;
        m_memory_rw <= 0;
        m_funct3 <= 0;
        m_alu_out <= 0;
        m_writeback_select <= 0;
        m_reg_write_enabled <= 0;
        m_rs2 <= 0;
        m_rd <= 0;
        m_instruction <= 0;
    end else begin
        m_pc <= x_pc;
        m_data_rs2 <= x_data_rs2;
        m_memory_rw <= x_memory_rw;
        m_funct3 <= x_funct3;
        m_alu_out <= x_alu_out;
        m_writeback_select <= x_writeback_select;
        m_reg_write_enabled <= x_reg_write_enabled;
        m_rs2 <= x_rs2;
        m_rd <= x_rd;
        m_instruction <= x_instruction;
    end
end

endmodule