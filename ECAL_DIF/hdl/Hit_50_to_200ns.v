`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/13 17:47:40
// Design Name: 
// Module Name: Hit_50_to_200ns
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


module Hit_50_to_200ns(
    input  Clk_In,//80MHz
    input  Rst_N,
    input  In_Hit_Sig,
    output Out_Hit_Sig
    );

	reg       Sig_Hit_Sig;
	reg       In_Hit_Sig_Delay1;
	reg       In_Hit_Sig_Delay2;
	reg [7:0] Cnt_Spread;
	reg [3:0] State;
	reg [3:0] State_Next;

	localparam [7:0] CNT_SPREAD = 8'd20;
	localparam [3:0] STATE_LOOP = 4'd1;
	localparam [3:0] STATE_IDLE = 4'd0;

	always @(posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			In_Hit_Sig_Delay1 <= 1'b1;
			In_Hit_Sig_Delay1 <= 1'b1;			
		end		
		else
		begin
			In_Hit_Sig_Delay1 <= In_Hit_Sig;
			In_Hit_Sig_Delay2 <= In_Hit_Sig_Delay1;
		end		
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

	always @(*)
	begin
		if(~Rst_N)
		begin
			State_Next         = STATE_IDLE;
		end		
		else
		begin
			case(State)
				STATE_IDLE:
					begin
						if(!In_Hit_Sig_Delay1 && In_Hit_Sig_Delay2)
						begin
							State_Next = STATE_LOOP;
						end		
						else
						begin
							State_Next = STATE_IDLE;
						end		
					end		
				STATE_LOOP:
					begin
						if(Cnt_Spread < CNT_SPREAD)
						begin
							State_Next = STATE_LOOP;
						end		
						else
						begin
							State_Next = STATE_IDLE;
						end		
					end
		    default:
					begin
						State_Next   = STATE_IDLE;
					end				
			endcase			
		end		
	end		

	always @ (posedge Clk_In or negedge Rst_N)
	begin
		if(~Rst_N)
		begin
			Sig_Hit_Sig     <= 1'b1;
			Cnt_Spread      <= 8'd0;
		end		
		else
		begin
		case(State)
			STATE_IDLE:
				begin
					Cnt_Spread  <= 8'd0;
					Sig_Hit_Sig <= 1'b1;
				end		
			STATE_LOOP:
				begin
					Cnt_Spread  <= Cnt_Spread + 1'b1;
					Sig_Hit_Sig <= 1'b0;
				end		
			default:
				begin
					Cnt_Spread  <= 8'd0;
					Sig_Hit_Sig <= 1'b1;
				end		
		endcase		

		end		
	end			
assign Out_Hit_Sig = Sig_Hit_Sig;
endmodule
