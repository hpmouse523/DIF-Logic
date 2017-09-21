`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:08:40 07/09/2015 
// Design Name: 
// Module Name:    usb_command_interpreter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module usb_command_interpreter( 						//The Clk cyc = 12.5ns not 20ns
      input                 IFCLK,
      input                 clk,
      input                 reset_n,
                                                       /* --------USB interface------------*/
      input                 in_from_usb_Ctr_rd_en,
      input [15:0]          in_from_usb_ControlWord,
      input [19:0]          Cnt_Trig,
      output reg            out_to_usb_Acq_Start_Stop,
                                                       /* -------clear usb fifo------------*/
      output reg            out_to_control_usb_data,   // control USB choose input Data ADC_Constant_Data or Normal Data
                                                       /* -------LED test------------------*/
      output reg [5:0]      LED,
                                                       /* ------Select Work mode-----------*/
      output reg            Out_Sel_Work_Mode,
                                                       /* ------Control Trig and ADC module--------*/
      output reg [4:1]      Out_Valid_TA_for_Self_Mod, // Control which TA to use for Self Trig mode  1111for all use 0001for only use TA1

      output reg            Out_Trig_Start_Stop,  
      output reg            Out_Hold,
      output reg [3:0]      Out_Control_Trig_Mode,
      output reg [7:0]      Out_Set_Trig_Inside_Time, 
      output reg [13:0]     Out_Set_Constant_Interval_Time,
      output reg [11:0]     Out_Set_Hold_Delay_Time,
                                                       /* ---------Control ADG-----------*/
      output reg            Out_Sel_ADC_Test,
      output reg            Out_ADG_Switch,

      output reg            Out_Reset_ASIC_b,
      output reg            Out_Start_Acq,
      output reg            Out_Start_Conver_b,
      output reg            Out_Force_Trig,
      output reg            Out_Start_Readout1,
      output reg            Out_Start_Readout2,
      output reg            Out_Start_Stop_ADG,
      output reg [192:1]    Out_AnaProb_SS1_SS10_PA,
      output reg [128:1]    Out_AnaProb_Thre_Fsb,
      output reg            Select_Main_Backup,
      output reg            Out_Set_Register,
      output reg [3:0]      Out_Sel_Feedback_Capacitance,
      output reg [64:1]     Out_Choose_Channel_Resister,
      output reg [1:0]      Out_Sel_Cali_TA,
      output reg [11:0]     Out_Set_Cali_DAC,
      output reg [9:0]     Out_Set_TA_Thr_DAC_12,
      output reg [9:0]     Out_Set_TA_Thr_DAC_34,
                                                       /* -----Control TA Config module---*/
      output reg [5:1]      Out_TA_Mode,
      output reg            Out_Select_Ramp_ADC,
      output reg [32:1]     Out_Disable_Channel,
      output reg            Out_Start_Config,
      output reg            Out_Select,                /* Select SC or Probregister mode 1 for SC 0 for Probe*/
      output reg            Out_Select_TDC_On,

 //     output [15:0] Out_Ctr_Word,
      output reg            Status_En_Out
    );


localparam  [19:0]    TOTAL_NUM_EX_TRIG = 20'd500;
/*-------Select Ramp_ADC------------*/
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Select_Ramp_ADC                                          <= 1'b0;

  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hfab1)
    Out_Select_Ramp_ADC                                          <= 1'b1;
    
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hfab0)
    Out_Select_Ramp_ADC                                          <= 1'b0;


  else
    Out_Select_Ramp_ADC                                          <= Out_Select_Ramp_ADC;
end
/*--------Sel ADC Test----------*/
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Sel_ADC_Test                                             <= 1'b0;

  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hf301)
    Out_Sel_ADC_Test                                             <= 1'b1;
    
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hf300)
    Out_Sel_ADC_Test                                             <= 1'b0;


  else
    Out_Sel_ADC_Test <= Out_Sel_ADC_Test;
end




/*----Command of Prob Register-----*/



always  @ (posedge clk or negedge reset_n)
  begin
    if(~reset_n)
      begin
        Out_AnaProb_SS1_SS10_PA       <=  192'd0;
      end   
    else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h30)
      begin
        if(in_from_usb_ControlWord[7:0] == 8'd0)
          Out_AnaProb_SS1_SS10_PA     <=  192'd0;
        else
          begin

          Out_AnaProb_SS1_SS10_PA      <=  192'd1 << in_from_usb_ControlWord[7:0]-1;
          end



      end   
    else
      Out_AnaProb_SS1_SS10_PA         <=  Out_AnaProb_SS1_SS10_PA;

  end   





  always  @ (posedge clk or negedge reset_n)
  begin
    if(~reset_n)
      begin
        Out_AnaProb_Thre_Fsb       <=  128'd0;
      end   
    else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h31)
      begin
        if(in_from_usb_ControlWord[7:0] == 8'd0)
          Out_AnaProb_Thre_Fsb     <=  128'd0;
        else
          begin

          Out_AnaProb_Thre_Fsb      <=  128'd1 << in_from_usb_ControlWord[7:0]-1;
          end



      end   
    else
      Out_AnaProb_Thre_Fsb         <=  Out_AnaProb_Thre_Fsb;

  end  



always  @ (posedge clk or negedge reset_n)
  begin
    if(~reset_n)
      begin
        Out_Choose_Channel_Resister       <=  64'd0;
      end   
    else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h34)
      begin
        if(in_from_usb_ControlWord[7:0] == 8'd0)
          Out_Choose_Channel_Resister     <=  64'd0;
        else
          begin

          Out_Choose_Channel_Resister      <=  64'd1 << in_from_usb_ControlWord[7:0]-1;
          end



      end   
    else
      Out_Choose_Channel_Resister         <=  Out_Choose_Channel_Resister;

  end   
/*
always @ (posedge clk or negedge reset_n)
  begin
    if(~reset_n)
      begin
   
        Cnt_AnaProb_SS1         <=  8'd0;
        Out_AnaProb_SS1_SS10_PA <=  192'd0;
      end   
    else
      begin
        case(State_SS1)
          IDLE_SS1:
            begin
              if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h30)
                begin
                  State_SS1             <=  RST_SS1;
                end   
              else
                begin
                  State_SS1             <=  IDLE_SS1;

                end   
            end   

        endcase         
      end   
  end   
  */

 
 /*always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
          Out_AnaProb_SS1_SS10_PA                                <=  192'd0;
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h30)
       begin
         for(Cnt_SS1_Prob = 1; Cnt_SS1_Prob <= 192;Cnt_SS1_Prob = Cnt_SS1_Prob + 1'b1)
           begin
               Out_AnaProb_SS1_SS10_PA[Cnt_SS1_Prob] <= (Cnt_SS1_Prob == in_from_usb_ControlWord[7:0] ) ? 1'b1: 1'b0;
           end    
       end    
     else
       begin
         Out_AnaProb_SS1_SS10_PA                               <=  Out_AnaProb_SS1_SS10_PA;            
       end    
   end    
*/

    

/*-----Set TA Mode-----*/
 always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
         Out_TA_Mode                                <=  5'b1_1000;
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:4] == 12'hac0)
       begin
         Out_TA_Mode[5:4]                           <=  in_from_usb_ControlWord[1:0];
       end    
     else
       begin
         Out_TA_Mode                                <=  Out_TA_Mode;            
       end    
   end    
/*-----TA_Disable_Channel---*/

 always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
         Out_Disable_Channel                        <=  32'h0;
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'hbb)
       begin
         case(in_from_usb_ControlWord[7:0])
           8'd0:
              Out_Disable_Channel                   <=  32'h0;
           8'd1:
              Out_Disable_Channel                   <=  32'b0111_1111_1111_1111_1111_1111_1111_1111;
           8'd2:
              Out_Disable_Channel                   <=  32'b1011_1111_1111_1111_1111_1111_1111_1111;
           8'd3:
              Out_Disable_Channel                   <=  32'b1101_1111_1111_1111_1111_1111_1111_1111;
           8'd4:
              Out_Disable_Channel                   <=  32'b1110_1111_1111_1111_1111_1111_1111_1111;
           8'd5:
              Out_Disable_Channel                   <=  32'b1111_0111_1111_1111_1111_1111_1111_1111;
           8'd6:
              Out_Disable_Channel                   <=  32'b1111_1011_1111_1111_1111_1111_1111_1111;
           8'd7:
              Out_Disable_Channel                   <=  32'b1111_1101_1111_1111_1111_1111_1111_1111;
           8'd8:
              Out_Disable_Channel                   <=  32'b1111_1110_1111_1111_1111_1111_1111_1111;
           8'd9:
              Out_Disable_Channel                   <=  32'b1111_1111_0111_1111_1111_1111_1111_1111;
           8'd10:
              Out_Disable_Channel                   <=  32'b1111_1111_1011_1111_1111_1111_1111_1111;
           8'd11:
              Out_Disable_Channel                   <=  32'b1111_1111_1101_1111_1111_1111_1111_1111;
           8'd12:
              Out_Disable_Channel                   <=  32'b1111_1111_1110_1111_1111_1111_1111_1111;
           8'd13:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_0111_1111_1111_1111_1111;
           8'd14:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1011_1111_1111_1111_1111;
           8'd15:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1101_1111_1111_1111_1111;
           8'd16:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1110_1111_1111_1111_1111;
           8'd17:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_0111_1111_1111_1111;
           8'd18:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1011_1111_1111_1111;
           8'd19:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1101_1111_1111_1111;
           8'd20:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1110_1111_1111_1111;
           8'd21:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_0111_1111_1111;
           8'd22:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1011_1111_1111;
           8'd23:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1101_1111_1111;
           8'd24:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1110_1111_1111;
           8'd25:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_0111_1111;
           8'd26:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1011_1111;
           8'd27:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1101_1111;
           8'd28:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1110_1111;
           8'd29:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1111_0111;
           8'd30:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1111_1011;
           8'd31:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1111_1101;
           8'd32:
              Out_Disable_Channel                   <=  32'b1111_1111_1111_1111_1111_1111_1111_1110;
           default:
              Out_Disable_Channel                   <=  32'h0;
         endcase                            
       end
     else
       begin
         Out_Disable_Channel                        <=  Out_Disable_Channel;            
       end    
   end    

/*-----Send Config start signal-----*/

//command process

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Hold                             <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffb1)
    Out_Hold                             <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffb0)
    Out_Hold                             <= 1'b0;
  else
    Out_Hold                             <= Out_Hold;
end

/*-----Control ADG start stop----*/
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Start_Stop_ADG                             <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h0033)
    Out_Start_Stop_ADG                             <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h0044)
    Out_Start_Stop_ADG                             <= 1'b0;
  else
    Out_Start_Stop_ADG                             <= Out_Start_Stop_ADG;
end
/*----------------Select main or backup---------*/
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Select_Main_Backup                             <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hfd03)     //main
    Select_Main_Backup                             <= 1'b1;                  
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hfd04)     //backup
    Select_Main_Backup                             <= 1'b0;
  else
    Select_Main_Backup                             <= Select_Main_Backup;
end



//Select work mode
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Sel_Work_Mode                             <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hfd40)     //normal mode
    Out_Sel_Work_Mode                             <= 1'b0;                  
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hfd41)     //Cali mode
    Out_Sel_Work_Mode                             <= 1'b1;
  else
    Out_Sel_Work_Mode                             <= Out_Sel_Work_Mode;
end

// Control ADG Switch 1 for closed 
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_ADG_Switch                             <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h0f00)
    Out_ADG_Switch                             <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h0f01)
    Out_ADG_Switch                             <= 1'b1;
  else
    Out_ADG_Switch                             <= Out_ADG_Switch;
end


//Set DAC Code for Cali and TA thr

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_TA_Thr_DAC_12 <= 10'h3FF;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'b0001)
    begin
    Out_Set_TA_Thr_DAC_12[0] <=     in_from_usb_ControlWord[9];
    Out_Set_TA_Thr_DAC_12[1] <=     in_from_usb_ControlWord[8];
    Out_Set_TA_Thr_DAC_12[2] <=     in_from_usb_ControlWord[7];
    Out_Set_TA_Thr_DAC_12[3] <=     in_from_usb_ControlWord[6];
    Out_Set_TA_Thr_DAC_12[4] <=     in_from_usb_ControlWord[5];
    Out_Set_TA_Thr_DAC_12[5] <=     in_from_usb_ControlWord[4];
    Out_Set_TA_Thr_DAC_12[6] <=     in_from_usb_ControlWord[3];
    Out_Set_TA_Thr_DAC_12[7] <=     in_from_usb_ControlWord[2];
    Out_Set_TA_Thr_DAC_12[8] <=     in_from_usb_ControlWord[1];
    Out_Set_TA_Thr_DAC_12[9] <=     in_from_usb_ControlWord[0];


    end


    else
    Out_Set_TA_Thr_DAC_12 <= Out_Set_TA_Thr_DAC_12;
end


always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_TA_Thr_DAC_34 <= 10'h3FF;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'h4)
  begin
    Out_Set_TA_Thr_DAC_34[0] <=     in_from_usb_ControlWord[9];
    Out_Set_TA_Thr_DAC_34[1] <=     in_from_usb_ControlWord[8];
    Out_Set_TA_Thr_DAC_34[2] <=     in_from_usb_ControlWord[7];
    Out_Set_TA_Thr_DAC_34[3] <=     in_from_usb_ControlWord[6];
    Out_Set_TA_Thr_DAC_34[4] <=     in_from_usb_ControlWord[5];
    Out_Set_TA_Thr_DAC_34[5] <=     in_from_usb_ControlWord[4];
    Out_Set_TA_Thr_DAC_34[6] <=     in_from_usb_ControlWord[3];
    Out_Set_TA_Thr_DAC_34[7] <=     in_from_usb_ControlWord[2];
    Out_Set_TA_Thr_DAC_34[8] <=     in_from_usb_ControlWord[1];
    Out_Set_TA_Thr_DAC_34[9] <=     in_from_usb_ControlWord[0];
  end
    
    else
    Out_Set_TA_Thr_DAC_34 <= Out_Set_TA_Thr_DAC_34;
end



always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_Cali_DAC <= 12'h500;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'b0101)
    Out_Set_Cali_DAC <= in_from_usb_ControlWord[11:0];
    else
    Out_Set_Cali_DAC <= Out_Set_Cali_DAC;
end


always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Sel_Cali_TA <= 2'b00;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'd5)   //5 for Cali DAC     1-4  for TA DAC
    Out_Sel_Cali_TA <= 2'b00;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'd1)
    Out_Sel_Cali_TA <= 2'b10;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'd2)
    Out_Sel_Cali_TA <= 2'b10;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'd3)
    Out_Sel_Cali_TA <= 2'b11;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'd4)
    Out_Sel_Cali_TA <= 2'b11;
  else
    Out_Sel_Cali_TA <= Out_Sel_Cali_TA;
end





/*--------Start_Set_DAC last for 10 Cycles------*/
localparam    [3:0]   STATE_SET_DAC_IDLE = 4'd0,
                      STATE_SET_DAC_LOOP = 4'd1;
reg [3:0]             State,
                      State_Next;
reg [7:0]             Cnt_State;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State               <=  STATE_SET_DAC_IDLE;
      Out_Start_Config    <=  1'b0;
                Cnt_State         <=  8'd0;
    end   
  else
    begin
      case(State)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h00b1)
              begin
                State     <=  STATE_SET_DAC_LOOP;
                Out_Start_Config  <=  1'b1;
                Cnt_State         <=  8'd0;
              end   
            else
              begin
                State     <=  STATE_SET_DAC_IDLE;
                Cnt_State         <=  8'd0;
                Out_Start_Config    <=  1'b0;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State > 8'd16)
              begin
                State     <=  STATE_SET_DAC_IDLE;
                Out_Start_Config  <=  1'b0;
                Cnt_State         <=  8'd0;
              end   
            else
              begin
                State       <=  STATE_SET_DAC_LOOP;
                Cnt_State   <=  Cnt_State + 1'b1;
                Out_Start_Config    <=  1'b1;
              end   
          end   
      endcase
    end   

end
/*-------------Reset ASIC------------------*/


reg [3:0]             State_Reset;
                      
reg [7:0]             Cnt_State_Reset;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State_Reset               <=  STATE_SET_DAC_IDLE;
      Out_Reset_ASIC_b    <=  1'b1;
                Cnt_State_Reset         <=  8'd0;
    end   
  else
    begin
      case(State_Reset)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffc0)
              begin
                State_Reset     <=  STATE_SET_DAC_LOOP;
                Out_Reset_ASIC_b  <=  1'b0;
                Cnt_State_Reset         <=  8'd0;
              end   
            else
              begin
                State_Reset     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Reset         <=  8'd0;
                Out_Reset_ASIC_b    <=  1'b1;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Reset > 8'd30)
              begin
                State_Reset     <=  STATE_SET_DAC_IDLE;
                Out_Reset_ASIC_b  <=  1'b1;
                Cnt_State_Reset         <=  8'd0;
              end   
            else
              begin
                State_Reset       <=  STATE_SET_DAC_LOOP;
                Cnt_State_Reset   <=  Cnt_State_Reset + 1'b1;
                Out_Reset_ASIC_b    <=  1'b0;
              end   
          end   
      endcase
    end   

end
/*------------Start Register--------------------*/
reg [3:0]             State_Rigister;
                      
reg [7:0]             Cnt_State_Rigister;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State_Rigister               <=  STATE_SET_DAC_IDLE;
      Out_Set_Register    <=  1'b0;
                Cnt_State_Rigister         <=  8'd0;
    end   
  else
    begin
       State_Rigister     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Rigister         <=  8'd0;
                Out_Set_Register    <=  1'b0;
      case(State_Rigister)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h00b2)
              begin
                State_Rigister     <=  STATE_SET_DAC_LOOP;
                Out_Set_Register  <=  1'b1;
                Cnt_State_Rigister         <=  8'd0;
              end   
            else
              begin
                State_Rigister     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Rigister         <=  8'd0;
                Out_Set_Register    <=  1'b0;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Rigister > 8'd20) //2means last for 60ns
              begin
                State_Rigister     <=  STATE_SET_DAC_IDLE;
                Out_Set_Register  <=  1'b0;
                Cnt_State_Rigister         <=  8'd0;
              end   
            else
              begin
                State_Rigister       <=  STATE_SET_DAC_LOOP;
                Cnt_State_Rigister   <=  Cnt_State_Rigister + 1'b1;
                Out_Set_Register    <=  1'b1;
              end   
          end   
      endcase
    end   

end


/*-------------------Start_Convb------------------*/

reg [3:0]             State_Convb;
                      
reg [7:0]             Cnt_State_Conv;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State_Convb               <=  STATE_SET_DAC_IDLE;
      Out_Start_Conver_b    <=  1'b0;
                Cnt_State_Conv         <=  8'd0;
    end   
  else
    begin
      case(State_Convb)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffd0)
              begin
                State_Convb     <=  STATE_SET_DAC_LOOP;
                Out_Start_Conver_b  <=  1'b1;
                Cnt_State_Conv         <=  8'd0;
              end   
            else
              begin
                State_Convb     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Conv         <=  8'd0;
                Out_Start_Conver_b    <=  1'b0;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Conv > 8'd40) //2means last for 37.5ns 40means 500+12.5
              begin
                State_Convb     <=  STATE_SET_DAC_IDLE;
                Out_Start_Conver_b  <=  1'b0;
                Cnt_State_Conv         <=  8'd0;
              end   
            else
              begin
                State_Convb       <=  STATE_SET_DAC_LOOP;
                Cnt_State_Conv   <=  Cnt_State_Conv + 1'b1;
                Out_Start_Conver_b    <=  1'b1;
              end   
          end   
      endcase
    end   

end


/*----------------------Force trigger--------------------*/
reg [3:0]             State_Trig;
                      
reg [7:0]             Cnt_State_Trig;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State_Trig               <=  STATE_SET_DAC_IDLE;
      Out_Force_Trig    <=  1'b0;
                Cnt_State_Trig         <=  8'd0;
    end   
  else
    begin
      case(State_Trig)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffe0)
              begin
                State_Trig     <=  STATE_SET_DAC_LOOP;
                Out_Force_Trig  <=  1'b1;
                Cnt_State_Trig         <=  Cnt_State_Trig + 1'b1;
              end   
            else
              begin
                State_Trig     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Trig         <=  8'd0;
                Out_Force_Trig    <=  1'b0;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Trig > 8'd40)//1 means 2clk 40ns 40 means 500ns
              begin
                State_Trig     <=  STATE_SET_DAC_IDLE;
                Out_Force_Trig  <=  1'b0;
                Cnt_State_Trig         <=  8'd0;
              end   
            else
              begin
                State_Trig       <=  STATE_SET_DAC_LOOP;
                Cnt_State_Trig   <=  Cnt_State_Trig + 1'b1;
                Out_Force_Trig    <=  1'b1;
              end   
          end   
      endcase
    end   

end

/*-------------------------Start_Readout---------------*/
reg [3:0]             State_Readout;
                      
reg [7:0]             Cnt_State_Readout;
              

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    begin
      State_Readout               <=  STATE_SET_DAC_IDLE;
      Out_Start_Readout1    <=  1'b0;
      Out_Start_Readout2    <=  1'b1;
                Cnt_State_Readout         <=  8'd0;
    end   
  else
    begin
      case(State_Readout)
        STATE_SET_DAC_IDLE:
          begin
            if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffe3)
              begin
                State_Readout     <=  STATE_SET_DAC_LOOP;
                Out_Start_Readout1  <=  1'b1;
                Out_Start_Readout2  <=  1'b0;
                Cnt_State_Readout         <=  8'd0;
              end   
            else
              begin
                State_Readout     <=  STATE_SET_DAC_IDLE;
                Cnt_State_Readout         <=  8'd0;
                Out_Start_Readout1    <=  1'b0;
                Out_Start_Readout2    <=  1'b1;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Readout > 8'd25)
              begin
                State_Readout     <=  STATE_SET_DAC_IDLE;
                Out_Start_Readout1  <=  1'b0;
                Out_Start_Readout2  <=  1'b1;
                Cnt_State_Readout         <=  8'd0;
              end   
            else
              begin
                State_Readout       <=  STATE_SET_DAC_LOOP;
                Cnt_State_Readout   <=  Cnt_State_Readout + 1'b1;
                Out_Start_Readout1    <=  1'b1;
                Out_Start_Readout2    <=  1'b0;
              end   
          end   
      endcase
    end   

end






always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Start_Acq <= 1'b1;

  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hffa1)
    Out_Start_Acq <= 1'b1;
    
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:0] == 16'hffa0)
    Out_Start_Acq <= 1'b0;


  else
    Out_Start_Acq <= Out_Start_Acq;
end
/*---------Sel Feedback capacitance------*/
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Sel_Feedback_Capacitance <= 4'b1111;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:4] == 12'haca)
    Out_Sel_Feedback_Capacitance <= in_from_usb_ControlWord[3:0];
    else
    Out_Sel_Feedback_Capacitance <= Out_Sel_Feedback_Capacitance;
end

//set Trigtime of Inside mode 0~256
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_Trig_Inside_Time <= 8'd1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'hab)
    Out_Set_Trig_Inside_Time <= in_from_usb_ControlWord[7:0];
    else
    Out_Set_Trig_Inside_Time <= Out_Set_Trig_Inside_Time;
end



//Set Delay time default 1us 50cyc
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_Hold_Delay_Time  <= 12'd1560;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:12] == 4'h6)
    Out_Set_Hold_Delay_Time <= in_from_usb_ControlWord[11:0];
    else
    Out_Set_Hold_Delay_Time <= Out_Set_Hold_Delay_Time;
end





//Set Out_Set_Constant_Interval_Time for Constant ADC 
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Set_Constant_Interval_Time <= 14'd20;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:14] == 2'b01)
    Out_Set_Constant_Interval_Time <= in_from_usb_ControlWord[13:0];
    else
    Out_Set_Constant_Interval_Time <= Out_Set_Constant_Interval_Time;
end




always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    out_to_usb_Acq_Start_Stop <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hf0f1)
    out_to_usb_Acq_Start_Stop <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hf0f0)
    out_to_usb_Acq_Start_Stop <= 1'b0;
  else if(Cnt_Trig    >=  TOTAL_NUM_EX_TRIG)
  begin
    out_to_usb_Acq_Start_Stop <=  1'b0;
  end   
  else
    out_to_usb_Acq_Start_Stop <= out_to_usb_Acq_Start_Stop;
end





//Status module Enabled and disabled  55aa eb90
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Status_En_Out <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h55aa)
    Status_En_Out <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'heb90)
    Status_En_Out <= 1'b0;
  else
    Status_En_Out <= Status_En_Out;
end





//Control Trig mode to Trig_Gen module
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Control_Trig_Mode <= 4'b0001;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'haa01) //Inside Mode
    Out_Control_Trig_Mode <= 4'b0001;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'haa02) //Ex Mode
    Out_Control_Trig_Mode <= 4'b0010;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'haa03) // Self Mode OR
    Out_Control_Trig_Mode <= 4'b0100;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'haa04) // Self Mode AND
    Out_Control_Trig_Mode <= 4'b1000;
 
  else 
    Out_Control_Trig_Mode <= Out_Control_Trig_Mode;
end

//Select Which TA to use
always @ (posedge clk or negedge reset_n)
  begin
    if(~reset_n)
      begin
        Out_Valid_TA_for_Self_Mod           <=  4'b1111;
      end   
    else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:4]  ==  12'h920)
      begin
        Out_Valid_TA_for_Self_Mod           <=  in_from_usb_ControlWord[3:0];
      end   
    else
      begin
        Out_Valid_TA_for_Self_Mod           <=  Out_Valid_TA_for_Self_Mod;
      end   

  end   


//Control Trig Mode
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Out_Trig_Start_Stop <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h00a1)
    Out_Trig_Start_Stop <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h00a0)
    Out_Trig_Start_Stop <= 1'b0;
  else
    Out_Trig_Start_Stop <= Out_Trig_Start_Stop;
end




//clear usb data fifo a0f0
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    out_to_control_usb_data <= 1'b1;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'ha0f0)
   out_to_control_usb_data <= 1'b0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'ha0f1)
    out_to_control_usb_data <= 1'b1;
  else 
    out_to_control_usb_data <= out_to_control_usb_data;
end




//led interface
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    LED <= 6'b11_1111;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'h00)
    LED <= in_from_usb_ControlWord[5:0];
  else if (in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h55aa)
    LED <= 6'b11_1111;
  else if (in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'h45aa)
    LED <= 6'b11_0000;
  else 
    LED <= LED;
  
end
/*-----Select Mode-----*/
 always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
         Out_Select                                <=  1'b1;
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hbb01)
       begin
         Out_Select                                <=  1'b1;
       end    
      else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hbb00)
       begin
         Out_Select                                <=  1'b0;

       end    
      else
        begin
          Out_Select                                <=  Out_Select;
        end   
   end    
/*--------------------Out_Select_TDC_On----------------*/
 always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
         Out_Select_TDC_On                                <=  1'b1;
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hf901)
       begin
         Out_Select_TDC_On                                <=  1'b1;
       end    
      else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hf900)
       begin
         Out_Select_TDC_On                                <=  1'b0;

       end    
      else
        begin
          Out_Select_TDC_On                                <=  Out_Select_TDC_On;
        end   
   end   
endmodule
