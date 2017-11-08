`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/08 15:02:36
// Design Name: 
// Module Name: Test Usb_Command
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


module Test_Usb_Command();
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
		Cmd = 16'hffc0;

		#100
		Cmd = 16'hffd0;
	end		

	always @ (*)
	begin
		#12.5
		Clk_In <= ~Clk_In;
	end		

	//Command(from USB Chip) interpreter
				usb_command_interpreter usb_command_interpreter_Inst(

					.clk(Clk_In),
					.reset_n(Rst_N),
					.in_from_usb_Ctr_rd_en(Cmd_En),
					.in_from_usb_ControlWord(Cmd),
					.Cnt_Trig(),
					.out_to_usb_Acq_Start_Stop(),
					.out_to_control_usb_data(),
					.LED(),
					.Out_DAC_Adj_Chn64(),
					.Out_Sel_Work_Mode(),
					.Out_Sel_High_Low_Leakage(),
					.Out_Valid_TA_for_Self_Mod(),
					.Out_Val_Evt(),//default 1 en discriminator
					.Out_Trig_Start_Stop(),
					.Out_Sel_OnlyExTrig(),
					.Out_Hold(),
					.Out_Control_Trig_Mode(),
					.Out_Delay_Trig_Temp(),
					.Out_Set_Trig_Inside_Time(),
					.Out_Set_Constant_Interval_Time(),
					.Out_Set_Ini_DAC_for_Auto_Scan(),
					.Out_Set_Hv_1(),//highest 4bit
					.Out_Set_Hv_2(),
					.Out_Set_Hv_3(),
					.Out_Set_Hv_4(),//lowest bit
					.Out_Sel_ADC_Test(),
					.Out_ADG_Switch(),
					.Out_Reset_ASIC_b(),
					.Out_Start_Acq(),
					.Out_Start_Conver_b(),
					.Out_Force_Trig(),
					.Out_Start_Readout1(),
					.Out_Start_Cfg_Hv(),
					.Out_Start_Stop_Hv(),
					.Out_Flag_Start_Stop_Hv(),
					.Out_Start_Readout2(),
					.Out_Start_Stop_ADG(),
					.Out_AnaProb_SS1_SS10_PA(),
					.Out_AnaProb_Thre_Fsb(),
					.Select_Main_Backup(),
					.Out_Set_Register(),
					.Out_Sel_Feedback_Capacitance(),
					.Out_Choose_Channel_Resister(),
					.Out_Set_Mask64(),
					.Out_Sel_Cali_TA(),
					.Out_Set_Cali_DAC(),
					.Out_Set_TA_Thr_DAC_12(),
					.Out_Set_TA_Thr_DAC_34(),
					.Out_TA_Mode(),
					.Out_Select_Ramp_ADC(),
					.Out_Disable_Channel(),
					.Out_Start_Config(),
					.Out_Select(),
					.Out_Select_TDC_On(),
					.Out_Status_Power_On_Control()

					);

endmodule
