`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/09/19 14:10:47
// Design Name:
// Module Name: Flag_LED
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


module   Flag_LED(
	input  Clk_In, //80MHz
	input  Rst_N,
	input  In_Start_Light,
	input  In_Stop_Extinguish,
	output Out_LED,
	output Out_LED_Blink
	);


	reg Sig_Out_LED;
	reg Sig_Out_LED_Blink;

	reg In_Start_Light_Delay1, In_Start_Light_Delay2;
	reg In_Stop_Extinguish_Delay1, In_Stop_Extinguish_Delay2;//

	reg [27:0] Cnt_Time_Shut, Cnt_Time_Light;

	localparam [27:0] TIME_05S = 28'h2625A00; //means 0.5s when Clk_In = 80MHz

	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			In_Start_Light_Delay1     <= 1'b0;
			In_Start_Light_Delay2     <= 1'b0;
			In_Stop_Extinguish_Delay1 <= 1'b0;
			In_Stop_Extinguish_Delay2 <= 1'b0;
		end
		else
		begin
			In_Start_Light_Delay1     <= In_Start_Light;
			In_Start_Light_Delay2     <= In_Start_Light_Delay1;
			In_Stop_Extinguish_Delay1 <= In_Stop_Extinguish;
			In_Stop_Extinguish_Delay2 <= In_Stop_Extinguish_Delay1;
		end
	end




	reg [3:0] State,State_Next;
	localparam [3:0] STATE_IDLE  = 4'd0,
	STATE_LIGHT = 4'd1,
	STATE_SHUT  = 4'd2,
	STATE_END   = 4'd3;

	always @ (posedge Clk_In or negedge Rst_N )
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
						if(In_Start_Light_Delay1 && !In_Start_Light_Delay2)
						begin
							State_Next     = STATE_LIGHT;
						end
						else
						begin
							State_Next     = STATE_IDLE;
						end

					end
				STATE_LIGHT:
					begin
						if(In_Stop_Extinguish_Delay1 && !In_Stop_Extinguish_Delay2)
						begin
							State_Next     = STATE_IDLE;
						end
						else if(Cnt_Time_Light < TIME_05S)
						begin
							State_Next     = STATE_LIGHT;
						end
						else
						begin
							State_Next     = STATE_SHUT;
						end
					end
				STATE_SHUT:
					begin
						if(In_Stop_Extinguish_Delay1 && !In_Stop_Extinguish_Delay2)
						begin
							State_Next     = STATE_IDLE;
						end
						else
						begin
							if(Cnt_Time_Shut < TIME_05S)
							begin
								State_Next = STATE_SHUT;
							end
							else
							begin
								State_Next = STATE_LIGHT;
							end
						end
					end
				default:
					begin
						State_Next         = STATE_IDLE;
					end
			endcase
		end
	end

	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Cnt_Time_Shut     <= 28'd0;
			Cnt_Time_Light    <= 28'd0;
			Sig_Out_LED       <= 1'b0;
			Sig_Out_LED_Blink <= 1'b0;
		end
		else
		begin
			case(State)
				STATE_IDLE:
					begin
						Cnt_Time_Shut     <= 28'd0;
						Cnt_Time_Light    <= 28'd0;
						Sig_Out_LED       <= 1'b0;
						Sig_Out_LED_Blink <= 1'b0;

					end
				STATE_LIGHT:
					begin
						Cnt_Time_Light    <= Cnt_Time_Light + 1'b1;
						Sig_Out_LED       <= 1'b1;
						Sig_Out_LED_Blink <= 1'b1;
						Cnt_Time_Shut     <= 28'd0;
					end
				STATE_SHUT:
					begin
						Cnt_Time_Light    <= 28'd0;
						Sig_Out_LED_Blink <= 1'b0;
						Cnt_Time_Shut     <= Cnt_Time_Shut + 1'b1;
					end
				default:
					begin
						Cnt_Time_Shut     <= 28'd0;
						Cnt_Time_Light    <= 28'd0;
						Sig_Out_LED       <= 1'b0;
						Sig_Out_LED_Blink <= 1'b0;

					end
			endcase
		end
	end

	assign Out_LED       = Sig_Out_LED;
	assign Out_LED_Blink = Sig_Out_LED_Blink;


endmodule
