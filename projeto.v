module projeto;
    reg [7:0] digito_a_ser_dividido;
    reg clk,pc;
    reg [7:0] comando;  
    wire opcode, le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, clock, Reset;
    wire [2:0] decideRegSalto;
    wire[7:0] endereco_atual;


// -------------------- BLOCO INCIAL 

    initial begin // Dados de teste
        clk = 0;
    end

    //always #20 clk = ~clk; // CLOCK COM PERIODO 20
    
    initial begin 
        $monitor("Time=%0d, clk = %0d, digito_a_ser_dividido=%d ,",$time, clk, digito_a_ser_dividido);
    end

    /*
    unidadecontrole controle (comando[7:4], le_mem, escreve_mem, jump, beq, pulo, mem_reg, hl, origem, opAlu, regEscreve, decideRegSalto, clock, Reset);

    pre_registrador pre_reg (instrucao, dado_escrito, sinalControleIndef, dado1 , dado2, endereco);

    post_registrador post_reg (dado1, dado2, dois_a_zero_instrucao, endereco, origem, pulo, Opalu, mem_reg, saida_mux_pulo, saida_ula);
    
    anda_memoria andando_mem (endereco_atual, saida_mux_pulo, jump, beq, saida_ula, endereco_final);
    */



// -------------------- BLOCO INCIAL FIM 

endmodule
/*
module anda_memoria(endereco_atual, saida_mux_pulo, jump, beq, saida_ula ,endereco_final);
    input jump, beq;
    input [7:0] endereco_atual, saida_mux_pulo;
    wire [7:0] novo_endereco, novo_endereco_mais_mux;
    output [7:0] endereco_final, saida_ula; 
    reg [7:0] add_1_Step = 8'b00000001;
    wire soma = 1'b0;

     ULA somador(endereco_atual,add_1_Step , soma, novo_endereco);
     ULA soma_novo_endereco(novo_endereco, saida_mux_pulo ,soma, novo_endereco_mais_mux);

    wire saida1and, saida2and;

     AND primeiro_and(beq, saida_ula, saida1and); // CONFIRMAR SE È UM AND MESMO
     AND segundo_and(jump, saida1and, saida2and);

     mux2Entradas muxFinal(saida2and, novo_endereco, novo_endereco_mais_mux, endereco_final);

endmodule

module pre_registrador(instrucao, dado_escrito, sinalControleIndef, dado1 , dado2, endereco);
    input [7:0] instrucao, dado_escrito;
    input [1:0] sinalControleIndef;
    input clock;
    output [7:0] endereco, dado1,dado2;
    wire [7:0] saida_mux_sinalControle;

    

     mux3Entradas muxSinalControle(sinalControleIndef, 3'b011, 3'b010, 3'b001, saida_mux_sinalControle);


    //banco_reg banco_registradores(clock,)


    /*
    000 registrador 0 : $zero
    001 registrador com endereço para o qual beq desvia : $beq
    010 registrador com o endereço usado ao fazer um sw : $sw
    011 registrador com o endereço usado ao fazer um lw : $lw
    100 registrador com o resultado da comparação feita pelo SLT : $slt
    101 registrador livre $a0
    110 registrador livre $a1
    111 registrador livre $a2
    

endmodule
*/
module banco_registradores
(clock,reg_endSalto, endereco_regd, endereco_reg1, endereco_reg2, dado_escrito, valor_regd, valor_reg1, valor_reg2, valor_endSalto, regWrite);
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
/*
module post_registrador(dado1, dado2, dois_a_zero_instrucao, endereco, origem, pulo, Opalu, mem_reg, saida_mux_pulo, saida_ula );
    input wire origem, pulo , mem_reg, Opalu;
    input [7:0] endereco, dado1, dado2;
    input [2:0] dois_a_zero_instrucao;

    wire [7:0] sinal_extendido, resposta_mux_origem ;

    output [7:0] saida_mux_pulo, saida_ula; 


    extensorSinal extensor(dois_a_zero_instrucao, sinal_extendido);

    mux2Entradas muxOrigem(origem, dado2, sinal_extendido, resposta_mux_origem);
    
    mux2Entradas muxPulo(pulo, endereco, dado1, saida_mux_pulo);

    ULA somador(resposta_mux_origem, dado1 , Opalu , saida_ula);

    /// LOGICA DA MEMORIA DE DADOS 

    wire [7:0] resposta_mem_dados;

    
    mux2Entradas muxMemReg(mem_reg, saida_ula, resposta_mem_dados, saida_mux_pulo);   

endmodule
*/

module ULA(number1,number2,operation,result);
    input [7:0] number1,number2;
    input wire operation;
    output reg [7:0] result;
    
    always @(operation) begin
        
        if(operation == 0) begin
             result = number1 + number2;
             
        end
        else begin
         result = number1 - number2;
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


 module mux3Entradas(comando, entrada1, entrada2,entrada3, saida);
    input [7:0] entrada1,entrada2, entrada3;
    input wire [1:0] comando;
    output reg [7:0] saida;
    
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



 module extensorSinal(entrada1, saida);
    input [3:0] entrada1;
    output [7:0] saida;
    
    assign saida = {4'b0000,entrada1};
    
 endmodule



 
 module AND( entrada1, entrada2, saida);
    input  entrada1,entrada2;
    output saida;
    assign saida = entrada1 && entrada2;
 endmodule


module pc_counter (clock, endereco); 
    input clock;
    reg [7:0] counter;
    output [7:0] endereco;
    initial begin
            counter = 8'b00000000;
        end
    
    always @(negedge clock) begin
            counter = counter + 8'b00000001;
    end
    assign endereco = counter;
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
