module RegisterFile(

    input wire clk,

    input wire wr_en,
    input wire [31:0] wr_data,
    input wire [4:0] wr_index,

    input wire [4:0] rd_index1,
    input wire [4:0] rd_index2,

    output wire [31:0] rd_data1,
    output wire [31:0] rd_data2

);

    // Banco de 32 registros de 32 bits
    reg [31:0] registers [31:0];

    integer i;

    // Inicialización (solo para simulación)
    initial begin
        for(i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    //---------------------------------------------------------
    // Escritura síncrona
    //---------------------------------------------------------
    always @(posedge clk) begin

        // x0 siempre permanece en cero
        registers[0] <= 32'b0;

        if (wr_en && (wr_index != 5'd0))
            registers[wr_index] <= wr_data;

    end

    //---------------------------------------------------------
    // Lecturas combinacionales
    //---------------------------------------------------------
    assign rd_data1 = (rd_index1 == 5'd0) ? 32'b0 : registers[rd_index1];
    assign rd_data2 = (rd_index2 == 5'd0) ? 32'b0 : registers[rd_index2];

endmodule