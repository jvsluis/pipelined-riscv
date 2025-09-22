module pd(
  input clock,
  input reset
);

// Hazards
wire f_stall;
wire d_stall;
wire d_comb_flush;
wire d_comb_stall;
wire d_comb_reset;

// Fetch
wire [31:0] f_pc_sel_mux_out;
wire [31:0] f_pc;
wire [31:0] f_pc_plus_four;
wire [31:0] f_instruction;

// Decode
wire [31:0] d_pc;
wire [31:0] d_instruction;
wire [6:0]  d_opcode;    
wire [4:0]  d_rd;
wire [4:0]  d_rs1;
wire [4:0]  d_rs2;
wire [2:0]  d_funct3;
wire [6:0]  d_funct7;
wire [4:0]  d_shamt;
wire [31:0] d_imm;
wire [31:0] d_data_rd;
wire [31:0] d_data_rs1;
wire [31:0] d_data_rs2;

wire [2:0]  d_instruction_type;
wire [3:0]  d_alu_select;
wire        d_alu_mux_select_a;
wire        d_alu_mux_select_b;
wire        d_reg_write_enabled;
wire        d_memory_rw;
wire [1:0]  d_writeback_select;
wire        d_jump;

// Execute
wire [31:0] x_pc;
wire [31:0] x_instruction;
wire [6:0]  x_opcode;    
wire [2:0]  x_funct3;
wire [6:0]  x_funct7;
wire [4:0]  x_rd;
wire [4:0]  x_rs1;
wire [4:0]  x_rs2;
wire [31:0] x_data_rs1;
wire [31:0] x_data_rs2;
wire [31:0] x_alu_a;
wire [31:0] x_alu_b;
wire [31:0] x_alu_out;
wire [2:0]  x_instruction_type;
wire [31:0] x_imm;

wire        x_pc_select;
wire [1:0]  x_branch_select_a;
wire [1:0]  x_branch_select_b;
wire [31:0] x_branch_mux_a_out;
wire [31:0] x_branch_mux_b_out;
wire        x_branch_taken;
wire        x_jump;
wire        x_alu_mux_select_a;
wire        x_alu_mux_select_b;
wire [3:0]  x_alu_select;

wire [1:0]  x_bypass_rs1_select;
wire [1:0]  x_bypass_rs2_select;
wire [31:0] x_bypass_rs1_out;
wire [31:0] x_bypass_rs2_out;

wire        x_reg_write_enabled;
wire        x_memory_rw;
wire [1:0]  x_writeback_select;

// Memory
wire [31:0] m_pc;
wire [31:0] m_instruction;
wire [2:0]  m_funct3;
wire [31:0] m_alu_out;
wire [31:0] m_data_rs2;
wire [31:0] m_dmem_out;
wire [31:0] m_dmem_corrected;
wire [1:0]  m_size_encoded;
wire        m_forward_mux_select;
wire [31:0] m_forward_mux_out;

wire        m_reg_write_enabled;
wire        m_memory_rw;
wire [1:0]  m_writeback_select;
wire [31:0] m_writeback_mux_out;
wire [4:0]  m_rd;
wire [4:0]  m_rs2;


// Writeback
wire [31:0] w_instruction;
wire [31:0] w_pc;
wire [31:0] w_pc_plus_four;
wire [31:0] w_writeback_mux_out;
wire [4:0]  w_rd;
wire        w_reg_write_enabled;

wire [31:0] w_alu_out;
wire [2:0]  w_funct3;
wire [31:0] w_dmem_corrected;
wire [1:0]  w_writeback_select;

////////////////////////////////////////////////////////////////////////////////
// Hazard Signal Controller
////////////////////////////////////////////////////////////////////////////////
hazard_unit hazard_unit_instance (
  .d_rs1(d_rs1),
  .d_rs2(d_rs2),
  .d_opcode(d_opcode),
  .x_opcode(x_opcode),
  .x_rd(x_rd),
  .x_reg_write_enabled(x_reg_write_enabled),
  .m_reg_write_enabled(m_reg_write_enabled),
  .w_reg_write_enabled(w_reg_write_enabled),
  .x_rs1(x_rs1),
  .x_rs2(x_rs2),
  .m_rs2(m_rs2),
  .m_rd(m_rd),
  .w_rd(w_rd),

  // .d_pc(d_pc),
  // .x_pc(x_pc),

  // output
  .f_stall(f_stall),
  .d_stall(d_stall),
  .x_bypass_rs1_select(x_bypass_rs1_select),
  .x_bypass_rs2_select(x_bypass_rs2_select),
  .m_forward_mux_select(m_forward_mux_select)
);

////////////////////////////////////////////////////////////////////////////////
// Fetch Stage
////////////////////////////////////////////////////////////////////////////////

