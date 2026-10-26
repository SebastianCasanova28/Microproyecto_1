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
      .clk(clk),
      .data(instr),
      .addr(iaddr[13:2])
  );

  // Instancia de la memoria de datos
  sram_32x DMEM(
      .clk(clk),
      .addr(daddr[11:2]),
      .wr_en(dwr_en),
      .wr_data(ddata_out),
      .rd_en(drd_en),
      .rd_data(ddata_in)
  );

  endmodule

// Memoria ROM de programa
module rom4096x32 (
    input wire clk,
    input wire [11:0] addr,
    output reg [31:0] data
);

    reg [31:0] mem [0:4095];
    integer i;

    initial begin

        // Inicialización de la memoria
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 32'h00000000;

        // Carga del programa desde archivo hexadecimal
        $readmemh("test_program.hex", mem);

    end

    // Lectura de la memoria
    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule

// Modulo SRAM
module sram_32x (
    input wire clk,
    input wire [9:0] addr,
    input wire wr_en,
    input wire [31:0] wr_data,
    input wire rd_en,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:1023];
    reg [31:0] rd_data_reg;

    integer i;

    initial begin
        rd_data_reg = 32'b0;

        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'b0;
    end

    // Escritura y lectura síncronas
    always @(posedge clk) begin

        if (wr_en)
            mem[addr] <= wr_data;

        if (rd_en)
            rd_data_reg <= mem[addr];

    end

    // Salida en alta impedancia cuando la lectura no está habilitada
    assign rd_data = rd_en ? rd_data_reg : 32'bz;

endmodule
