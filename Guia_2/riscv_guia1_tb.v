`timescale 1ns/1ps

module tb_riscv;

    reg [31:0] instr;
    reg clk;
    reg rst;

    integer i;

    // Instanciación del procesador
    riscv uut (
        .clk(clk),
        .rst(rst),
        .instr(instr)
    );

    initial begin
        $dumpfile("tb_riscv.vcd");
        $dumpvars(0, tb_riscv);
            
        // Guardar los registros del RF en el archivo VCD
        for(i = 0; i < 32; i = i + 1)
        $dumpvars(0, uut.rf.registers[i]);

        // Inicialización del banco de registros
        for(i = 0; i < 32; i = i + 1)
            uut.rf.registers[i] = i;

        clk = 0;
        rst = 0;
        instr = 32'b0;

        $monitor("Tiempo=%0t | instr=%h | x4=%0d | x5=%0d | x6=%0d | x7=%0d | x8=%0d | x9=%0d | x10=%0d | x11=%0d | x12=%0d",
                 $time, instr,
                 uut.rf.registers[4],
                 uut.rf.registers[5],
                 uut.rf.registers[6],
                 uut.rf.registers[7],
                 uut.rf.registers[8],
                 uut.rf.registers[9],
                 uut.rf.registers[10],
                 uut.rf.registers[11],
                 uut.rf.registers[12]);

        // -------------------------
        // Instrucciones tipo R
        // -------------------------

        // add x4, x3, x2
        #4;
        instr = 32'b0000000_00010_00011_000_00100_0110011;
        #12;

        // sub x5, x3, x2
        instr = 32'b0100000_00010_00011_000_00101_0110011;
        #12;

        // and x6, x10, x12
        instr = 32'b0000000_01100_01010_111_00110_0110011;
        #12;

        // or x7, x3, x2
        instr = 32'b0000000_00010_00011_110_00111_0110011;
        #12;

        // xor x8, x3, x2
        instr = 32'b0000000_00010_00011_100_01000_0110011;
        #12;


        // -------------------------
        // Instrucciones tipo I
        // -------------------------

        // addi x9, x3, 5
        // x9 = 3 + 5 = 8
        instr = 32'b000000000101_00011_000_01001_0010011;
        #12;

        // andi x10, x3, 1
        // x10 = 3 AND 1 = 1
        instr = 32'b000000000001_00011_111_01010_0010011;
        #12;

        // ori x11, x3, 4
        // x11 = 3 OR 4 = 7
        instr = 32'b000000000100_00011_110_01011_0010011;
        #12;

        // xori x12, x3, 6
        // x12 = 3 XOR 6 = 5
        instr = 32'b000000000110_00011_100_01100_0010011;
        #12;

        $finish;
    end

    // Reloj
    always begin
        #2 clk = !clk;
    end

endmodule

