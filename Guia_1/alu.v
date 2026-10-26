module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0] op,
    output wire [31:0] ALU_out
);

    assign ALU_out =
        (op == 3'b000) ? A + B       : // ADD
        (op == 3'b001) ? A - B       : // SUB
        (op == 3'b010) ? A << B[4:0] : // SLL
        (op == 3'b011) ? A ^ B       : // XOR
        (op == 3'b100) ? A | B       : // OR
                         A & B;         // AND

endmodule