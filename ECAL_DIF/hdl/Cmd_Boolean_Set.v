`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 11:43:32
// Design Name: 
// Module Name: Cmd_Boolean_Set
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cmd_Boolean_Set(
    input Clk_In,
    input Rst_N,
    input [16:1] Cmd,
    input Cmd_En,
    output reg Output_Valid_Sig
    );

	parameter [16:1] EFFECT_1_CMD = 16'h0;
	parameter [16:1] EFFECT_0_CMD = 16'h1;
	parameter       DEFAULT_VALUE = 1'b1;


	always @ (posedge Clk_In or negedge Rst_N )
	begin
		if(~Rst_N)
		begin
			Output_Valid_Sig <= DEFAULT_VALUE;
		end		
		else if (Cmd_En && Cmd  == EFFECT_0_CMD)
		begin
			Output_Valid_Sig <= 1'b0;
		end		
		else if (Cmd_En && Cmd  == EFFECT_1_CMD)
		begin
			Output_Valid_Sig <= 1'b1;
		end		
		else
			Output_Valid_Sig <= Output_Valid_Sig;
	end		

endmodule
