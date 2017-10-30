`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 12:17:51
// Design Name: 
// Module Name: Test_Cmd_Boolean_Set
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


module Test_Cmd_Boolean_Set(

    );
	reg Clk_In;
	reg Rst_N;
	reg [16:1] Cmd;
	reg Cmd_En;


	initial
	begin
		Clk_In = 1'b0;
		Rst_N = 1'b0;
		Cmd_En = 1'b0;
		Cmd = 16'h0;
		#200
		Rst_N = 1'b1;
		Cmd_En = 1'b1;
		Cmd = 16'h55aa;
		#100
		Cmd = 16'd0;
		#500
		Cmd = 16'heb90;
	end		

	always @ (*)
	begin
		#12.5
		Clk_In <= ~Clk_In;
	end		


	 Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'h55aa), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'heb90), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Boolean_Set_Inst(
    .Clk_In(Clk_In),
    .Rst_N(Rst_N),
    .Cmd(Cmd),                // input Cmd
    .Cmd_En(Cmd_En),          // input Cmd_En
    .Output_Valid_Sig()       // Output Signal
    );
endmodule
