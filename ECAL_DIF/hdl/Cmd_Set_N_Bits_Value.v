`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 15:36:39
// Design Name: 
// Module Name: Cmd_Set_N_Bits_Value
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


module Cmd_Set_N_Bits_Value(
    input Clk_In,
    input Rst_N,
    input [16:1] Cmd_In,
    input Cmd_En,
    output reg [LENGTH_VALUE:1] Output_Valid_Sig
    );

	parameter [4:1] LENGTH_CMD = 4'd4;
	parameter [4:1] LENGTH_VALUE = 4'd12; 
	parameter [LENGTH_CMD:1] EFFECT_CMD = 0;
	parameter [LENGTH_VALUE:1] DEFAULT_VALUE = 0;

	wire [LENGTH_CMD:1] Effect_Cmd;
	wire [LENGTH_VALUE:1] Effect_Value;
	assign Effect_Cmd = Cmd_In[16:17-LENGTH_CMD];	
	assign Effect_Value = Cmd_In[LENGTH_VALUE:1];

	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Output_Valid_Sig <= DEFAULT_VALUE;
		end		
		else if (Cmd_En && Effect_Cmd == EFFECT_CMD)
		begin
			Output_Valid_Sig <= Effect_Value;
		end		
		else
		begin
			Output_Valid_Sig <= Output_Valid_Sig;
		end		
	end		
endmodule
