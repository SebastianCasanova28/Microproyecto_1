module riscv (
	input clk,		//Reloj del procesador
	input rst,		//Reset del procesador
	input [31:0] instr,	//Instrucción de entrada
	
  output [31:0] iaddr,        //Dirección hacia IMEM
  output [31:0] daddr,        //Dirección hacia DMEM
  input  [31:0] ddata_in,     //Datos recibidos desde DMEM
  output [31:0] ddata_out,    //Datos enviados hacia DMEM
  output dwr_en,              //Habilitación de escritura
  output drd_en               //Habilitación de lectura

  );
  
  //Contador de programa
  reg [31:0] pc;
  assign iaddr = pc;

  //Estados del ciclo de instrucción
  reg state_fetch, state_decode, state_execute, state_execute2;

  always @(negedge clk) begin
      if (rst) begin
          state_fetch   <= 1;
          state_decode  <= 0;
          state_execute <= 0;
          state_execute2 <= 0;
      end
      else begin
            state_fetch   <= state_execute2;
            state_decode  <= state_fetch;
            state_execute <= state_decode;
            state_execute2 <= state_execute;
      end
  end

  //Registro de instrucción
  reg [31:0] IR;

  always @(posedge clk) begin
      if (rst)
          IR <= 32'd0;
      else if (state_fetch)
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
  
  //Dato que se escribirá en el Register File
  wire [31:0] rf_wr_data;

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

  wire is_srl;
  wire is_sra;
  wire is_slt;
  wire is_sltu;
  wire is_lui;
  wire is_auipc;

  wire is_addi;
  wire is_andi;
  wire is_ori;
  wire is_xori;

  wire is_beq;
  wire is_bne;
  wire is_blt;
  wire is_bge;
  wire is_bltu;
  wire is_bgeu;

  wire is_i_instr;
  wire is_r_instr;
  wire is_s_instr;
  wire is_b_instr;
  wire is_u_instr;
  wire is_j_instr;
  wire is_valid;

  wire is_load;

  wire taken_br;

  wire [31:0] pc_plus4;
  wire [31:0] br_tgt_pc;

  wire [31:0] next_pc;

  assign is_u_instr = (opcode[6:2] == 5'b00101) || (opcode[6:2] == 5'b01101);
  assign is_r_instr = (opcode[6:2] == 5'b01100);
  assign is_i_instr = (opcode[6:2] == 5'b00100);
  assign is_s_instr = (opcode[6:2] == 5'b01000);
  assign is_b_instr = (opcode[6:2] == 5'b11000);
  assign is_j_instr = (opcode[6:2] == 5'b11011);
  
  assign is_load = (opcode == 7'b0000011) &&
                    ((funct3 == 3'b000) ||
                    (funct3 == 3'b001) ||
                    (funct3 == 3'b010) ||
                    (funct3 == 3'b100) ||
                    (funct3 == 3'b101));

  assign is_valid = (opcode[1:0] == 2'b11) &&
                  (is_r_instr ||
                   is_i_instr ||
                   is_s_instr ||
                   is_b_instr ||
                   is_u_instr ||
                   is_j_instr ||
                   is_load);
  


  assign rf_wr_data = is_load ? ddata_in : alu_out;



  //Instanciación del RF
  RegisterFile rf (
    .clk(clk),
    .wr_en(wr_en & state_execute2), 
    .wr_index(rd),	
    .wr_data(rf_wr_data), 
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
        (is_add | is_addi | is_lui | is_auipc | is_load | is_s_instr) ? 4'b0000 :
        is_sub                                  ? 4'b0001 :
        is_sll                                  ? 4'b0010 :
        (is_xor | is_xori)                      ? 4'b0011 :
        (is_or  | is_ori)                       ? 4'b0100 :
        (is_and | is_andi)                      ? 4'b0101 :
        is_srl                                  ? 4'b0110 :
        is_sra                                  ? 4'b0111 :
        is_slt                                  ? 4'b1000 :
        is_sltu                                 ? 4'b1001 :
                                                4'b0000
    ) //Señal que define la operación

);
  
  //Cableado entre el RF y la ALU
  assign alu_a = is_lui   ? 32'b0 :
               is_auipc ? pc     :
                          src1_value;

  assign alu_b = imm_valid ? imm : src2_value;

  // Dirección hacia la memoria de datos
  assign daddr = alu_out;
  
  // Dato enviado hacia DMEM en instrucciones STORE
  assign ddata_out = src2_value;

  // Habilitación de escritura en DMEM
  assign dwr_en = is_s_instr &&
                (state_execute | state_execute2);
  
  // Habilitación de lectura en DMEM
  assign drd_en = is_load &&
                (state_execute | state_execute2);



  //Cableado de la Control Unit (UC)
  //--------------------------------


  // Generación del valor inmediato

  assign imm[31:0] = (is_i_instr | is_load) ?
                     { {21{IR[31]}}, IR[30:20] } :
                   is_s_instr ?
                     { {21{IR[31]}}, IR[30:25], IR[11:7] } :
                   is_b_instr ?
                     { {20{IR[31]}}, IR[7], IR[30:25],
                       IR[11:8], 1'b0 } :
                   is_u_instr ?
                     { IR[31:12], 12'b0 } :
                   is_j_instr ?
                     { {12{IR[31]}}, IR[19:12], IR[20],
                       IR[30:21], 1'b0 } :
                     32'b0;
  
  assign imm_valid = is_i_instr |
                   is_load |
                   is_s_instr |
                   is_b_instr |
                   is_u_instr |
                   is_j_instr;
    

  //Señales de control

  assign wr_en = is_r_instr |
               is_i_instr |
               is_load |
               is_u_instr |
               is_j_instr;


  assign dec_bits = {funct7[5], funct3, opcode};

  assign is_add = (dec_bits == 11'b0_000_0110011);
  assign is_sub = (dec_bits == 11'b1_000_0110011);

  assign is_sll = (dec_bits == 11'b0_001_0110011) ||
                    (dec_bits == 11'b0_001_0010011);

  assign is_srl = (dec_bits == 11'b0_101_0110011) ||
                    (dec_bits == 11'b0_101_0010011);

  assign is_sra = (dec_bits == 11'b1_101_0110011) ||
                    (dec_bits == 11'b1_101_0010011);

  assign is_xor = (dec_bits == 11'b0_100_0110011);
  assign is_or  = (dec_bits == 11'b0_110_0110011);
  assign is_and = (dec_bits == 11'b0_111_0110011);

  
  assign dec_bits2 = {funct3, opcode};
  assign is_addi = (dec_bits2 == 10'b000_0010011);
  assign is_andi = (dec_bits2 == 10'b111_0010011);
  assign is_ori  = (dec_bits2 == 10'b110_0010011);
  assign is_xori = (dec_bits2 == 10'b100_0010011);
  
  assign is_slt = (dec_bits == 11'b0_010_0110011) ||
                (dec_bits2 == 10'b010_0010011);

  assign is_sltu = (dec_bits == 11'b0_011_0110011) ||
                 (dec_bits2 == 10'b011_0010011);
  
  assign is_lui   = (opcode == 7'b0110111);
  assign is_auipc = (opcode == 7'b0010111);


  // Decodificación de instrucciones tipo Branch
  assign is_beq  = is_b_instr && (funct3 == 3'b000);
  assign is_bne  = is_b_instr && (funct3 == 3'b001);
  assign is_blt  = is_b_instr && (funct3 == 3'b100);
  assign is_bge  = is_b_instr && (funct3 == 3'b101);
  assign is_bltu = is_b_instr && (funct3 == 3'b110);
  assign is_bgeu = is_b_instr && (funct3 == 3'b111);
  
  assign taken_br =
      is_beq  ? (src1_value == src2_value) :
      is_bne  ? (src1_value != src2_value) :
      is_blt  ? ((src1_value < src2_value) ^
                (src1_value[31] != src2_value[31])) :
      is_bge  ? ((src1_value >= src2_value) ^
                (src1_value[31] != src2_value[31])) :
      is_bltu ? (src1_value < src2_value) :
      is_bgeu ? (src1_value >= src2_value) :
                1'b0;
  
  assign pc_plus4   = pc + 32'd4;
  assign br_tgt_pc  = pc + imm;

  assign next_pc = (taken_br | is_j_instr) ? br_tgt_pc :
                                           pc_plus4;

  always @(posedge clk) begin
      if (rst)
          pc <= 32'd0;
      else if (state_execute)
          pc <= next_pc;
  end
  
endmodule
