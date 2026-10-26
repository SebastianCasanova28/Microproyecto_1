//Definición del microcontrolador
module mcu(
  input clk,  //Reloj del microcontrolador
  input rst   //Reset del microcontrolador
);

  //Buses con la memoria de programa (IMEM)
  wire [31:0] instr;  //Instrucción de entrada
  wire [31:0] iaddr;  //Dirección en la IMEM

  //Buses con la memoria de datos (DMEM)
  wire [31:0] daddr;      //Dirección en la DMEM
  wire [31:0] ddata_in;   //Bus de datos DMEM (entrada)
  wire  [31:0] ddata_out; //Bus de datos DMEM (salida)
  wire dwr_en;  //Señales del bus de control DMEM
  wire drd_en;

  // Instancia del microprocesador RISCV
  riscv cpu (
    .rst(rst),
    .clk(clk),
    .instr(instr),
    .iaddr(iaddr),
    .daddr(daddr),
    .ddata_in(ddata_in),
    .ddata_out(ddata_out),
    .dwr_en(dwr_en), 
    .drd_en(drd_en)
  );

  // Instancia de la memoria de programa
  rom4096x32 IMEM(
    .data(instr),
    .addr(iaddr[13:2])
  );

  endmodule

// Memoria ROM de programa
module rom4096x32 (
    input wire [11:0] addr,
    output reg [31:0] data
);

    reg [31:0] mem [0:4095];
    integer i;

    initial begin

        // Inicialización de la memoria
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 32'h00000000;

        // Programa ejemplo 2: do...while
        mem[0] = 32'h000001B3;   // add  x3,  x0, x0
        mem[1] = 32'h000002B3;   // add  x5,  x0, x0
        mem[2] = 32'h00500313;   // addi x6,  x0, 5
        mem[3] = 32'h005181B3;   // add  x3,  x3, x5
        mem[4] = 32'h00128293;   // addi x5,  x5, 1
        mem[5] = 32'hFE62CCE3;   // blt  x5,  x6, do1
        mem[6] = 32'h00018633;   // add  x12, x3, x0

    end

    // Lectura de la memoria
    always @(*) begin
        data = mem[addr];
    end

endmodule
