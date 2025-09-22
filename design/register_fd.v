module register_fd (
  input clock,
  input reset,
  input stall,
  input flush,
  input [31:0] f_pc,
  input [31:0] f_instruction,

  output reg [31:0] d_pc,
  output reg [31:0] d_instruction,
  output reg d_comb_flush,
  output reg d_comb_stall,
  output reg d_comb_reset
);

always @(posedge clock, posedge reset) begin
  if (reset) begin
      d_pc <= 0;
      d_comb_flush <= 0;
      d_comb_stall <= 0;
      d_comb_reset <= 1;

  end else begin
    if (flush) begin
      d_pc <= 0;
    end else if (stall) begin
      d_pc <= d_pc;
    end else begin
      d_pc <= f_pc;
    end
  d_comb_flush <= flush;
  d_comb_stall <= stall;
  d_comb_reset <= 0;

  end

end

always @(*) begin
  if (reset | d_comb_reset) begin
      d_instruction = 32'b0;
  end else begin
    if (d_comb_flush) begin
      d_instruction = 32'h00000013;
    end else begin
      d_instruction = f_instruction;
    end
  end
end

endmodule