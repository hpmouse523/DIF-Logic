`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  University of Science and Technology of China
// Engineer: 
// 
// Create Date:    10:50:18 03/21/2017 
// Design Name: 
// Module Name:    Readout_Dout 
// Project Name: 
// Target Devices: 
// Tool versions: ISE14.4
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Readout_Dout(
    input Clk,    //Input 40MHz Clk same as Fast Clk    //sloclk is 10Mhz instead of 5M  data structure is remain same
    input Rst_N,
    input In_Doutb,
    input In_TransmitOnb,
    input  [11:0] In_Num_Receive,
    output [15:0] Out_Parallel_Data,
    output     Reach_25000,
    output     Reach_30000,
    output Out_Parallel_Data_En
    );

reg     Sig_Parallel_Data_En;
assign  Out_Parallel_Data_En      = Sig_Parallel_Data_En;


reg [15:0] Cnt_2_25000,
           Cnt_2_30000;


reg [15:0] Sig_Parallel_Data;
assign  Out_Parallel_Data         = Sig_Parallel_Data;

reg     Dout_Reg,Dout_Reg_Delay;//Low active
reg     Transmitonb_Reg,Transmitonb_Reg_Delay;
reg [15:0] Sig_Parallel_Data_Temp_Gray;
wire  [15:0] Sig_Parallel_Data_Temp_Bin;


reg [3:0] Cnt_Receive;
reg [1:0] Slow_Cnt;

wire      Cnt_2_16;
assign    Cnt_2_16        =   &Cnt_Receive;

reg       Cnt_2_16_Delay;
wire      Data_Ready;
assign    Data_Ready      =   (~Cnt_2_16)   && Cnt_2_16_Delay;

always @ (posedge Clk )
  begin

    Cnt_2_16_Delay <=  Cnt_2_16;
  end   


/*------------Cnt Data-------------*/
always  @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_2_25000           <=  16'd0;
        Cnt_2_30000           <=  16'd0;
      end   
    else
      begin
        if(Transmitonb_Reg)
          begin
            Cnt_2_25000       <=  16'd0;
            Cnt_2_30000       <=  16'd0;
          end   
        else if(Data_Ready)
          begin
            Cnt_2_25000       <=  Cnt_2_25000 + 1'b1;
            Cnt_2_30000       <=  Cnt_2_30000 + 1'b1;
          end   
        else
          begin
            Cnt_2_25000       <=  Cnt_2_25000;
            Cnt_2_30000       <=  Cnt_2_30000;
          end   
      end   
  end   

assign Reach_25000    =   (Cnt_2_25000  > 16'd1579) ? 1'b1 : 1'b0;
assign Reach_30000    =   (Cnt_2_30000  > In_Num_Receive) ? 1'b1 : 1'b0;


/*-------------------------------------*/
always  @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Dout_Reg          <=  1'b1;
        Dout_Reg_Delay    <=  1'b1;
        Transmitonb_Reg_Delay <=  1'b1;
        Transmitonb_Reg   <=  1'b1;
      end   
    else
      begin
        Dout_Reg          <=  In_Doutb;
        Dout_Reg_Delay    <=  Dout_Reg;
        Transmitonb_Reg   <=  In_TransmitOnb;
        Transmitonb_Reg_Delay <=  Transmitonb_Reg;
      end   
  end   


always  @ ( posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Slow_Cnt          <=  2'd0;
      end   
    else if(Transmitonb_Reg_Delay)
      begin
        Slow_Cnt          <=  2'd0;
      end   
    else
      begin
        Slow_Cnt          <=  Slow_Cnt      + 1'b1;
      end   
  end   

always  @ ( posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Sig_Parallel_Data_Temp_Gray      <=  16'h0;
        Cnt_Receive                 <=  4'd0;
      end   
    else if(Transmitonb_Reg)
      begin
        Sig_Parallel_Data_Temp_Gray      <=  16'h0;
        Cnt_Receive                 <=  4'd0;
      end   
    else
    begin
      if(Slow_Cnt  ==  2'b01)//if Slow Clk = 5Mhz = 40M / 8,  if 10MHz = 40M/4
      begin
        Sig_Parallel_Data_Temp_Gray[4'd15 - Cnt_Receive] <=  ~Dout_Reg_Delay;
        Cnt_Receive                 <=  Cnt_Receive + 1'b1;
      end   
      else
      begin
        Sig_Parallel_Data_Temp_Gray                <=  Sig_Parallel_Data_Temp_Gray  ;
        Cnt_Receive                         <=  Cnt_Receive;
      end  
    end
  end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Sig_Parallel_Data     <=  16'h0;
        Sig_Parallel_Data_En  <=  1'b0;
      end   
    else if(Data_Ready)
      begin
        Sig_Parallel_Data     <=  Sig_Parallel_Data_Temp_Bin;
        Sig_Parallel_Data_En  <=  1'b1;
      end   
    else
      begin
        Sig_Parallel_Data     <=  16'h0;
        Sig_Parallel_Data_En  <=  1'b0;
      end   
  end   
 assign   Sig_Parallel_Data_Temp_Bin[15:12] = Sig_Parallel_Data_Temp_Gray[15:12];
 Gray_2_Bin Gray_2_Bin_Inst(
     .In_Gray(Sig_Parallel_Data_Temp_Gray[11:0]),
     .Out_Bin(Sig_Parallel_Data_Temp_Bin[11:0])
    ); 

endmodule
