module writeback_gen (
    input wire [31:0] data,
    input wire [2:0] writeback_size, // this is funct3 from the load instruction in question
    output reg [31:0] out
);

always @(*) begin
    case (writeback_size)
        3'b000: begin //lb
            out = {{24{data[7]}}, data[7:0]};
        end
        3'b001: begin //lh
            out = {{16{data[15]}}, data[15:0]};
        end
        3'b010: begin //lw
            out = data;
        end
        3'b100: begin //lbu
            out = {24'b0, data[7:0]};
        end
        3'b101: begin //lhu
            out = {16'b0, data[15:0]};
        end
        default: out = 32'b0;
    endcase
end

endmodule