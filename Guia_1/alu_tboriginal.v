`timescale 1ns/1ps

module ALU_tb;

    reg [7:0] A;
    reg [7:0] B;
    reg [1:0] op;
    wire [7:0] ALU_out;

    // Instancia de la ALU
    ALU uut (
        .A(A),
        .B(B),
        .op(op),
        .ALU_out(ALU_out)
    );

    initial begin

        // Monitor de las señales
        $monitor("Tiempo=%0t | A=%d | B=%d | op=%h | ALU_out=%d",
                 $time, A, B, op, ALU_out);

        // SUMA
        A = 8'h0A;
        B = 8'h05;
        op = 2'b00;
        #10;

        // RESTA
        A = 8'h0A;
        B = 8'h05;
        op = 2'b01;
        #10;

        // AND
        A = 8'h0F;
        B = 8'h03;
        op = 2'b10;
        #10;

        // OR
        A = 8'h0F;
        B = 8'h30;
        op = 2'b11;
        #10;

        // Otra prueba de suma
        A = 8'hFF;
        B = 8'h01;
        op = 2'b00;
        #10;

        // Otra prueba de resta
        A = 8'h10;
        B = 8'h01;
        op = 2'b01;
        #10;

        $finish;
    end

endmodule