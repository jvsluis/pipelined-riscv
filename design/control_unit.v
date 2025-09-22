`define R_TYPE 3'b000
`define I_TYPE 3'b001
`define S_TYPE 3'b010
`define B_TYPE 3'b011
`define U_TYPE 3'b100
`define J_TYPE 3'b101

module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [2:0] instruction_type,
    output reg a_select,
    output reg b_select,
    output reg [3:0] alu_select,
    output reg regfile_enable,
    output reg [1:0] wb_sel,
    output reg mem_rw,
    output reg d_jump
);

// ASel 0 = Reg, 1 = PC
// BSel 0 = Reg, 1 = Imm

// wb_sel
// 00: Data Memory Out
// 01: ALU Out
// 10: PC+4
always @(*) begin
    case (opcode)

        // R Type Arithmetic Operators
        7'b0110011: begin
            instruction_type = `R_TYPE;
            a_select = 1'b0; // Reg1
            b_select = 1'b0; // Reg2
            // This will make the ALU select the lower 3 bits + the 5th bit of funct7
            // which toggles add/sub and srl/sra
            alu_select = {funct7[5], funct3};
            regfile_enable = 1;
            wb_sel = 2'b01;
            mem_rw = 0;
            d_jump = 0;
        end

        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        // I Type
        7'b0010011: begin
            instruction_type = `I_TYPE;
            a_select = 1'b0; // Reg
            b_select = 1'b1; // Imm
            case (funct3)
                3'b001:  alu_select = {funct7[5], funct3};
                3'b101:  alu_select = {funct7[5], funct3};
                default: alu_select = {1'b0, funct3};
            endcase
            regfile_enable = 1;
            wb_sel = 2'b01;
            mem_rw = 0;
            d_jump = 0;
        end

        // LUI
        // U Type
        7'b0110111: begin
            instruction_type = `U_TYPE;
            a_select = 1'b0;         // Dont Care
            b_select = 1'b1;         // Imm
            alu_select = 4'b1111; // Pass Through B
            regfile_enable = 1;
            wb_sel = 2'b01;
            mem_rw = 0;
            d_jump = 0;
        end

        // AUIPC
        // U Type
        7'b0010111: begin
            instruction_type = `U_TYPE;
            a_select = 1'b1;         // PC
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD
            regfile_enable = 1;   // Write Enable
            wb_sel = 2'b01;       // ALU Out
            mem_rw = 0;           // Read
            d_jump = 0;
        end
            
        // JAL
        // J Type
        7'b1101111: begin
            instruction_type = `J_TYPE;
            a_select = 1'b1;         // PC
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD
            regfile_enable = 1;   // Write Enable
            wb_sel = 2'b10;       // PC+4
            mem_rw = 0;           // Read
            d_jump = 1;
        end
            
        // JALR
        // I Type
        7'b1100111: begin
            instruction_type = `I_TYPE;
            a_select = 1'b0;         // Reg
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD
            regfile_enable = 1;   // Write Enable
            wb_sel = 2'b10;       // PC+4 Out
            mem_rw = 0;           // Read
            d_jump = 1;
        end

        // B Type
        7'b1100011: begin
            instruction_type = `B_TYPE;
            a_select = 1'b1;         // PC
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD

            regfile_enable = 0; // Read
            wb_sel = 2'b11; // Dont Care
            mem_rw = 0; // Read
            d_jump = 0;
        end

        // LB, LH, LW, LBU, LHU
        // I Type
        7'b0000011: begin
            instruction_type = `I_TYPE;
            a_select = 1'b0;         // Reg
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD
            regfile_enable = 1;
            wb_sel = 2'b00;
            mem_rw = 0;
            d_jump = 0;
        end
            
        // SB, SH, SW
        // S Type
        7'b0100011: begin
            instruction_type = `S_TYPE;
            a_select = 1'b0;         // Reg
            b_select = 1'b1;         // Imm
            alu_select = 4'b0000; // ADD
            regfile_enable = 0;   // Write Enable
            wb_sel = 2'b11;       // Dont Care
            mem_rw = 1;           // Write Enable
            d_jump = 0;
        end

        // ECALL
        // For now we do nothing?
        7'b1110011: begin
            instruction_type = `R_TYPE; // Dont Care
            a_select = 1'b0;               // Dont Care
            b_select = 1'b0;               // Dont Care
            alu_select = 4'b0000;       // Dont Care
            regfile_enable = 0;         // Dont Care
            wb_sel = 2'b11;             // Dont Care
            mem_rw = 0;                 // Dont Care
            d_jump = 0;
        end

        default: begin
            instruction_type = `R_TYPE; // Dont Care
            a_select = 1'b0;               // Dont Care
            b_select = 1'b1;               // Dont Care
            alu_select = 4'b0000;       // Dont Care
            regfile_enable = 0;         // Dont Care
            wb_sel = 2'b11;             // Dont Care
            mem_rw = 0;                 // Dont Care
            d_jump = 0;
        end

    endcase
end

endmodule