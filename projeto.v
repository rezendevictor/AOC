module main;

    reg clk, pc;
    wire [7:0] comando;  
    wire operation_saida, saidaEndBeq, norJumpBeq;
    wire opcode, le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, Reset;
    wire [1:0] decideRegSalto;
    wire [7:0] resultadoEnd, ResultadoEndMaisSalto, enderecoFinal;
    wire[7:0] endereco_atual, saidaExtensor, saidaMuxUla;
    wire[2:0] saidaMuxRegSalto;
    wire[7:0] dado_escrito, valor_regd, valor_dado1, valor_dado2, endereco, valorEscrito, valorEndSalto, result, dadoMem, endSaltoFim;
    wire [3:0] funct;
///----------------------------------- Simulacao 


    initial begin // Dados de teste
        clk = 0;
        pcContador.counter = 0;
    end

    always #1 clk = ~clk; // CLOCK COM PERIODO 20

    initial begin
	  forever
	  begin
        
	   $display("Status do processador");
       $display("PC=%d", endereco_atual);
       $display("PC-1=%d", enderecoFinal);
	   $display("Clock = %d",clk);
	   $display("Estagio : %d", pcContador.counter);
       $display("Memoria 1: %d", valor_dado1);
       $display("Memoria 2: %d", valor_dado2);
       $display("Instrução processada: %d", comando);
	   $display("-------------------------------------------------");
	   #1;
          end
        end

/// ----------------------------------------------------------------

