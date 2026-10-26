`timescale 1ns/1ps

module alu_tb;

    reg [31:0] A;
    reg [31:0] B;
    reg [2:0] op;

    wire [31:0] ALU_out;

    // Instanciación de la ALU
    alu uut (
        .A(A),
        .B(B),
        .op(op),
        .ALU_out(ALU_out)
    );

    initial begin

        $monitor("Tiempo=%0t | A=%0d | B=%0d | op=%b | ALU_out=%0d",
                 $time, A, B, op, ALU_out);

        // ADD: 10 + 5 = 15
        A = 32'd10;
        B = 32'd5;
        op = 3'b000;
        #10;

        // SUB: 10 - 5 = 5
        A = 32'd10;
        B = 32'd5;
        op = 3'b001;
        #10;

        // SLL: 5 << 2 = 20
        A = 32'd5;
        B = 32'd2;
        op = 3'b010;
        #10;

        // XOR
        A = 32'h0000000F;
        B = 32'h00000003;
        op = 3'b011;
        #10;

        // OR
        A = 32'h0000000F;
        B = 32'h00000030;
        op = 3'b100;
        #10;

        // AND
        A = 32'h0000000F;
        B = 32'h00000003;
        op = 3'b101;
        #10;

        $finish;

    end

endmodule