two_one_mux pc_sel_mux (
  .select(x_pc_select),
  .a(f_pc_plus_four),
  .b(x_alu_out),
  .out(f_pc_sel_mux_out)
);

register_pc register_pc_instance (
  .clock(clock),
  .reset(reset),
  .stall(f_stall),
  .flush(x_pc_select),
  .pc(f_pc_sel_mux_out),
  .pc_out(f_pc),
  .pc_plus_four(f_pc_plus_four)
);

/*
    input             clock,
    input      [31:0] address,
    input      [31:0] data_in,
    input             read_write,
    input             enable,
    output reg [31:0] data_out
*/
imemory imemory_instance (
  .clock(clock),
  .read_write(0),
  .enable(!(d_stall)),
  .address(f_pc),
  .data_in(0),
  .data_out(f_instruction)
);

register_fd register_fd_instance (
  // input
  .clock(clock),
  .reset(reset),
  .stall(d_stall),
  .flush(x_pc_select),
  .f_pc(f_pc),
  .f_instruction(f_instruction),

  // output
  .d_pc(d_pc),
  .d_instruction(d_instruction),
  .d_comb_flush(d_comb_flush),
  .d_comb_stall(d_comb_stall),
  .d_comb_reset(d_comb_reset)
);

////////////////////////////////////////////////////////////////////////////////
// Decode Stage
////////////////////////////////////////////////////////////////////////////////
// NOTE: f_instruction is now d_instruction since it is registered in the module...

// always @(*) begin
//   $display("%0h", d_instruction);
// end



instruction_parse instruction_parse_instance (
  .instruction(d_instruction),
  .opcode(d_opcode),
  .rd(d_rd),
  .rs1(d_rs1),
  .rs2(d_rs2),
  .funct3(d_funct3),
  .funct7(d_funct7),
  .shamt(d_shamt)
);

register_file register_file_instance (
  .clock(clock),
  .reset(reset),
  .addr_rs1(d_rs1),
  .addr_rs2(d_rs2),
  .addr_rd(w_rd),
  .data_rd(w_writeback_mux_out),
  .write_enable(w_reg_write_enabled),
  .data_rs1(d_data_rs1),  // MAJOR NOTE: x_data_rs1 is automatically registered here so we got rid of it in D/X
  .data_rs2(d_data_rs2)   // MAJOR NOTE: x_data_rs2 is automatically registered here so we got rid of it in D/X
);

control_unit control_unit_instance (
  .opcode(d_opcode),
  .funct3(d_funct3),
  .funct7(d_funct7),
  
  .instruction_type(d_instruction_type),
  .a_select(d_alu_mux_select_a),
  .b_select(d_alu_mux_select_b),
  .alu_select(d_alu_select),
  .regfile_enable(d_reg_write_enabled),
  .wb_sel(d_writeback_select),
  .mem_rw(d_memory_rw),
  .d_jump(d_jump)
);

immediate_gen immediate_gen_instance2 (
  .instruction(d_instruction),
  .type(d_instruction_type),
  .imm(d_imm)
);

register_dx register_dx_instance (
  .clock(clock),
  .reset(reset),
  .flush(x_pc_select),
  .stall(d_stall),

  // input
  .d_pc(d_pc),
  .d_instruction(d_instruction),
  .d_memory_rw(d_memory_rw),
  .d_reg_write_enabled(d_reg_write_enabled),
  .d_writeback_select(d_writeback_select),
  .d_rd(d_rd),
  .d_rs1(d_rs1),
  .d_rs2(d_rs2),
  .d_alu_select(d_alu_select),
  .d_alu_mux_select_a(d_alu_mux_select_a),
  .d_alu_mux_select_b(d_alu_mux_select_b),
  .d_instruction_type(d_instruction_type),
  .d_opcode(d_opcode),
  .d_funct3(d_funct3),
  .d_data_rs1(d_data_rs1),
  .d_data_rs2(d_data_rs2),
  .d_imm(d_imm),
  .d_jump(d_jump),
  .d_comb_flush(d_comb_flush),
  .d_comb_stall(d_comb_stall),

  // output
  .x_pc(x_pc),
  .x_instruction(x_instruction),
  .x_memory_rw(x_memory_rw),
  .x_reg_write_enabled(x_reg_write_enabled),
  .x_writeback_select(x_writeback_select),
  .x_rd(x_rd),
  .x_rs1(x_rs1),
  .x_rs2(x_rs2),
  .x_alu_select(x_alu_select),
  .x_alu_mux_select_a(x_alu_mux_select_a),
  .x_alu_mux_select_b(x_alu_mux_select_b),
  .x_instruction_type(x_instruction_type),
  .x_opcode(x_opcode),
  .x_funct3(x_funct3),
  .x_data_rs1(x_data_rs1),
  .x_data_rs2(x_data_rs2),
  .x_imm(x_imm),
  .x_jump(x_jump)
);

