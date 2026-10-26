//Definición del microcontrolador
module mcu(
    input clk,                 // Reloj del microcontrolador
    input rst,                 // Reset del microcontrolador
    output reg [7:0] PORTA,    // Puerto A (salida)
    output reg [7:0] PORTB,    // Puerto B (salida)
    input wire [7:0] PORTC     // Puerto C (entrada)
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
  
  // Señales de control de los puertos de E/S
  wire wr_porta;
  wire wr_portb;
  wire rd_portc; 

  // Señales de selección y control de DMEM
  wire sel_dmem;
  wire dmem_wr_en;
  wire dmem_rd_en;

  // Decodificador de direcciones de memoria
  assign sel_dmem = (daddr[31:14] == 18'b0);

  // Habilitación de lectura y escritura de DMEM
  assign dmem_wr_en = dwr_en && sel_dmem;
  assign dmem_rd_en = drd_en && sel_dmem;

  // Decodificadores de direcciones de los puertos

  // Escritura en PORTA: dirección 0x4000
  assign wr_porta = dwr_en &&
                    (daddr == 32'h00004000);

  // Escritura en PORTB: dirección 0x4004
  assign wr_portb = dwr_en &&
                    (daddr == 32'h00004004);

  // Lectura de PORTC: dirección 0x4008
  assign rd_portc = drd_en &&
                    (daddr == 32'h00004008);


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
      .addr(daddr[13:2]),
      .wr_en(dmem_wr_en),
      .wr_data(ddata_out),
      .rd_en(dmem_rd_en),
      .rd_data(ddata_in)
  );

  // Registros de salida PORTA y PORTB
  always @(posedge clk) begin
      if (rst) begin
          PORTA <= 8'b0;
          PORTB <= 8'b0;
      end
      else begin
          if (wr_porta)
              PORTA <= ddata_out[7:0];

          if (wr_portb)
              PORTB <= ddata_out[7:0];
      end
  end
 
  // Buffer triestado para lectura de PORTC
  assign ddata_in = rd_portc ?
                    {24'b0, PORTC} :
                    32'bz;
  
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
    input wire [11:0] addr,
    input wire wr_en,
    input wire [31:0] wr_data,
    input wire rd_en,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:4095];
    reg [31:0] rd_data_reg;

    integer i;

    initial begin
        rd_data_reg = 32'b0;

        for (i = 0; i < 4096; i = i + 1)
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
