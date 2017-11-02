`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/09/16 20:39:01
// Design Name:
// Module Name: Auto_TA_Scan
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


module Auto_TA_Scan(
	input          Clk_10MHz,
	input          Rst_N,
	input  [9:0]   Ini_DAC,
	input          In_Trig_Ex_From_Signal,
	input          In_Hit_From_SKIROC,
	input          In_Start_Scan,
	input          In_Finish_Sc,//at least last 1cyc
	output         Out_Finish_Scan,
	output         Out_Set_SC,
	output [48:1]  Out_Set_DAC,//48bit but useful is 40bit
	output [256:1] Out_Mask_Code,
	output [16:1]  Out_Fifo_Din,
	output         Out_Token_All,
	output         Out_Fifo_Wr,
	output [12:1]  Out_Test_Cnt_Hit
	);


	reg         In_Start_Scan_Delay1;
	reg         In_Start_Scan_Delay2;

	reg         Out_Set_SC_Sig;
	reg         Out_Fifo_Wr_Sig;
	reg  [16:1] Out_Fifo_Din_Sig;
	
	wire [12:1] Sig_Test_Cnt_Hit;
	wire [4:1]  Sel_Chip;
	wire [12:1] Sig_Ini_DAC;
	wire        Sig_Token_Chip1,Sig_Set_SC_Chip1;
	wire        Sig_Token_Chip2,Sig_Set_SC_Chip2;
	wire        Sig_Token_Chip3,Sig_Set_SC_Chip3;
	wire        Sig_Token_Chip4,Sig_Set_SC_Chip4;
	wire        Sig_Fifo_Wr_Chip1,Sig_Fifo_Wr_Chip2,Sig_Fifo_Wr_Chip3,Sig_Fifo_Wr_Chip4;
	wire [16:1] Sig_Fifo_Din_Chip1,Sig_Fifo_Din_Chip2,Sig_Fifo_Din_Chip3,Sig_Fifo_Din_Chip4;
	wire [12:1] Sig_DAC_Chip1,Sig_DAC_Chip2,Sig_DAC_Chip3,Sig_DAC_Chip4;


	wire [64:1]Sig_Mask_Chip1,Sig_Mask_Chip2,Sig_Mask_Chip3,Sig_Mask_Chip4;
	wire End_Chip1,End_Chip2,End_Chip3;


	always @ (posedge Clk_10MHz or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			In_Start_Scan_Delay1 <= 1'b0;
			In_Start_Scan_Delay2 <= 1'b0;
		end
		else
		begin
			In_Start_Scan_Delay1 <= In_Start_Scan;
			In_Start_Scan_Delay2 <= In_Start_Scan_Delay1;
		end
	end

	always @ (*)
	begin
		case(Sel_Chip)
			4'b1000:
				begin
					Out_Set_SC_Sig   = Sig_Set_SC_Chip1;
					Out_Fifo_Din_Sig = Sig_Fifo_Din_Chip1;
					Out_Fifo_Wr_Sig  = Sig_Fifo_Wr_Chip1;
				end
			4'b0100:
				begin
					Out_Set_SC_Sig   = Sig_Set_SC_Chip2;
					Out_Fifo_Din_Sig = Sig_Fifo_Din_Chip2;
					Out_Fifo_Wr_Sig  = Sig_Fifo_Wr_Chip2;
				end
			4'b0010:
				begin
					Out_Set_SC_Sig   = Sig_Set_SC_Chip3;
					Out_Fifo_Din_Sig = Sig_Fifo_Din_Chip3;
					Out_Fifo_Wr_Sig  = Sig_Fifo_Wr_Chip3;
				end
			4'b0001:
				begin
					Out_Fifo_Din_Sig = Sig_Fifo_Din_Chip4;
					Out_Set_SC_Sig   = Sig_Set_SC_Chip4;
					Out_Fifo_Wr_Sig  = Sig_Fifo_Wr_Chip4;
				end
			default:
				begin
					Out_Set_SC_Sig   = Sig_Set_SC_Chip1;
					Out_Fifo_Din_Sig = Sig_Fifo_Din_Chip1;
					Out_Fifo_Wr_Sig  = Sig_Fifo_Wr_Chip1;
				end
		endcase

	end


	SKIROC2_S_Para_Scan SKIROC_Auto_TA_Inst_Chip1(
		.Clk_10M(Clk_10MHz),
		.Rst_N(Rst_N),
		.In_Start(In_Start_Scan_Delay2),
		.In_ID(4'd0),
		.In_Ini_DAC(Sig_Ini_DAC),
		.In_Hit_In(In_Hit_From_SKIROC),
		.In_Trig_In(In_Trig_Ex_From_Signal),//rising edge effect
		.In_Sc_End(In_Finish_Sc),
		.Out_End(Out_Finish_Scan),//finish scan only 1 chip. this is scalable
		.Out_Token(Sig_Token_Chip1),
		.Out_Set_SC(Sig_Set_SC_Chip1),
		.Out_Send_Trig(),
		.Out_Mask_Code(Sig_Mask_Chip1),
		.Out_DAC_Code(Sig_DAC_Chip1),
		.Out_Fifo_Din(Sig_Fifo_Din_Chip1),
		.Out_Fifo_Wr(Sig_Fifo_Wr_Chip1),
		.Out_Test_Cnt_Hit(Sig_Test_Cnt_Hit)
		);

	SKIROC2_S_Para_Scan SKIROC_Auto_TA_Inst_Chip2(
		.Clk_10M(Clk_10MHz),
		.Rst_N(Rst_N),
		.In_Start(1'b0),
		.In_ID(4'd1),
		.In_Ini_DAC(Sig_Ini_DAC),
		.In_Hit_In(In_Hit_From_SKIROC),
		.In_Trig_In(In_Trig_Ex_From_Signal),//rising edge effect
		.In_Sc_End(In_Finish_Sc),
		.Out_End(),
		.Out_Token(Sig_Token_Chip2),
		.Out_Set_SC(Sig_Set_SC_Chip2),
		.Out_Send_Trig(),
		.Out_Mask_Code(Sig_Mask_Chip2),
		.Out_DAC_Code(Sig_DAC_Chip2),
		.Out_Fifo_Din(Sig_Fifo_Din_Chip2),
		.Out_Fifo_Wr(Sig_Fifo_Wr_Chip2),
		.Out_Test_Cnt_Hit()
		);

	SKIROC2_S_Para_Scan SKIROC_Auto_TA_Inst_Chip3(
		.Clk_10M(Clk_10MHz),
		.Rst_N(Rst_N),
		.In_Start(1'b0),
		.In_ID(4'd2),
		.In_Ini_DAC(Sig_Ini_DAC),
		.In_Hit_In(In_Hit_From_SKIROC),
		.In_Trig_In(In_Trig_Ex_From_Signal),//rising edge effect
		.In_Sc_End(In_Finish_Sc),
		.Out_End(),
		.Out_Token(Sig_Token_Chip3),
		.Out_Set_SC(Sig_Set_SC_Chip3),
		.Out_Send_Trig(),
		.Out_Mask_Code(Sig_Mask_Chip3),
		.Out_DAC_Code(Sig_DAC_Chip3),
		.Out_Fifo_Din(Sig_Fifo_Din_Chip3),
		.Out_Fifo_Wr(Sig_Fifo_Wr_Chip3),
		.Out_Test_Cnt_Hit()
		
		);

	SKIROC2_S_Para_Scan SKIROC_Auto_TA_Inst_Chip4(
		.Clk_10M(Clk_10MHz),
		.Rst_N(Rst_N),
		.In_Start(1'b0),
		.In_ID(4'd3),
		.In_Ini_DAC(Sig_Ini_DAC),
		.In_Hit_In(In_Hit_From_SKIROC),
		.In_Trig_In(In_Trig_Ex_From_Signal),//rising edge effect
		.In_Sc_End(In_Finish_Sc),
		.Out_End(),
		.Out_Token(Sig_Token_Chip4),
		.Out_Set_SC(Sig_Set_SC_Chip4),
		.Out_Send_Trig(),
		.Out_Mask_Code(Sig_Mask_Chip4),
		.Out_DAC_Code(Sig_DAC_Chip4),
		.Out_Fifo_Din(Sig_Fifo_Din_Chip4),
		.Out_Fifo_Wr(Sig_Fifo_Wr_Chip4),
		.Out_Test_Cnt_Hit()
		
		);

	assign Sig_Ini_DAC   = {2'b0,Ini_DAC};
	assign Out_Mask_Code = {Sig_Mask_Chip1,Sig_Mask_Chip2,Sig_Mask_Chip3,Sig_Mask_Chip4};
	assign Sel_Chip      = {Sig_Token_Chip1,Sig_Token_Chip2,Sig_Token_Chip3,Sig_Token_Chip4};
	assign Out_Set_DAC   = {Sig_DAC_Chip1,Sig_DAC_Chip2,Sig_DAC_Chip3,Sig_DAC_Chip4};
	assign Out_Set_SC    = Out_Set_SC_Sig;
	assign Out_Fifo_Wr   = Out_Fifo_Wr_Sig;
	assign Out_Fifo_Din  = Out_Fifo_Din_Sig;
	assign Out_Token_All = Sig_Token_Chip1|Sig_Token_Chip2|Sig_Token_Chip3|Sig_Token_Chip4;
	assign Out_Test_Cnt_Hit = Sig_Test_Cnt_Hit; 
endmodule