////////////////////////////////////////////////////////////////////////////////
// Execute Stage
////////////////////////////////////////////////////////////////////////////////

four_one_mux x_bypass_mux_rs1 (
  .select(x_bypass_rs1_select),
  .a(x_data_rs1),
  .b(m_alu_out),
  .c(w_writeback_mux_out),
  .d(0),
  .out(x_bypass_rs1_out)
);

four_one_mux x_bypass_mux_rs2 (
  .select(x_bypass_rs2_select),
  .a(x_data_rs2),
  .b(m_alu_out),
  .c(w_writeback_mux_out),
  .d(0),
  .out(x_bypass_rs2_out)
);

branch_compute branch_compute_instance (
  .opcode(x_opcode),
  .branch_type(x_funct3),
  .rs1(x_bypass_rs1_out),
  .rs2(x_bypass_rs2_out),
  .x_jump(x_jump),
  .branch_taken(x_branch_taken),
  .x_pc_select(x_pc_select)
);

two_one_mux alu_A_mux (
  .select(x_alu_mux_select_a),
  .a(x_bypass_rs1_out),
  .b(x_pc),
  .out(x_alu_a)
);

two_one_mux alu_B_mux (
  .select(x_alu_mux_select_b),
  .a(x_bypass_rs2_out),
  .b(x_imm),
  .out(x_alu_b)
);

alu alu_instance (
  .alu_select(x_alu_select),
  .A(x_alu_a),
  .B(x_alu_b),
  .out(x_alu_out)
);

register_xm register_xm_instance (
  .clock(clock),
  .reset(reset),

  // Input
  .x_pc(x_pc),
  .x_data_rs2(x_bypass_rs2_out),
  .x_memory_rw(x_memory_rw),
  .x_funct3(x_funct3),
  .x_alu_out(x_alu_out),
  .x_writeback_select(x_writeback_select),
  .x_reg_write_enabled(x_reg_write_enabled),
  .x_rs2(x_rs2),
  .x_rd(x_rd),
  .x_instruction(x_instruction),

  // Output
  .m_pc(m_pc),
  .m_data_rs2(m_data_rs2),
  .m_memory_rw(m_memory_rw),
  .m_funct3(m_funct3),
  .m_alu_out(m_alu_out),
  .m_writeback_select(m_writeback_select),
  .m_reg_write_enabled(m_reg_write_enabled),
  .m_rs2(m_rs2),
  .m_rd(m_rd),
  .m_instruction(m_instruction)
);

////////////////////////////////////////////////////////////////////////////////
// Memory Stage
////////////////////////////////////////////////////////////////////////////////
assign m_size_encoded = m_funct3[1:0];
wire [31:0] m_pc_plus_four = m_pc + 4;

two_one_mux dmemory_forward_mux (
  .select(m_forward_mux_select),
  .a(m_data_rs2),
  .b(w_writeback_mux_out),
  .out(m_forward_mux_out)
);

dmemory dmemory_instance (
  .clock(       clock),
  .read_write(  m_memory_rw),
  .access_size( m_size_encoded),
  .address(     m_alu_out),
  .data_in(     m_forward_mux_out),
  .data_out(    m_dmem_out)
);

////////////////////////////////////////////////////////////////////////////////
// Writeback Stage
////////////////////////////////////////////////////////////////////////////////

register_mw register_mw_instance (
  .clock(clock),
  .reset(reset),

  .m_pc(m_pc),
  .m_rd(m_rd),
  .m_reg_write_enabled(m_reg_write_enabled),
  .m_instruction(m_instruction),

  .m_pc_plus_four(m_pc_plus_four),
  .m_writeback_select(m_writeback_select),
  .m_funct3(m_funct3),
  .m_alu_out(m_alu_out),

  // Output
  .w_pc(w_pc),
  .w_rd(w_rd),
  .w_reg_write_enabled(w_reg_write_enabled),
  .w_instruction(w_instruction),
  
  .w_pc_plus_four(w_pc_plus_four),
  .w_writeback_select(w_writeback_select),
  .w_funct3(w_funct3),
  .w_alu_out(w_alu_out)
);

// The dataout is already registered, so just pass through to this unit
writeback_gen writeback_gen_instance (
    m_dmem_out,
    w_funct3,             // this is funct3 from the load instruction in question
    w_dmem_corrected
);

four_one_mux writeback_mux (
  .select( w_writeback_select),
  .a     ( w_dmem_corrected),
  .b     ( w_alu_out),
  .c     ( w_pc_plus_four),
  .d     ( 0),
  .out   ( w_writeback_mux_out)
);

endmodule