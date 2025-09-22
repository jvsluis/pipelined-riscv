module register_pc (
    input clock,
    input reset,
    input stall,
    input flush,
    input [31:0] pc,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus_four
);

always @(posedge clock, posedge reset) begin
  if (reset) begin
    // Reset the program counter to 0x01000000
    pc_out <= 'h01000000;
    pc_plus_four <= 'h01000000 + 4;
  end else begin
    if (stall && !flush) begin
      // If we're stalling then hold this constant
      pc_out <= pc_out;
      pc_plus_four <= pc_plus_four;
    end else begin
      pc_out <= pc;
      pc_plus_four <= pc + 4;
    end
  end
end

endmodule