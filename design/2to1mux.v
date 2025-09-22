module two_one_mux
(
    input select,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] out
);

always @(*) begin
    case (select)
        1'b0: out = a;
        1'b1: out = b;
    endcase
end

endmodule