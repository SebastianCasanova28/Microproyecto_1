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
  
      //Valor inmediato
  wire [31:0] imm;
  wire imm_valid;
  
  //Señales de control de la CU
  wire wr_en;
  wire [10:0] dec_bits;
  wire [9:0] dec_bits2;
  
  wire is_add;
  wire is_sub;
  wire is_sll;
  wire is_xor;
  wire is_or;
  wire is_and;

  wire is_addi;
  wire is_andi;
  wire is_ori;
  wire is_xori;

  wire is_i_instr;
  wire is_r_instr;
  wire is_s_instr;
  wire is_b_instr;
  wire is_u_instr;
  wire is_j_instr;
  wire is_valid;

  assign is_u_instr = (opcode[6:2] == 5'b00101) || (opcode[6:2] == 5'b01101);
  assign is_r_instr = (opcode[6:2] == 5'b01100);
  assign is_i_instr = (opcode[6:2] == 5'b00100);
  assign is_s_instr = (opcode[6:2] == 5'b01000);
  assign is_b_instr = (opcode[6:2] == 5'b11000);
  assign is_j_instr = (opcode[6:2] == 5'b11011);
  assign is_valid = (opcode[1:0] == 2'b11) &&
                  (is_r_instr ||
                   is_i_instr ||
                   is_s_instr ||
                   is_b_instr ||
                   is_u_instr ||
                   is_j_instr);




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
        (is_add | is_addi) ? 3'b000 :
        is_sub             ? 3'b001 :
        is_sll             ? 3'b010 :
        (is_xor | is_xori) ? 3'b011 :
        (is_or  | is_ori)  ? 3'b100 :
        (is_and | is_andi) ? 3'b101 :
                            3'b000
    ) //Señal que define la operación

);
  
  //Cableado entre el RF y la ALU
  assign alu_a = src1_value;
  assign alu_b = imm_valid ? imm : src2_value;
  
  //Cableado de la Control Unit (UC)
  //--------------------------------


  // Generación del valor inmediato

  assign imm[31:0] = is_i_instr ? { {21{IR[31]}}, IR[30:20] } :
                     is_s_instr ? { {21{IR[31]}}, IR[30:25], IR[11:7] } :
                     is_b_instr ? { {20{IR[31]}}, IR[7], IR[30:25],
                                    IR[11:8], 1'b0 } :
                     is_u_instr ? { IR[31:12], 12'b0 } :
                     is_j_instr ? { {12{IR[31]}}, IR[19:12], IR[20],
                                    IR[30:21], 1'b0 } :
                                  32'b0;
  
  assign imm_valid = is_i_instr |
                   is_s_instr |
                   is_b_instr |
                   is_u_instr |
                   is_j_instr;
    

  //Señales de control

  assign wr_en = is_r_instr |
               is_i_instr |
               is_u_instr |
               is_j_instr;

  assign dec_bits = {funct7[5], funct3, opcode};
  assign is_add = (dec_bits == 11'b0_000_0110011);
  assign is_sub = (dec_bits == 11'b1_000_0110011);
  assign is_sll = (dec_bits == 11'b0_001_0110011);
  assign is_xor = (dec_bits == 11'b0_100_0110011);
  assign is_or  = (dec_bits == 11'b0_110_0110011);
  assign is_and = (dec_bits == 11'b0_111_0110011);
  
  assign dec_bits2 = {funct3, opcode};
  assign is_addi = (dec_bits2 == 10'b000_0010011);
  assign is_andi = (dec_bits2 == 10'b111_0010011);
  assign is_ori  = (dec_bits2 == 10'b110_0010011);
  assign is_xori = (dec_bits2 == 10'b100_0010011);
  
endmodule
