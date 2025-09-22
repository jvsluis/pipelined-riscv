module register_file #(
    parameter TOP_OF_STACK = `MEM_DEPTH + 32'h01000000
)
(
    input clock,
    input reset,
    input [4:0]  addr_rs1,
    input [4:0]  addr_rs2,
    input [4:0]  addr_rd,
    input [31:0] data_rd,
    input write_enable,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2
);

// Allocate enough space for 32 registers
(* ram_style = "block" *) reg [31:0] register_memory [0:31];

// Init the register values and stack pointer
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        register_memory[i] = 32'b0;
    end
    register_memory[2] = TOP_OF_STACK;
end

// Note:
// Output reads are combinational
// Input writes are sequential

// Here we dont need to check write_enable low since we can read even if write is high
// always @(posedge clock) begin
// end

always @(posedge clock) begin
    if (write_enable == 1 && reset == 0) begin
        if (addr_rd != 0) begin
            register_memory[addr_rd] <= data_rd;
        end
    end
    data_rs1 <= register_memory[addr_rs1];
    data_rs2 <= register_memory[addr_rs2];
end

endmodule
