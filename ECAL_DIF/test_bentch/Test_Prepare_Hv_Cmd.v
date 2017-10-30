`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/24 15:00:50
// Design Name: 
// Module Name: Test_Prepare_Hv_Cmd
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


module Test_Prepare_Hv_Cmd(

    );

	localparam [56:1] HV_7BYTE = 56'h48_42_56_31_32_33_34; //"HBV1234"
	
	reg Clk_In;
	reg Rst_N;
	reg	Start_Cfg;
	reg Start_Start;


	initial
	begin
		Clk_In  = 1'b0;
		Rst_N = 1'b0;
		Start_Cfg = 1'b0;
		Start_Start = 1'b0;
		#200
		Rst_N = 1'b1;
		#50
		Start_Cfg = 1'b1;


	end		

	always @ (*)
	begin
		#12.5
		Clk_In <= ~Clk_In; //40MHz Clk
	end		

 Prepare_Hv_Cmd Prepare_Hv_Cmd_Inst(
     .Clk_In(Clk_In),//40MHz
     .Rst_N(Rst_N),
     .Start_Cfg(Start_Cfg),//Start Cfg Hv
		 .Start_Stop_Hv(Start_Start),//Start_Stop_Hv
     .In_Hv_7Byte(HV_7BYTE),//7byte value HBV_ _ _ _
     .In_Flag_Start(1'b0), //Set Start or Stop
     .Out_Cmd(),//to Hv_Control
     .Out_En()
    );
	endmodule
