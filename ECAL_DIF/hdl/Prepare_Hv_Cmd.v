`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/24 10:59:19
// Design Name: 
// Module Name: Prepare_Hv_Cmd
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


module Prepare_Hv_Cmd(
    input Clk_In,
    input Rst_N,
    input Start_Cfg,
		input Start_Stop_Hv,
    input [56:1] In_Hv_7Byte,
    input In_Flag_Start,
    output [8:1] Out_Cmd,
    output Out_En
    );
	wire       Sig_Start_Cfg_Rising;
	wire       Sig_Start_Stop_Rising;

	reg        [3:0] State;
	reg        [3:0] State_Next;

	localparam [3:0] STATE_IDLE = 4'd0;
	localparam [3:0] STATE_LOOP_SENDING_CFG = 4'd1;
	localparam [3:0] STATE_LOOP_SENDING_START = 4'd2;
	localparam [3:0] STATE_PRE_CFG = 4'd3;
	localparam [3:0] STATE_PRE_START = 4'd4;
	
	reg        [3:0] Cnt_Sending_Cfg;
	reg        [3:0] Cnt_Sending_Start;
	localparam [3:0] CNT_CFG_HV = 4'd12;
	localparam [3:0] CNT_START_STOP = 4'd8;

	reg        [8:1] Sig_Out_Cmd;
	reg        Sig_Out_En;
	reg        [16:1] Check_Hv;
	reg        [16:1]  Sum_Of_Hv_7Byte;
	reg        [96:1] Shift_In_Hv_7Byte;
	reg        [64:1] Shift_Start_Stop;
	localparam [64:1] START_CMD = 64'h02_48_4f_4e_03_45_41_0d; // 3byte ASCII "HON" Check EA = 45_41
	localparam [64:1] STOP_CMD = 64'h02_48_4f_46_03_45_32_0d;  // 3byte ASCII "HOF" Check E2 = 45_32


	always @ (*)
	begin
		Sum_Of_Hv_7Byte = 8'd5+In_Hv_7Byte[56:49] + In_Hv_7Byte[48:41] + In_Hv_7Byte[40:33] + In_Hv_7Byte[32:25] + In_Hv_7Byte[24:17] + In_Hv_7Byte[16:9] + In_Hv_7Byte[8:1];
	end

	always @ (*)
	begin
		case(Sum_Of_Hv_7Byte[8:5])
			4'h0:Check_Hv[16:9] = 8'h30;
			4'h1:Check_Hv[16:9] = 8'h31;
			4'h2:Check_Hv[16:9] = 8'h32;
			4'h3:Check_Hv[16:9] = 8'h33;
			4'h4:Check_Hv[16:9] = 8'h34;
			4'h5:Check_Hv[16:9] = 8'h35;
			4'h6:Check_Hv[16:9] = 8'h36;
			4'h7:Check_Hv[16:9] = 8'h37;
			4'h8:Check_Hv[16:9] = 8'h38;
			4'h9:Check_Hv[16:9] = 8'h39;
			4'hA:Check_Hv[16:9] = 8'h41;
			4'hB:Check_Hv[16:9] = 8'h42;
			4'hC:Check_Hv[16:9] = 8'h43;
			4'hD:Check_Hv[16:9] = 8'h44;
			4'hE:Check_Hv[16:9] = 8'h45;
			4'hF:Check_Hv[16:9] = 8'h46;
			default: Check_Hv[16:9] = 8'h30;
		endcase								
	end			


	always @ (*)
	begin
		case(Sum_Of_Hv_7Byte[4:1])
			4'h0:Check_Hv[8:1] = 8'h30;
			4'h1:Check_Hv[8:1] = 8'h31;
			4'h2:Check_Hv[8:1] = 8'h32;
			4'h3:Check_Hv[8:1] = 8'h33;
			4'h4:Check_Hv[8:1] = 8'h34;
			4'h5:Check_Hv[8:1] = 8'h35;
			4'h6:Check_Hv[8:1] = 8'h36;
			4'h7:Check_Hv[8:1] = 8'h37;
			4'h8:Check_Hv[8:1] = 8'h38;
			4'h9:Check_Hv[8:1] = 8'h39;
			4'hA:Check_Hv[8:1] = 8'h41;
			4'hB:Check_Hv[8:1] = 8'h42;
			4'hC:Check_Hv[8:1] = 8'h43;
			4'hD:Check_Hv[8:1] = 8'h44;
			4'hE:Check_Hv[8:1] = 8'h45;
			4'hF:Check_Hv[8:1] = 8'h46;
			default: Check_Hv[8:1] = 8'h30;
		endcase								
	end			


	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			State <= STATE_IDLE;
		end		
		else
		begin
			State <= State_Next;
		end		
	end		
	always @ (*)
	begin
		if(~Rst_N)
		begin
			State_Next = STATE_IDLE;
		end		
		else
		begin
			case(State)
					STATE_IDLE:
					begin

						if(Sig_Start_Cfg_Rising)
							begin
								State_Next = STATE_PRE_CFG;
							end		
						else if(Sig_Start_Stop_Rising)
							begin
								State_Next = STATE_PRE_START;
							end		
						else
							begin
								State_Next = STATE_IDLE;
							end		
						
					end		
					STATE_PRE_CFG:
					begin
						State_Next = STATE_LOOP_SENDING_CFG;
					end		
					STATE_PRE_START:
					begin
						State_Next = STATE_LOOP_SENDING_START;
					end		
					STATE_LOOP_SENDING_CFG:
					begin
						if(Cnt_Sending_Cfg < CNT_CFG_HV - 1'b1)
						begin
							State_Next = STATE_PRE_CFG;
						end		
						else
						begin
							State_Next = STATE_IDLE;
						end		
					end		
					STATE_LOOP_SENDING_START:
					begin
						if(Cnt_Sending_Start < CNT_START_STOP - 1'b1)
						begin
							State_Next = STATE_PRE_START;
						end		
						else
						begin
							State_Next = STATE_IDLE;
						end		
					end		
				default:
					State_Next = STATE_IDLE;
			endcase		
		end		
	end		

	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Cnt_Sending_Cfg                <= 4'd0;
			Cnt_Sending_Start              <= 4'd0;
			Sig_Out_En                     <= 1'b0;
			Sig_Out_Cmd                    <= 8'd0;
			Shift_In_Hv_7Byte[96:89]       <= 8'h02;
			Shift_In_Hv_7Byte[8:1]         <= 8'h0d;
			Shift_In_Hv_7Byte[24:9]        <= Check_Hv;
			Shift_In_Hv_7Byte[88:33]       <= In_Hv_7Byte;
			Shift_In_Hv_7Byte[32:25]       <= 8'h03;
		end		
		else
		begin
			case(State)
				  STATE_IDLE:
					begin
						Cnt_Sending_Cfg          <= 4'd0;
						Cnt_Sending_Start        <= 4'd0;
						Sig_Out_En               <= 1'b0;
						Sig_Out_Cmd              <= 8'd0;
						Shift_In_Hv_7Byte[96:89] <= 8'h02;
						Shift_In_Hv_7Byte[8:1]   <= 8'h0d;
						Shift_In_Hv_7Byte[24:9]  <= Check_Hv;
						Shift_In_Hv_7Byte[88:33] <= In_Hv_7Byte;
						Shift_In_Hv_7Byte[32:25] <= 8'h03;
						if(In_Flag_Start)
							Shift_Start_Stop       <= START_CMD;
						else
							Shift_Start_Stop       <= STOP_CMD;
					end		
					STATE_PRE_CFG:
					begin
						Sig_Out_Cmd              <= Shift_In_Hv_7Byte[96:89];
						Sig_Out_En               <= 1'b0;
					end		
					STATE_PRE_START:
					begin
						Sig_Out_Cmd              <= Shift_Start_Stop[64:57];
						Sig_Out_En               <= 1'b0;
					end		
					STATE_LOOP_SENDING_CFG:
					begin
						Shift_In_Hv_7Byte        <= Shift_In_Hv_7Byte << 8;
						Sig_Out_En               <= 1'b1;
						Cnt_Sending_Cfg          <= Cnt_Sending_Cfg + 1'b1;
					end		
					STATE_LOOP_SENDING_START:
					begin
						Shift_Start_Stop         <= Shift_Start_Stop << 8;
						Sig_Out_En               <= 1'b1;
						Cnt_Sending_Start        <= Cnt_Sending_Start + 1'b1;
					end		
				default:
					begin
						Cnt_Sending_Cfg          <= 4'd0;
						Cnt_Sending_Start        <= 4'd0;
						Sig_Out_En               <= 1'b0;
						Sig_Out_Cmd              <= 8'd0;
						Shift_In_Hv_7Byte        <= In_Hv_7Byte;
					end		
			endcase			
		end		
	end		

	assign Out_Cmd = Sig_Out_Cmd;
	assign Out_En = Sig_Out_En;

	topulsesignal   #(.size (1)) Tell_Start_Cfg  (
				.clk	(Clk_In),
				.rst_n	(Rst_N),
				.din	(Start_Cfg),
				.dout	(Sig_Start_Cfg_Rising)
		);
		topulsesignal #(.size (1)) Tell_Start_Stop (
				.clk	(Clk_In),
				.rst_n	(Rst_N),
				.din	(Start_Stop_Hv),
				.dout	(Sig_Start_Stop_Rising)
		);
endmodule
