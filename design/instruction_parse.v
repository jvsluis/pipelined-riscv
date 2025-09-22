module instruction_parse
(
    input [31:0] instruction,
    output reg [6:0] opcode,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [4:0] shamt
);

always @(*) begin
    opcode = instruction[6:0];
    rd = instruction[11:7];
    rs1 = instruction[19:15];
    rs2 = instruction[24:20];
    funct3 = instruction[14:12];
    funct7 = instruction[31:25];
    shamt = instruction[24:20];

    // If it is an I type then set rs2 and funct7 to 0.
    if (opcode == 'b0010011 || opcode == 'b0000011) begin
        rs2 = 5'b00000;
    end

    // If its B or S type then set rd to 00.
    if (opcode == 'b1100011 || opcode == 'b0100011) begin
        rd = 5'b00000;
    end

    // U Type
    if (opcode == 'b0110111 || opcode == 'b0010111) begin
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
    end
end

endmodule