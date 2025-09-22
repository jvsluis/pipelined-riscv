module hazard_unit (
    input [4:0] d_rs1,
    input [4:0] d_rs2,
    input [6:0] d_opcode,
    input [6:0] x_opcode,
    input [4:0] x_rd,

    // input[31:0] d_pc,
    // input[31:0] x_pc,

    // For the bypassing
    input x_reg_write_enabled,
    input m_reg_write_enabled,
    input w_reg_write_enabled,
    input [4:0] x_rs1,
    input [4:0] x_rs2,
    input [4:0] m_rs2,
    input [4:0] m_rd,
    input [4:0] w_rd,

    output reg f_stall,
    output reg d_stall,
    output reg [1:0] x_bypass_rs1_select,
    output reg [1:0] x_bypass_rs2_select,
    output reg       m_forward_mux_select  
);

// Parallelize the conditions to speed up the hazard units propagation
wire w_hazard_rs1 = (w_rd == d_rs1) && w_reg_write_enabled && (w_rd != 0);
wire x_hazard_rs1 = (x_rd == d_rs1) && x_reg_write_enabled && (x_rd != 0);
wire m_hazard_rs1 = (m_rd == d_rs1) && m_reg_write_enabled && (m_rd != 0);
wire rs1_stall_condition = w_hazard_rs1 && !(x_hazard_rs1 || m_hazard_rs1);
wire w_hazard_rs2 = (w_rd == d_rs2) && w_reg_write_enabled && (w_rd != 0);
wire x_hazard_rs2 = (x_rd == d_rs2) && x_reg_write_enabled && (x_rd != 0);
wire m_hazard_rs2 = (m_rd == d_rs2) && m_reg_write_enabled && (m_rd != 0);
wire rs2_stall_condition = w_hazard_rs2 && !(x_hazard_rs2 || m_hazard_rs2);

always @(*) begin
  if ( x_opcode == 'b0000011 && ( (d_rs1 == x_rd) || ( (d_rs2 == x_rd) && d_opcode != 'b0100011) ) ) begin
    f_stall = 1;
    d_stall = 1;
  // We now use these two pre-computed conditions to check for stall. This allows the sub-expressions to be done in parallel
  end else if (rs1_stall_condition || rs2_stall_condition) begin
    f_stall = 1;
    d_stall = 1;
  end else begin
    f_stall = 0;
    d_stall = 0;
  end

  // In all cases we just check for if the write bit is enabled. Since this tells us if this
  // is an instruction that will do a write back. Nice and simple!
  if ((x_rs1 == m_rd) && m_reg_write_enabled && (x_rs1 != 0)) begin
    // M/X bypass into rs1
    x_bypass_rs1_select = 2'b01;
  end else if ((x_rs1 == w_rd) && w_reg_write_enabled && (x_rs1 != 0)) begin
    // W/X bypass into rs1
    x_bypass_rs1_select = 2'b10;
  end else begin
    // No bypass
    x_bypass_rs1_select = 2'b00;
  end

  if ((x_rs2 == m_rd) && m_reg_write_enabled && (x_rs2 != 0)) begin
    // M/X bypass into rs2
    x_bypass_rs2_select = 2'b01;
  end else if ((x_rs2 == w_rd) && w_reg_write_enabled && (x_rs2 != 0)) begin
    // W/X bypass into rs2
    x_bypass_rs2_select = 2'b10;
  end else begin
    // No bypass
    x_bypass_rs2_select = 2'b00;
  end

  if ((m_rs2 == w_rd) && w_reg_write_enabled) begin
    m_forward_mux_select = 1'b1;
    //$display("Hit this 5");
  end else begin
    m_forward_mux_select = 1'b0;
  end

end

endmodule