module ALU (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [1:0] op,
    output wire [7:0] ALU_out
);

    assign ALU_out = (op == 2'b00) ? A + B :
                     (op == 2'b01) ? A - B :
                     (op == 2'b10) ? A & B :
                                    A | B;

endmodule