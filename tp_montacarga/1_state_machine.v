//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:27:37 11/25/2021 
// Design Name: 
// Module Name:    mef_clave_3bits 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mef_clave_3bits(
    input [3:0] hex_digit,
    input Clock,
	 input Reset,
    output reg enable_mc,
    output reg [3:0] out_led_states
    );

	reg [1:0] state_clave, next_state_clave;

	parameter S0 = 2'b00; //estado de reposo.
	parameter S1 = 2'b01; //estado primer digito correcto.
	parameter S2 = 2'b10; //estado segundo digito correcto.
	parameter S3 = 2'b11; //estado tercer digito correcto.
	parameter digito_1 = 4'b0100; //un 4 en hex.
	parameter digito_2 = 4'b0110; //un 6 en hex.
	parameter digito_3 = 4'b1001; //un 9 en hex.

//-------------------------------------------------------------------------
	//registro de estados
	always @ (posedge Clock, posedge Reset)
		if(Reset) state_clave <= S0;
		else state_clave <= next_state_clave;

//-------------------------------------------------------------------------
	//logica del progreso de estados.
	always @ (*) //un Reset, Clock, o hex_digit.
		case (state_clave)
			S0: if(hex_digit == digito_1)
					next_state_clave <= S1;
				 else
					next_state_clave <= S0; //si mete cualquiera, se reinicia el candado.
					
			S1: if(hex_digit == digito_2)
					next_state_clave <= S2;
				 else if(hex_digit == 4'b1101) //cuando no se presiona nada llegan las D.
					next_state_clave <= S1; //se mantiene en el mismo estado
				 else
					next_state_clave <= S0; //si mete cualquiera, se reinicia el candado.
					
			S2: if(hex_digit == digito_3)
					next_state_clave <= S3;
				 else if(hex_digit == 4'b1101) //cuando no se presiona nada llegan las D.
					next_state_clave <= S2; //se mantiene en el mismo estado
				 else
					next_state_clave <= S0; //si mete verdura, se reinicia el candado.
					
			S3: if(!Reset)
					next_state_clave <= S0;
				 else
				 next_state_clave <= S3; //se queda desbloqueado llegue lo que llegue.
			
			default: next_state_clave <= S0; //no haria falta defol porqe estan todos los casos contemplados.
		endcase

//-------------------------------------------------------------------------
	//logica de salidas.
	always @(*) //un Reset, Clock, o hex_digit.
	begin
		if(state_clave == S3)
		begin
			enable_mc <= 1'b1; //habilita el montacargas.
			out_led_states <= 4'b0001; //prende el led de codigo completo y habilitado.
		end
		else if(state_clave == S2)
		begin
			enable_mc <= 1'b0; //deshabilita el montacargas.
			out_led_states <= 4'b0010; //prende el led de estado 2 y segundo codigo correcto.
		end
		else if(state_clave == S1)
		begin
			enable_mc <= 1'b0; //deshabilita el montacargas.
			out_led_states <= 4'b0100; //prende el led de estado 1 y primer codigo correcto.
		end
		else
		begin
			enable_mc <= 1'b0; //deshabilita el montacargas.
			out_led_states <= 4'b1000; //prende el led de estado 0 y sin codigo valido.
		end
	end
endmodule
