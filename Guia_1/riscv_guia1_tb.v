`timescale 1ns/1ps

module tb_riscv;

    // Señales de prueba
    reg [31:0] instr;
    reg clk;
    reg rst;

    // Instancia del DUT (Device Under Test)
    riscv uut (
        .clk(clk),
        .instr(instr)
    );

    // Bloque inicial: aplica estímulos
    integer i;
    initial begin

        // Configurar la generación de archivos de volcado
        $dumpfile("tb_riscv.vcd");
        $dumpvars(0, tb_riscv);

        for(i=0; i<32; i=i+1)
            $dumpvars(0, uut.rf.registers[i]);

        // Inicia el register file para facilitar la prueba
        // En este caso cada registro xN toma el valor de N,
        // por ejemplo, x10 = 10.
        for(i=0; i<32; i=i+1)
            uut.rf.registers[i] = i;

        // Muestra en consola los valores de interés cada vez que cambien
        $monitor($time,
                 " clk=%d | ins=%h | x4=%h x5=%h x6=%h x7=%h x8=%h",
                 clk,
                 instr,
                 uut.rf.registers[4],
                 uut.rf.registers[5],
                 uut.rf.registers[6],
                 uut.rf.registers[7],
                 uut.rf.registers[8]);

        #0;
        clk = 0;
        rst = 1;

        #3;
        rst = 0;

        // ADD x4, x3, x2
        instr = 32'b0000000_00010_00011_000_00100_0110011;
        $display("add x4, x3, x2");

        #12;

        // SUB x5, x3, x2
        instr = 32'b0100000_00010_00011_000_00101_0110011;
        $display("sub x5, x3, x2");

        #12;

        // AND x6, x10, x12
        instr = 32'b0000000_01100_01010_111_00110_0110011;
        $display("and x6, x10, x12");

        #12;

        // OR x7, x3, x2
        instr = 32'b0000000_00010_00011_110_00111_0110011;
        $display("or x7, x3, x2");

        #12;

        // XOR x8, x3, x2
        instr = 32'b0000000_00010_00011_100_01000_0110011;
        $display("xor x8, x3, x2");

        #16;

        // Fin de la simulación
        $finish;

    end

    always
    begin
        #2 clk = !clk;
    end

endmodule

