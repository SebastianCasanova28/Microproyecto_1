`timescale 1ns / 1ps

module tb_RegisterFile;

    reg clk;

    reg wr_en;
    reg [31:0] wr_data;
    reg [4:0] wr_index;

    reg [4:0] rd_index1;
    reg [4:0] rd_index2;

    wire [31:0] rd_data1;
    wire [31:0] rd_data2;

    RegisterFile DUT(
        .clk(clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_index(wr_index),
        .rd_index1(rd_index1),
        .rd_index2(rd_index2),
        .rd_data1(rd_data1),
        .rd_data2(rd_data2)
    );

    //--------------------------------------------------
    // Generación del reloj (100 MHz)
    //--------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------
    initial begin
        $monitor("t=%0t | wr_en=%b wr_idx=%d wr_data=%h | rd1=x%0d=%h | rd2=x%0d=%h",
                  $time,
                  wr_en,
                  wr_index,
                  wr_data,
                  rd_index1,
                  rd_data1,
                  rd_index2,
                  rd_data2);
    end

    //--------------------------------------------------
    // Estímulos
    //--------------------------------------------------
    initial begin

        wr_en = 0;
        wr_data = 0;
        wr_index = 0;
        rd_index1 = 0;
        rd_index2 = 0;

        #10;

        // Escribir x1
        wr_en = 1;
        wr_index = 5'd1;
        wr_data = 32'h12345678;
        #10;

        // Escribir x2
        wr_index = 5'd2;
        wr_data = 32'hAAAAAAAA;
        #10;

        // Escribir x10
        wr_index = 5'd10;
        wr_data = 32'hDEADBEEF;
        #10;

        // Deshabilitar escritura
        wr_en = 0;

        // Leer x1 y x2
        rd_index1 = 5'd1;
        rd_index2 = 5'd2;
        #10;

        // Leer x10 y x0
        rd_index1 = 5'd10;
        rd_index2 = 5'd0;
        #10;

        // Intentar escribir en x0
        wr_en = 1;
        wr_index = 5'd0;
        wr_data = 32'hFFFFFFFF;
        #10;

        wr_en = 0;

        // Verificar que x0 sigue siendo cero
        rd_index1 = 5'd0;
        rd_index2 = 5'd1;
        #10;

        $finish;

    end

endmodule