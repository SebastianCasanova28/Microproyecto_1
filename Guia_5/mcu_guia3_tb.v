`timescale 1ns/1ps

//Test bench para mcu_guia3.v

module tb_mcu;
  
  // Señales de prueba
  reg  clk;
  reg  rst;
  
  // Instancia del microcontrolador
  mcu mcuuq (
    .rst(rst),
    .clk(clk)
  );

  integer i;
  // Bloque inicial: aplica estímulos
  initial begin
    // Configurar la generación de archivos de volcado
    $dumpfile("tb_mcu.vcd");
    $dumpvars(0, tb_mcu);
	  for(i=0; i<32; i=i+1) $dumpvars(0, mcuuq.cpu.rf.registers[i]);
    
    #0;  clk = 0;
		 rst = 1;
	
    #9;  rst = 0; 
    
  #240;  //Termina después de 60 ciclos de reloj

	#16;
    // Fin de la simulación
    $finish;
  end
  
  always
    begin
        #2 clk=!clk;
    end

endmodule
