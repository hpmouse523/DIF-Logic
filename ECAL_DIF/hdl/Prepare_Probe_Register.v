`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Siyuan Ma  
// 
// Create Date:    10:41:09 03/07/2017 
// Design Name: 
// Module Name:    Prepare_Probe_Register 
// Project Name:    SKIROC
// Target Devices::FPGA Spartan 6 XC6SLX45 FG484  
// Tool versions: V1.0
// Description: Prepare prob registers
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Prepare_Probe_Register(
    input Clk,
    input Rst_N,
    input Start_In,
    input In_Select_Ramp_ADC,
    input [192:1] In_AnaProb_SS1_SS10_PA,
    input [128:1] In_AnaProb_Thre_Fsb,
    input [128:1] In_Outt_Out_Delay,
    input [128:1] In_OutGain_Out_ADC,
    input [2:1]   In_OR64_OR64delay,//10means ORdelay  01means OR
    output Out_Ex_Fifo_Wr_En,
    output [7:0] Out_Ex_Fifo_Din,
    output reg End_Flag
    );


    reg             Sig_Ex_Fifo_Wr_En;
    reg [7:0]       Sig_Ex_Fifo_Din;
assign      Out_Ex_Fifo_Wr_En       =   Sig_Ex_Fifo_Wr_En;
assign      Out_Ex_Fifo_Din         =   Sig_Ex_Fifo_Din;

wire    [1544:1]        Prob_Registers; //1544 bit probe registers
reg     [1544:1]        Prob_Registers_Shiftreg;
assign      Prob_Registers[192:1]       =   In_AnaProb_SS1_SS10_PA;
assign      Prob_Registers[1152:193]    =   960'd0;         //Holdb_SCA  Digital probe 2
assign      Prob_Registers[1280:1153]   =   In_AnaProb_Thre_Fsb;
assign      Prob_Registers[1408:1281]   =   In_Outt_Out_Delay;//Digital Probe1
assign      Prob_Registers[1536:1409]   =   In_OutGain_Out_ADC;//Digital Probe2
assign      Prob_Registers[1538:1537]   =   In_OR64_OR64delay;//Digital Probe1
assign      Prob_Registers[1539]        =   1'b0;     //Start_Ramp_TDC Digital probe 2
assign      Prob_Registers[1540]        =   1'b0;     //Start_Ramp_TDC_Dig Digital probe 2
assign      Prob_Registers[1541]        =   1'b1;     //Flag_TDC  Digital probe 2
assign      Prob_Registers[1542]        =   In_Select_Ramp_ADC;     // Startb_Ramp_ADC_Int  Digital probe2
assign      Prob_Registers[1543]        =   1'b0;     //Out_ramp_ADC   analogue probe
assign      Prob_Registers[1544]        =   1'b0;     //Out_ramp_TDC   analogue probe 

/*---telling the rising edge---*/
reg Start_In_Delay;
always @ (posedge Clk)
  begin
    Start_In_Delay      <=  Start_In;
  end   

reg   [3:0]             State,
                        State_Next;
localparam  [3:0]       IDLE                  =   4'd0,
                        STATE_PROB_PROCESS      =   4'd1,
                        STATE_PROB_LOOP         =   4'd2,
                        STATE_PROB_END          =   4'd3;
reg   [11:0]            Cnt_Prob_Num;
localparam  [11:0]      PROB_NUM                =   12'd193;//1544 / 8 = 193



always  @ (posedge Clk, negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State               <=  IDLE;
      end   
    else
      State                 <=  State_Next;
  end   




always  @ (*)
  begin
    if(~Rst_N)
      begin
        State_Next            = IDLE;
      end   
    else
      begin
        case(State)
          IDLE:
            if(Start_In && !Start_In_Delay)
              begin
                State_Next            = STATE_PROB_PROCESS;
              end   
            else
              begin
                State_Next            = IDLE;
              end   
          STATE_PROB_PROCESS:
            begin
              State_Next              = STATE_PROB_LOOP;
            end   
          STATE_PROB_LOOP:
            begin
              if(Cnt_Prob_Num     < PROB_NUM - 1'b1)
                begin
                  State_Next          = STATE_PROB_PROCESS;
                end   
              else
                begin
                  State_Next          = STATE_PROB_END;
                end   
            end   
          STATE_PROB_END:
            begin
              State_Next              = IDLE;
            end   
          default:
            begin
              State_Next              =IDLE;
            end   
        endcase 
      end   
  end   


always   @ (posedge Clk, negedge Rst_N)
  begin
    if(~Rst_N)
      begin
				Sig_Ex_Fifo_Wr_En       <= 1'b0;
				Sig_Ex_Fifo_Din         <= 8'b0;
				Prob_Registers_Shiftreg <= Prob_Registers;
				Cnt_Prob_Num            <= 12'b0;
				End_Flag                <= 1'b0;
      end   
    else
		begin
			Sig_Ex_Fifo_Wr_En             <= 1'b0;
			Sig_Ex_Fifo_Din               <= 8'b0;
			Prob_Registers_Shiftreg       <= Prob_Registers;
			Cnt_Prob_Num                  <= 12'b0;
			End_Flag                      <= 1'b0;
			case(State)
				IDLE:
					begin
						Sig_Ex_Fifo_Wr_En       <= 1'b0;
						Sig_Ex_Fifo_Din         <= 8'b0;
						Prob_Registers_Shiftreg <= Prob_Registers;
						Cnt_Prob_Num            <= 12'b0;
						End_Flag                <= 1'b0;

					end   
				STATE_PROB_PROCESS:
					begin
						Sig_Ex_Fifo_Wr_En       <= 1'b1;
						Sig_Ex_Fifo_Din         <= Prob_Registers_Shiftreg[1544:1537];
						Prob_Registers_Shiftreg <= Prob_Registers_Shiftreg;
						End_Flag                <= 1'b0;
						Cnt_Prob_Num            <= Cnt_Prob_Num;
					end   
				STATE_PROB_LOOP:
					begin
						Sig_Ex_Fifo_Wr_En       <= 1'b0;
						Sig_Ex_Fifo_Din         <= Sig_Ex_Fifo_Din;
						Prob_Registers_Shiftreg <= Prob_Registers_Shiftreg  << 8;
						End_Flag                <= 1'b0;
						Cnt_Prob_Num            <= Cnt_Prob_Num  + 1'b1;
					end   
				STATE_PROB_END:
					begin
						Sig_Ex_Fifo_Wr_En       <= 1'b0;
						Sig_Ex_Fifo_Din         <= 8'b0;
						Prob_Registers_Shiftreg <= Prob_Registers;
						End_Flag                <= 1'b1;
						Cnt_Prob_Num            <= 12'b0;
					end   
        endcase 
      end   
  end   



  /*-----State of putting into Fifo-----*/
endmodule
