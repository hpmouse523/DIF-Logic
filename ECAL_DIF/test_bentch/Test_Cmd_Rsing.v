`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/24 21:17:29
// Design Name: 
// Module Name: Test_Cmd_Rsing
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


module Test_Cmd_Rsing(

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
	end		

	always @ (*)
	begin
		#12.5
		Clk_In <= ~Clk_In;
	end		

	Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'h55aa),//Input effect words
		.LAST_CYC(8'd5)) //Input Last Cyc 
		Cmd_Rising_N_Clock_Inst(
    .Clk_In(Clk_In),
    .Rst_N(Rst_N),
    .Cmd_In(Cmd),
    .Cmd_En(Cmd_En),
    .Output_Valid_Sig()
    );
endmodule
