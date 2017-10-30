`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 15:51:43
// Design Name: 
// Module Name: Test_Cmd_Set_N_Bits_Value
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


module Test_Cmd_Set_N_Bits_Value(

    );


	reg Clk_In;
	reg Rst_N;
	reg [16:1] Cmd;
	reg Cmd_En;
	wire [8:1] Output_Final;
	wire [4:1] Sig_Output;
	initial
	begin
		Clk_In = 1'b0;
		Rst_N = 1'b0;
		Cmd_En = 1'b0;
		Cmd = 16'h0;
		#200
		Rst_N = 1'b1;
		Cmd_En = 1'b1;
		Cmd = 16'he123;
		#100
		Cmd = 16'hd12a;
		#500
		Cmd = 16'hd122;
	end		

	always @ (*)
	begin
		#12.5
		Clk_In <= ~Clk_In;
	end	

 Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'hd12),
 .DEFAULT_VALUE(4'd0))
	Cmd_Set_N_Bits_Value_Inst(
    .Clk_In(Clk_In),
    .Rst_N(Rst_N),
    .Cmd_In(Cmd),
    .Cmd_En(Cmd_En),
    .Output_Valid_Sig(Sig_Output)
    );	
	 Hex_2_ASCII Hex_2_ASCII_Inst(
    .In_Hex(Sig_Output),//4bit Hex
    .Out_ASCII(Output_Final)//8bit ASCII
    );
endmodule
