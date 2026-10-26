module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0] op,
    output wire [31:0] ALU_out
);

    wire [4:0] shamt; 
    wire [63:0] a_ext; 
    wire [31:0] sltu_result; 
    wire [31:0] slt_result; 

    //Valor del shift 
    assign shamt = B[4:0];
    
    //Extensión de signo de la entrada a para 64bits  
    assign a_ext = { {32{A[31]}}, A }; 

    //Valor obtenido por set if less than unsigned (sltu) 
    assign sltu_result = {31'b0, A < B}; 

    //Valor obtenido por set if less than (signed) 
    assign slt_result = (A[31]==B[31]) ? sltu_result : {31'b0, A[31]};

    assign ALU_out =
        (op == 4'b0000) ? A + B                    : // ADD
        (op == 4'b0001) ? A - B                    : // SUB
        (op == 4'b0010) ? A << shamt               : // SLL
        (op == 4'b0011) ? A ^ B                    : // XOR
        (op == 4'b0100) ? A | B                    : // OR
        (op == 4'b0101) ? A & B                    : // AND
        (op == 4'b0110) ? A >> shamt               : // SRL
        (op == 4'b0111) ? a_ext >> shamt           : // SRA
        (op == 4'b1000) ? slt_result               : // SLT
        (op == 4'b1001) ? sltu_result              : // SLTU
                        32'b0;

endmodule