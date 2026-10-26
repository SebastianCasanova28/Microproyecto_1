module riscv (
	input clk,		//Reloj del procesador
	input rst,		//Reset del procesador
	input [31:0] instr	//Instrucción de entrada
	);
  
  reg [31:0] IR;	//Registro de instrucción
  always @(posedge clk) begin
	IR <= instr;
  end
  
  // Señales del registro de instrucción (IR)
  wire [6:0] funct7;
  wire [4:0] rs2;
  wire [4:0] rs1;
  wire [2:0] funct3;
  wire [4:0] rd;
  wire [6:0] opcode;
  
  //Extracción de los campos del registro de instrucción
  assign funct7 = IR[31:25];
  assign rs2 = IR[24:20];
  assign rs1 = IR[19:15];
  assign funct3 = IR[14:12];
  assign rd = IR[11:7];
  assign opcode = IR[6:0];
   
  //Salidas del register file
  wire [31:0] src1_value;
  wire [31:0] src2_value;  
  
  //Operandos de entrada a la alu
  wire [31:0] alu_a;
  wire [31:0] alu_b;
  
  //Salida de la ALU
  wire [31:0] alu_out;
  
  //Señales de control de la CU
  wire wr_en;
  wire [10:0] dec_bits;
  wire is_add;
  wire is_sub;
  wire is_sll;
  wire is_xor;
  wire is_or;
  wire is_and;


  //Instanciación del RF
  RegisterFile rf (
    .clk(clk),
    .wr_en(wr_en), 
    .wr_index(rd),	
    .wr_data(alu_out), 
    .rd_index1(rs1),
    .rd_data1( src1_value ),	
    .rd_index2(rs2),	
    .rd_data2( src2_value )	
  );

  //Instanciación de la ALU 
  alu rv_alu (
    .A( alu_a ),
    .B( alu_b ), 
    .ALU_out( alu_out ), 
    .op(
        is_add ? 3'b000 :
        is_sub ? 3'b001 :
        is_sll ? 3'b010 :
        is_xor ? 3'b011 :
        is_or  ? 3'b100 :
        is_and ? 3'b101 :
                 3'b000
    )  //Señal que define la operación

);
  
  //Cableado entre el RF y la ALU
  assign alu_a = src1_value;
  assign alu_b = src2_value;
  
  //... aquí la conexión entre las señales srcN_value y alu_N y alu_out usando directivas assign

  //Cableado de la Control Unit (UC)
  //--------------------------------
  
  //Señales de control
  assign wr_en = is_add |
               is_sub |
               is_sll |
               is_xor |
               is_or  |
               is_and;

  assign dec_bits = {funct7[5], funct3, opcode};
  assign is_add = (dec_bits == 11'b0_000_0110011);
  assign is_sub = (dec_bits == 11'b1_000_0110011);
  assign is_sll = (dec_bits == 11'b0_001_0110011);
  assign is_xor = (dec_bits == 11'b0_100_0110011);
  assign is_or  = (dec_bits == 11'b0_110_0110011);
  assign is_and = (dec_bits == 11'b0_111_0110011);
  
endmodule
