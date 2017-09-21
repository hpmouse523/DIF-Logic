`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/09/14 17:22:18
// Design Name:
// Module Name: SKIROC2_S_Para_Scan
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


module SKIROC2_S_Para_Scan(
	input  Clk_10M,
	input  Rst_N,
	input  In_Start,
	input  [4:1] In_ID,
	input  [12:1] In_Ini_DAC,
	input  In_Hit_In,  // rising edge effect
	input  In_Trig_In, // rising edge effect
	input  In_Sc_End,  // last at lest 1 cyc = 100ns
	output reg Out_End,
	output reg Out_Token,
	output reg Out_Set_SC,
	output reg Out_Send_Trig,
	output reg [64:1] Out_Mask_Code,
	output reg [12:1] Out_DAC_Code,
	output reg [16:1] Out_Fifo_Din,
	output reg Out_Fifo_Wr
	);

	wire [7:0] Assert_Channel;



	wire [80:1] Data_to_Fifo; //This is used to write in Data to Fifo


	reg  [80:1] Data_to_Fifo_Shift;

	localparam	[64:1]	MASK_INI     = 64'h7FFFFFFFFFFFFFFF; // Trig Mask from channel 63 to 0 is from L to MSB. so Channel 0 is Highest bit. Mask = 1means Mask this channel.
	localparam	[11:0]	CNT_TRIG_NUM = 12'd1000,//just fot test  total num = 20
	CNT_HIGH_THR                     = 12'd970,
	CNT_LOW_THR                      = 12'd30;
	localparam                       [11:0] CNT_TIME_WAIT_HIT = 12'd50;       // 50 cycs of 10MHz(100ns) = 5us

	localparam [3:0] CNT_WR_FIFO_NUM = 4'd5;
	localparam [11:0] NUM_CHANNEL  = 64; //num of channel

	reg [3:0] Cnt_Wr_Fifo;
	reg	[11:0]	Cnt_Trig;                               // max cnt is 4095. Default is 1000 Trig_:w
	reg [11:0]  Cnt_Channel;
	reg [11:0]  Cnt_Hit;                                // if Cnt to 97% or below 3%
	reg [11:0]  Cnt_Wait_Hit;//Wait some time;

	reg	[7:0]	State;
	reg	[7:0]	State_Next;

	reg Flag_Start_Acq;
	reg Flag_Start_Wr,
	Flag_Start_Wr_Delay1,
	Flag_Start_Wr_Delay2;



	reg	In_Start_Delay1,
	In_Start_Delay2;

	reg Flag_End_Wr_Fifo;//finish writing FIFO
	assign Assert_Channel = Cnt_Channel + 1'b1;
	always @ (posedge Clk_10M or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			In_Start_Delay1 <= 1'b0;
			In_Start_Delay2 <= 1'b0;
		end
		else
		begin
			In_Start_Delay1 <= In_Start;
			In_Start_Delay2 <= In_Start_Delay1;
		end
	end

	reg In_Trig_In_Delay1,
	In_Trig_In_Delay2;
	reg In_Hit_In_Delay1,
	In_Hit_In_Delay2;
	always @ (posedge Clk_10M or negedge Rst_N)// tell the rising edge of Trig_In
	begin
		if(~Rst_N)
		begin
			In_Trig_In_Delay1    <= 1'b0;
			In_Trig_In_Delay2    <= 1'b0;
			In_Hit_In_Delay1     <= 1'b0;
			In_Hit_In_Delay2     <= 1'b0;
			Flag_Start_Wr_Delay1 <= 1'b0;
			Flag_Start_Wr_Delay2 <= 1'b0;
		end
		else
		begin
			Flag_Start_Wr_Delay1 <= Flag_Start_Wr;
			Flag_Start_Wr_Delay2 <= Flag_Start_Wr_Delay1;
			In_Trig_In_Delay1    <= In_Trig_In;
			In_Trig_In_Delay2    <= In_Trig_In_Delay1;
			In_Hit_In_Delay1     <= In_Hit_In;
			In_Hit_In_Delay2     <= In_Hit_In_Delay1;
		end
	end

	always @ (posedge Clk_10M or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Cnt_Trig <= 12'd0;
		end
		else if (~Flag_Start_Acq)
		begin
			Cnt_Trig <= 12'd0;
		end
		else if(In_Trig_In_Delay1 && !In_Trig_In_Delay2 && Flag_Start_Acq)
		begin
			Cnt_Trig <= Cnt_Trig + 1'b1;
		end
		else
		begin
			Cnt_Trig <= Cnt_Trig;
		end
	end

	localparam	[7:0]	STATE_IDLE              = 8'd0,
	STATE_SET_MASK_START    = 8'd1,
	STATE_SET_MASK          = 8'd2,
	STATE_SET_DAC_START     = 8'd3,
	STATE_DAC_PLUS          = 8'd4,
	STATE_SET_SC            = 8'd5,
	STATE_WAIT_SC_SET       = 8'd6,
	STATE_START_ACQ         = 8'd7,
	STATE_WAIT_OR_SEND_TRIG = 8'd8,
	STATE_WAIT_HIT          = 8'd9,
	STATE_WR_FIFO           = 8'd10,
	STATE_END               = 8'd11,
	STATE_MASK_PLUS         = 8'd12;
	always @ (posedge Clk_10M or negedge Rst_N)
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
						if(In_Start_Delay1 && ~In_Start_Delay2) //Rising edge of In Start
						begin
							State_Next = STATE_SET_MASK_START;
						end
						else
						begin
							State_Next = STATE_IDLE;
						end
					end
				STATE_SET_MASK_START:
					begin
						State_Next = STATE_SET_DAC_START;
					end

				STATE_SET_DAC_START:
					begin
						State_Next = STATE_SET_SC;
					end
				STATE_SET_SC:
					begin
						State_Next = STATE_WAIT_SC_SET;
					end
				STATE_WAIT_SC_SET:
					begin
						if(In_Sc_End)
						begin
							State_Next = STATE_START_ACQ;
						end
						else
						begin
							State_Next = STATE_WAIT_SC_SET;
						end
					end
				STATE_START_ACQ:
					begin
						State_Next = STATE_WAIT_OR_SEND_TRIG;
					end
				STATE_WAIT_OR_SEND_TRIG:
					begin
						if(In_Trig_In_Delay1 && ~In_Trig_In_Delay2)
						begin
							State_Next = STATE_WAIT_HIT;
						end
						else
						begin
							State_Next = STATE_WAIT_OR_SEND_TRIG;
						end
					end
				STATE_DAC_PLUS:
					begin
						State_Next = STATE_SET_SC;
					end
				STATE_WAIT_HIT:
					begin
						if(In_Hit_In_Delay1 && !In_Hit_In_Delay2)
						begin

							if(Cnt_Trig < CNT_TRIG_NUM)
							begin
								State_Next = STATE_WAIT_OR_SEND_TRIG;
							end
							else if(Cnt_Hit < CNT_LOW_THR)
							begin
								State_Next = STATE_MASK_PLUS;
							end
							else if(Cnt_Hit > CNT_HIGH_THR)
							begin
								State_Next = STATE_DAC_PLUS;
							end
							else
							begin
								State_Next = STATE_WR_FIFO;
							end
						end
						else
						begin
							if(Cnt_Wait_Hit < CNT_TIME_WAIT_HIT)
							begin
								State_Next = STATE_WAIT_HIT;
							end
							else if(Cnt_Trig < CNT_TRIG_NUM)
							begin
								State_Next = STATE_WAIT_OR_SEND_TRIG;
							end
							else if(Cnt_Hit < CNT_LOW_THR)
							begin
								State_Next = STATE_MASK_PLUS;
							end
							else if(Cnt_Hit > CNT_HIGH_THR)
							begin
								State_Next = STATE_DAC_PLUS;
							end
							else
							begin
								State_Next = STATE_WR_FIFO;
							end
						end
					end
				STATE_MASK_PLUS:
					begin
						if(Cnt_Channel < NUM_CHANNEL - 1'b1)
							State_Next = STATE_SET_DAC_START;
						else
						begin
							State_Next = STATE_END;
						end
					end
				STATE_WR_FIFO:
					begin
						if(Flag_End_Wr_Fifo	==	1'b1)
						begin
							State_Next = STATE_DAC_PLUS;
						end
						else
						begin
							State_Next = STATE_WR_FIFO;
						end
					end
				STATE_END:
					begin
						State_Next = STATE_IDLE;
					end
				default:
					begin
						State_Next = STATE_IDLE;
					end

			endcase
		end
	end

	always @ (posedge Clk_10M or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Out_Token      <= 1'b0;
			Out_End        <= 1'b0;
			Out_DAC_Code   <= 12'hfff;
			Out_Set_SC     <= 1'b0;
			Out_Mask_Code  <= 64'hFFFFFFFFFFFFFFFF; //all mask
			Cnt_Wait_Hit   <= 12'd0;
			Cnt_Channel    <= 12'd0;
			Cnt_Hit        <= 12'd0;
			Flag_Start_Acq <= 1'b0;
			Out_Send_Trig  <= 1'b0;
			Flag_Start_Wr  <= 1'b0;
		end
		else
		begin
			case(State)
				STATE_IDLE:
					begin
						Out_Token      <= 1'b0;
						Out_End        <= 1'b0;
						Out_DAC_Code   <= 12'hfff;
						Out_Set_SC     <= 1'b0;
						Out_Mask_Code  <= 64'hFFFFFFFFFFFFFFFF; //all mask
						Cnt_Wait_Hit   <= 12'd0;
						Cnt_Channel    <= 12'd0;
						Cnt_Hit        <= 12'd0;
						Flag_Start_Acq <= 1'b0;
						Out_Send_Trig  <= 1'b0;
						Flag_Start_Wr  <= 1'b0;
					end
				STATE_SET_MASK_START:
					begin
						Out_Mask_Code <= MASK_INI;
						Out_Token <= 1'b1;
					end
				STATE_SET_DAC_START:
					begin
						Out_DAC_Code <= In_Ini_DAC;
					end
				STATE_SET_SC:
					begin
						Out_Set_SC <= 1'b1;
					end
				STATE_WAIT_SC_SET:
					begin
						Out_Set_SC <= 1'b0;
					end
				STATE_START_ACQ:
					begin
						Flag_Start_Acq <= 1'b1;
					end
				STATE_DAC_PLUS:
					begin
						Cnt_Wait_Hit   <= 12'd0;
						Out_DAC_Code   <= Out_DAC_Code + 1'b1;
						Flag_Start_Acq <= 1'b0;
						Cnt_Hit        <= 12'd0;
						Flag_Start_Wr  <= 1'b0;

					end
				STATE_WR_FIFO:
					begin
						Flag_Start_Acq <= 1'b0;
						Cnt_Wait_Hit   <= 12'd0;
						Flag_Start_Wr  <= 1'b1;
					end
				STATE_MASK_PLUS:
					begin
						Cnt_Wait_Hit   <= 12'd0;
						Flag_Start_Acq <= 1'b0;
						Cnt_Hit        <= 12'd0;
						Cnt_Channel    <= Cnt_Channel + 1'b1;
						Out_Mask_Code  <= {1'b1, Out_Mask_Code[64:2]};
					end
				STATE_END:
					begin
						Out_Token <= 1'b0;
						Out_End   <= 1'b1;
					end
				STATE_WAIT_OR_SEND_TRIG:
					begin
						Cnt_Wait_Hit  <= 12'd0;
						Out_Send_Trig <= 1'b1;
					end
				STATE_WAIT_HIT:
					begin
						Cnt_Wait_Hit  <= Cnt_Wait_Hit + 1'b1;
						Out_Send_Trig <= 1'b0;
						if(In_Hit_In_Delay1 && !In_Hit_In_Delay2)
						begin
							Cnt_Hit   <= Cnt_Hit + 1'b1;
						end
					end
				default:
					begin
						Out_Token      <= 1'b0;
						Out_End        <= 1'b0;
						Out_DAC_Code   <= 12'hfff;
						Out_Set_SC     <= 1'b0;
						Out_Mask_Code  <= 64'hFFFFFFFFFFFFFFFF; //all mask
						Cnt_Wait_Hit   <= 12'd0;
						Cnt_Channel    <= 12'd0;
						Cnt_Hit        <= 12'd0;
						Flag_Start_Acq <= 1'b0;
						Out_Send_Trig  <= 1'b0;

					end

			endcase
		end

	end





	reg [3:0] State_Fifo;
	reg [3:0] State_Fifo_Next;

	localparam [3:0] STATE_FIFO_IDLE = 4'd0,
	STATE_FIFO_PROCESS = 4'd1,
	STATE_FIFO_LOOP = 4'd2,
	STATE_FIFO_END = 4'd3;

	always @ (posedge Clk_10M or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			State_Fifo <= STATE_FIFO_IDLE;
		end
		else
		begin
			State_Fifo <= State_Fifo_Next;
		end
	end

	always @ (*)
	begin
		if(~Rst_N)
		begin
			State_Fifo_Next = STATE_FIFO_IDLE;
		end
		else
		begin
			case(State_Fifo)
				STATE_FIFO_IDLE:
					begin
						if(Flag_Start_Wr_Delay1 && !Flag_Start_Wr_Delay2)//telling the rising edge of Flag Wr
						begin
							State_Fifo_Next = STATE_FIFO_PROCESS;
						end
						else
						begin
							State_Fifo_Next = STATE_FIFO_IDLE;
						end
					end
				STATE_FIFO_PROCESS:
					begin
						State_Fifo_Next = STATE_FIFO_LOOP;
					end
				STATE_FIFO_LOOP:
					begin
						if(Cnt_Wr_Fifo < CNT_WR_FIFO_NUM - 1'b1)
							State_Fifo_Next = STATE_FIFO_PROCESS;
						else
							State_Fifo_Next = STATE_FIFO_END;
					end
				STATE_FIFO_END:
					begin
						State_Fifo_Next = STATE_FIFO_IDLE;
					end
				default:
					State_Fifo_Next = STATE_FIFO_IDLE;
			endcase
		end
	end

	always @ (posedge Clk_10M or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Out_Fifo_Wr      <= 1'b0;
			Out_Fifo_Din     <= 16'h0;
			Cnt_Wr_Fifo      <= 4'd0;
			Flag_End_Wr_Fifo <= 1'b0;
			Data_to_Fifo_Shift <= Data_to_Fifo;
		end
		else
		begin
			case(State_Fifo)
				STATE_FIFO_IDLE:
					begin
						Out_Fifo_Wr        <= 1'b0;
						Out_Fifo_Din       <= 16'h0;
						Cnt_Wr_Fifo        <= 4'd0;
						Flag_End_Wr_Fifo   <= 1'b0;
						Data_to_Fifo_Shift <= Data_to_Fifo;

					end
				STATE_FIFO_PROCESS:
					begin
						Out_Fifo_Din       <= Data_to_Fifo_Shift[80:65];
						Out_Fifo_Wr        <= 1'b1;
					end
				STATE_FIFO_LOOP:
					begin
						Out_Fifo_Wr        <= 1'b0;
						Out_Fifo_Din       <= Data_to_Fifo_Shift[80:65];					
						Data_to_Fifo_Shift <= Data_to_Fifo_Shift << 16;
						Cnt_Wr_Fifo        <= Cnt_Wr_Fifo + 1'b1;
					end
				STATE_FIFO_END:
					begin
						Cnt_Wr_Fifo        <= 4'd0;
						Flag_End_Wr_Fifo   <= 1'b1;
					end
				default:
					begin
						Out_Fifo_Wr        <= 1'b0;
						Out_Fifo_Din       <= 16'h0;
						Cnt_Wr_Fifo        <= 4'd0;
						Flag_End_Wr_Fifo   <= 1'b0;
						Data_to_Fifo_Shift <= Data_to_Fifo;
					end
			endcase
		end
	end
	assign Data_to_Fifo[80:65] = 16'h55aa;
	assign Data_to_Fifo[64:49] = {In_ID,Assert_Channel};
	assign Data_to_Fifo[48:33] = {4'b0000,Out_DAC_Code};
	assign Data_to_Fifo[32:17] = {4'h0,Cnt_Hit};
	assign Data_to_Fifo[16:1] = 16'h5aa5;


endmodule