// -------------------- BLOCO INCIAL 

    assign enderecoFinal = 0;
    assign endereco_atual = 0;

    pc_counter pcContador(clk, enderecoFinal, endereco_atual);

    memoria_instrucoes instrucao(endereco_atual, clk, comando, Reset);
    
    assign funct= {comando[7:6],comando[2:0]};
    
    unidadecontrole controle (funct, le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, decideRegSalto, clk, Reset);
    
    mux3Entradas salto(decideRegSalto, 3'b001, 3'b010, 3'b011, saidaMuxRegSalto);
    
    banco_registradores regs(clk ,saidaMuxRegSalto, comando[5:3], comando[2:0], comando [5:3], dado_escrito, regWrite, valor_regd, valor_dado1, valor_dado2, valorEndSalto );
    
    extensorSinal extende(comando[2:0],saidaExtensor);
    
    mux2Entradas muxUla(origem, valor_dado2, saidaExtensor, saidaMuxUla);
    
    ULA operacaoDados1_mux(valor_dado1,saidaMuxUla, opAlu , operation_saida,result );
    
    memoria_dado dados(valor_dado1,reset, valorEndSalto, clk, leMem, escreveMem, dadoMem);
    
    mux2Entradas muxDecideMemUla(mem_reg, result, dadoMem, dado_escrito);
    
    mux2Entradas muxDecideEndSalto(pulo,valorEndSalto, valor_dado1,endSaltoFim);
    
    ULA operacaoEnderecoAtualMaisUM (endereco_atual, 8'b00000001, 1'b0 , operation_saida, resultadoEnd);
    
    ULA operacaoEnderecoAtualMaisMux (resultadoEnd, endSaltoFim, 1'b0 , operation_saida, ResultadoEndMaisSalto);
    
    AND andEnd( operation_saida, beq, saidaAndBeq);
    
    assign norJumpBeq = ~( saidaAndBeq | jump);
    
    mux2Entradas muxDecideJumpBeq(norJumpBeq, resultadoEnd, ResultadoEndMaisSalto, enderecoFinal);
    
    
   // anda_memoria andando_mem (endereco_atual, saida_mux_pulo, jump, beq, saida_ula, endereco_final);




// -------------------- BLOCO INCIAL FIM ---------//

endmodule

module memoria_instrucoes(counter, clock, instrucao_saida, reset);
    input clock, reset; // 
    input [7:0] counter; //vem do módulo pc
    output [7:0] instrucao_saida; // a instrucao que vai sair
    reg [7:0] memoria_instrucoes [60:0];// um vetor para guardar

    always @(posedge clock)
    begin
    if (reset)
            case(counter)
                8'b00000000: memoria_instrucoes[counter] <= 8'b10011000;
                8'b00000001: memoria_instrucoes[counter] <= 8'b11101000;
                8'b00000010: memoria_instrucoes[counter] <= 8'b10011001; 
                8'b00000011: memoria_instrucoes[counter] <= 8'b11001000; 
                8'b00000100: memoria_instrucoes[counter] <= 8'b10011001; 
                8'b00000101: memoria_instrucoes[counter] <= 8'b11111000; 
                8'b00000110: memoria_instrucoes[counter] <= 8'b10110001; 
                8'b00000111: memoria_instrucoes[counter] <= 8'b00101000; 
                8'b00001000: memoria_instrucoes[counter] <= 8'b00101110;
                8'b00001001: memoria_instrucoes[counter] <= 8'b10101110; 
                8'b00001010: memoria_instrucoes[counter] <= 8'b11111010; 
                8'b00001011: memoria_instrucoes[counter] <= 8'b11000011;
                default: memoria_instrucoes[counter] <= 8'b11000011; 
            endcase
        end
    assign instrucao_saida = memoria_instrucoes[counter];
endmodule

module pc_counter (clock, endereco_atual, endereco); 
    input clock;
    input [7:0] endereco_atual;
    reg [7:0] counter;
    output [7:0] endereco;

    initial begin
           #1 counter = 8'b00000000;
    end
    
    always @(posedge clock) begin
            counter = endereco_atual + 1;

    end
    assign endereco = counter;
    
endmodule

 module mux3Entradas(comando, entrada1, entrada2,entrada3, saida);
    input [2:0] entrada1,entrada2, entrada3;
    input wire [1:0] comando;
    output reg [2:0] saida;
    
    always @(comando) begin
    
        if(comando == 2'b00) begin
            saida = entrada1;
        end
    
        else if(comando == 2'b01 ) begin
         saida = entrada2;
        end
        
         else if(comando == 2'b11 ) begin
         saida = entrada3;
        end
    end
 endmodule
    
module mux2Entradas(comando, entrada1, entrada2, saida);
    input [7:0] entrada1,entrada2;
    input wire comando;
    output reg [7:0] saida;
    
    always @(comando) begin
    
        if(comando == 0) begin
            saida = entrada1;
        end
        else begin
         saida = entrada2;
        end
    end
 endmodule
 module unidadecontrole(opcode, le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, decideRegSalto, clock, Reset);

    input [3:0] opcode;
    input clock;
    output reg le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, Reset;
    output reg [1:0] decideRegSalto;

    always @ (posedge clock) begin
        casez(opcode)

            4'b1100: begin le_mem=1'b1; escreve_mem=1'b0; origem=1'b0;
            regEscreve = 1'b1; jump=1'b0; decideRegSalto= 2'b00; pulo=1'b1; regEscreve=1'b1; beq=1'b0;
            opAlu=1'b0; Reset=1'b1; hl=1'b0;
            end


            4'b1101: begin le_mem=1'b0; escreve_mem=1'b1; origem=1'b1;
            regEscreve = 1'b0; jump=1'b0; decideRegSalto= 2'b00; pulo=1'b0; regEscreve=1'b0; beq=1'b0;
            opAlu=1'b0; Reset=1'b1; hl=1'b0;
            end


            4'b00zz: begin le_mem=1'b0; escreve_mem=1'b0; origem=1'b0;
            regEscreve = 1'b0; jump=1'b0; decideRegSalto= 2'b10; pulo=1'b1; regEscreve=1'b0; beq=1'b1;
            opAlu=1'b0; Reset=1'b1; hl=1'b0;
            end


            4'b10zz: begin le_mem=1'b0; escreve_mem=1'b0; origem=1'b1;
            regEscreve = 1'b1; jump=1'b0; decideRegSalto= 2'b00; pulo=1'b0; regEscreve=1'b1; beq=1'b0;
            opAlu=1'b1; Reset=1'b1; hl=1'b0;
            end


            4'b1110: begin le_mem=1'b0; escreve_mem=1'b0; origem=1'b0;
            regEscreve = 1'b0; jump=1'b1; decideRegSalto= 2'b00; pulo=1'b1; regEscreve=1'b0; beq=1'b0;
            opAlu=1'b0; Reset=1'b1; hl=1'b0;
            end


            4'b1111: begin le_mem=1'b0; escreve_mem=1'b0; origem=1'b0;
            regEscreve = 1'b0; jump=1'b0; decideRegSalto= 2'b00; pulo=1'b0; regEscreve=1'b0; beq=1'b0;
            opAlu=1'b0; Reset=1'b0; hl=1'b1;
            end
        endcase
    end
endmodule
module banco_registradores
(clock,reg_endSalto, endereco_regd, endereco_reg1, endereco_reg2, dado_escrito,regWrite, valor_regd, valor_reg1, valor_reg2, valor_endSalto );
    input clock, regWrite;
    input [2:0] endereco_regd;
    input [2:0] endereco_reg1;
    input [2:0] endereco_reg2;
    input [2:0] reg_endSalto;
    input [7:0] dado_escrito;
    output [7:0] valor_regd;
    output [7:0] valor_reg1;
    output [7:0] valor_reg2;
    output [7:0] valor_endSalto;
    reg [7:0] registradores[7:0];

    initial begin
        registradores[3'b101] = 8'b00000001;
        registradores[3'b110] = 8'b00000000;
    end

    always @(posedge clock)
        begin
            if(regWrite)
                registradores[endereco_regd] <= dado_escrito; 
        end

    assign valor_regd = registradores[endereco_regd];
    assign valor_reg1 = registradores[endereco_reg1];
    assign valor_reg2 = registradores[endereco_reg2];
    assign valor_endSalto = registradores[reg_endSalto];

endmodule
 module extensorSinal(entrada1, saida);
    input [2:0] entrada1;
    output [7:0] saida;
    
    assign saida = {4'b0000,entrada1};
    
 endmodule
 module ULA(number1,number2, operation , operation_saida, result);
    input [7:0] number1,number2;
    input wire operation;
    output reg [7:0] result;
    output operation_saida;

    assign operation_saida = number1-number2;
    
    always @(operation) begin
        
        if(operation == 0) begin
             result = number1 + number2;
             
        end
        else begin
         result = number1 - number2;
        end
    end
    
endmodule
module memoria_dado(data_in,reset, endMem, clock, leMem, escreveMem,data_out);
     input [7:0] endMem;
     input [7:0] data_in;
     input leMem, escreveMem, reset;
     input clock;
     output reg [7:0] data_out;
     reg [7:0] memory [50:0];

    always @(posedge clock) begin
        if (leMem && reset)
            data_out <= memory[endMem] ;
        if (escreveMem && reset)
			memory[endMem] <= data_in;
    end

    always @(clock) begin
     
	end
    
endmodule

 module AND( entrada1, entrada2, saida);
    input  entrada1,entrada2;
    output saida;
    assign saida = entrada1 && entrada2;
 endmodule