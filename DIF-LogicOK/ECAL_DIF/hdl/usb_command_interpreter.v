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

      input                 clk,
      input                 reset_n,
                                                       /* --------USB interface------------*/
      input                 in_from_usb_Ctr_rd_en,
      input [15:0]          in_from_usb_ControlWord,
      input [19:0]          Cnt_Trig,
      output             out_to_usb_Acq_Start_Stop,
                                                       /* -------clear usb fifo------------*/
      output             out_to_control_usb_data,   // control USB choose input Data ADC_Constant_Data or Normal Data
                                                       /* -------LED test------------------*/
      output reg [5:0]      LED,
                                                       /* ------Select Work mode-----------*/
      output             Out_Sel_Work_Mode,
			output reg [4:1]      Out_DAC_Adj_Chn64,
                                                       /* ------Control Trig and ADC module--------*/
      output reg [4:1]      Out_Valid_TA_for_Self_Mod, // Control which TA to use for Self Trig mode  1111for all use 0001for only use TA1
			output             Out_Val_Evt,               //Default 1 En discriminator

      output             Out_Trig_Start_Stop, 
 			output             Out_Sel_OnlyExTrig,	
      output             Out_Hold,
      output reg [3:0]   Out_Control_Trig_Mode,
			output  [8:1]      Out_Delay_Trig_Temp, //Set Delay time. order is from MSB to LSB
      output  [7:0]      Out_Set_Trig_Inside_Time, 
      output  [13:0]     Out_Set_Constant_Interval_Time,
      output  [11:0]     Out_Set_Hold_Delay_Time,
	    output  [4:1]      Out_Set_Hv_1, //highest bit
			output 	[4:1]	     Out_Set_Hv_2,
			output  [4:1]      Out_Set_Hv_3,
		  output  [4:1]      Out_Set_Hv_4,//lowest bit
	
                                                       /* ---------Control ADG-----------*/
      output             Out_Sel_ADC_Test,
      output             Out_ADG_Switch,

      output             Out_Reset_ASIC_b,
      output             Out_Start_Acq,
      output             Out_Start_Conver_b,
      output             Out_Force_Trig,
      output             Out_Start_Readout1,
			output             Out_Start_Cfg_Hv,
			output             Out_Start_Stop_Hv,
			output 		         Out_Flag_Start_Stop_Hv,	
      output reg         Out_Start_Readout2,
      output             Out_Start_Stop_ADG,
      output reg [192:1]    Out_AnaProb_SS1_SS10_PA,
      output reg [128:1]    Out_AnaProb_Thre_Fsb,
      output             Select_Main_Backup,
      output             Out_Set_Register,
      output  [3:0]      Out_Sel_Feedback_Capacitance,
      output reg [64:1]     Out_Choose_Channel_Resister,
			output reg [64:1] 		Out_Set_Mask64,
      output reg [1:0]      Out_Sel_Cali_TA,
      output  [11:0]     Out_Set_Cali_DAC,
      output reg [9:0]     Out_Set_TA_Thr_DAC_12,
      output reg [9:0]     Out_Set_TA_Thr_DAC_34,
                                                       /* -----Control TA Config module---*/
      output reg [5:1]      Out_TA_Mode,
      output             Out_Select_Ramp_ADC,
      output reg [32:1]     Out_Disable_Channel,
      output             Out_Start_Config,
      output             Out_Select,                /* Select SC or Probregister mode 1 for SC 0 for Probe*/
      output             Out_Select_TDC_On,

 //     output [15:0] Out_Ctr_Word,
      output             Status_En_Out
    );


localparam  [19:0]    TOTAL_NUM_EX_TRIG = 20'd500;
	wire Sig_Start_Hv;
	wire Sig_Stop_Hv;

/*--------Select Only Extrig or in and ex------*/
Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hf5f1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hf5f0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Sel_OnlyExTrig(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Sel_OnlyExTrig)       // Output Signal
    );
	
	

/*--------Set Trig Delay time of SKIROC2-----*/

		Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd8),
 .LENGTH_VALUE(4'd8),
 .EFFECT_CMD(8'hf4),
 .DEFAULT_VALUE(8'h70))
	Cmd_Out_Delay_Trig_Temp(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Delay_Trig_Temp)
    );	
	


/*---------Disable Val_Evt---------*/
Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hf2f1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hf2f0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Out_Val_Evt(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Val_Evt)       // Output Signal
    );
	

	
/*-------Set Chn64 DAC Adjustment 4 bit------*/
always @ (posedge clk or negedge reset_n)
begin
  if(~reset_n)
    Out_DAC_Adj_Chn64 <= 4'd0;
  else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:4] == 12'hf1f)
    Out_DAC_Adj_Chn64 <= in_from_usb_ControlWord[3:0];
    else
    Out_DAC_Adj_Chn64 <= Out_DAC_Adj_Chn64;
end

/*-------Set Mask Channel------------*/
	 always @ (posedge clk or negedge reset_n)                        
   begin
     if(~reset_n)
       begin
         Out_Set_Mask64                                <=  64'd0;        // Set Mask Channels 0means no mask 64~1 means mask 0~63 Channel. Defult no mask
       end    
     else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffdf)
       begin
         Out_Set_Mask64                                <=  64'd0;                // Set no mask
       end    
      else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffde)
       begin
         Out_Set_Mask64                                <=  64'hfffffffffffffffe;
       end    
       else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffdd)
       begin
         Out_Set_Mask64                                <=  64'h10200001;         // Mask 36 43 64
       end    
       else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord == 16'hffdc)
       begin
         Out_Set_Mask64                                <=  64'hffffffffffffffff; // Mask all
       end    
		 	 else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'hfc)
			 begin
				 Out_Set_Mask64[65-in_from_usb_ControlWord[7:0]] <= 1'b1;
			 end		
		 	 else if(in_from_usb_Ctr_rd_en && in_from_usb_ControlWord[15:8] == 8'hfb)
			 begin
				 Out_Set_Mask64[65-in_from_usb_ControlWord[7:0]] <= 1'b0;
			 end		
			 else
        begin
          Out_Set_Mask64                                <=  Out_Set_Mask64;
        end   
   end    

/*-------Select Ramp_ADC------------*/
Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hfab1),              // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hfab0),              // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )               // Set the default value
	 Cmd_Out_Select_Ramp_ADC(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),         // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),        // input Cmd_En
    .Output_Valid_Sig(Out_Select_Ramp_ADC) // Output Signal
    );
	

/*--------Sel ADC Test----------*/
Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hf301), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hf300), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Sel_ADC_Test(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Sel_ADC_Test)       // Output Signal
    );

	


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
Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hffb1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hffb0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Hold(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Hold)       // Output Signal
    );


/*-----Control ADG start stop----*/
	Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'h0033), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'h0044), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Start_Stop_ADG(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Start_Stop_ADG)       // Output Signal
    );

	

/*----------------Select main or backup---------*/

	
		Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hfd03), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hfd04), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Select_Main_Backup(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Select_Main_Backup)       // Output Signal
    );
	




//Select work mode

	Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hfd41), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hfd40), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Sel_Work_Mode(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Sel_Work_Mode)       // Output Signal
    );
	
	


// Control ADG Switch 1 for closed 

		Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'h0f01), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'h0f00), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_ADG_Switch(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_ADG_Switch)       // Output Signal
    );
	



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

	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd4),
 .LENGTH_VALUE(4'd12),
 .EFFECT_CMD(4'b0101),
 .DEFAULT_VALUE(12'h500))
	Cmd_Out_Set_Cali_DAC(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Cali_DAC)
    );		




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


Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'h00b1), // Input effect words
		.LAST_CYC(8'd17))       // Input Last Cyc
		Cmd_Out_Start_Config(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Start_Config)
    );
	

/*-------------Reset ASIC------------------*/
Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hffc0), // Input effect words
		.LAST_CYC(8'd31))       // Input Last Cyc
		Cmd_Out_Reset_ASIC_b(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(~Out_Reset_ASIC_b)
    );


/*------------Start Register--------------------*/

Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'h00b2), // Input effect words
		.LAST_CYC(8'd21))       // Input Last Cyc
		Cmd_Out_Set_Register(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Register)
    );	
	


/*-------------------Start_Convb------------------*/
Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hffd0), // Input effect words
		.LAST_CYC(8'd41))       // Input Last Cyc
		Cmd_Out_Start_Conver_b(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Start_Conver_b)
    );


/*----------------------Force trigger--------------------*/
Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hffe0), // Input effect words
		.LAST_CYC(8'd6))       // Input Last Cyc
		Cmd_Out_Force_Trig(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Force_Trig)
    );
	

/*-------------------------Start_Readout---------------*/

Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hffe3), // Input effect words
		.LAST_CYC(8'd26))       // Input Last Cyc
		Cmd_Out_Start_Readout1(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Start_Readout1)
    );	
	




	Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hffa1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hffa0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Out_Start_Acq(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Start_Acq)       // Output Signal
    );


/*---------Sel Feedback capacitance------*/

	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'haca),
 .DEFAULT_VALUE(4'b1111))
	Cmd_Out_Sel_Feedback_Capacitance(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Sel_Feedback_Capacitance)
    );			
	


//set Trigtime of Inside mode 0~256
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd8),
 .LENGTH_VALUE(4'd8),
 .EFFECT_CMD(8'hab),
 .DEFAULT_VALUE(8'd1))
	Cmd_Out_Set_Trig_Inside_Time(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Trig_Inside_Time)
    );		
	
	




//Set Delay time default 1us 50cyc

Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd4),
 .LENGTH_VALUE(4'd12),
 .EFFECT_CMD(4'h6),
 .DEFAULT_VALUE(12'h3ff))
	Cmd_Out_Set_Hold_Delay_Time(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Hold_Delay_Time)
    );		
	
	




//Set Out_Set_Constant_Interval_Time for Constant ADC 
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd2),
 .LENGTH_VALUE(4'd14),
 .EFFECT_CMD(2'b01),
 .DEFAULT_VALUE(14'd20))
	Cmd_Out_Set_Constant_Interval_Time(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Constant_Interval_Time)
    );		
	



 Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hf0f1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hf0f0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_out_to_usb_Acq_Start_Stop(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(out_to_usb_Acq_Start_Stop)       // Output Signal
    );






//Status module Enabled and disabled  55aa eb90

 Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'h55aa), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'heb90), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Status_En_Out(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Status_En_Out)       // Output Signal
    );
	
	





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

	Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'h00a1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'h00a0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b0)	 )  // Set the default value
	 Cmd_Out_Trig_Start_Stop(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Trig_Start_Stop)       // Output Signal
    );
	





//clear usb data fifo a0f0
	
	 Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'ha0f1), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'ha0f0), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_out_to_control_usb_data(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(out_to_control_usb_data)       // Output Signal
    );





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
  Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hbb01), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hbb00), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Out_Select(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Select)       // Output Signal
    );
	

/*--------------------Out_Select_TDC_On----------------*/
  Cmd_Boolean_Set
 	 #(.EFFECT_1_CMD(16'hf901), // Set the Cmd to set output 1
		 .EFFECT_0_CMD(16'hf900), // Set the Cmd to set output 0
		 .DEFAULT_VALUE(1'b1)	 )  // Set the default value
	 Cmd_Out_Select_TDC_On(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd(in_from_usb_ControlWord),                // input Cmd
    .Cmd_En(in_from_usb_Ctr_rd_en),          // input Cmd_En
    .Output_Valid_Sig(Out_Select_TDC_On)       // Output Signal
    );
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'hd13),
 .DEFAULT_VALUE(4'd0))
	Cmd_Out_Set_Hv_1(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Hv_1)
    );		
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'hd12),
 .DEFAULT_VALUE(4'd0))
	Cmd_Out_Set_Hv_2(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Hv_2)
    );		
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'hd11),
 .DEFAULT_VALUE(4'd0))
	Cmd_Out_Set_Hv_3(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Hv_3)
    );		
	
	Cmd_Set_N_Bits_Value  
	#(
 .LENGTH_CMD(4'd12),
 .LENGTH_VALUE(4'd4),
 .EFFECT_CMD(12'hd10),
 .DEFAULT_VALUE(4'd0))
	Cmd_Out_Set_Hv_4(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Set_Hv_4)
    );		


	Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hd141), // Input effect words
		.LAST_CYC(8'd10))       // Input Last Cyc
		Cmd_Out_Start_Cfg_Hv(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Out_Start_Cfg_Hv)
    );
Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hd0d0), // Input effect words
		.LAST_CYC(8'd10))       // Input Last Cyc
		Cmd_Out_Start_Hv(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Sig_Start_Hv)
    );
Cmd_Rising_N_Clock 
	#(.EFFECT_CMD(16'hd0d1), // Input effect words
		.LAST_CYC(8'd10))       // Input Last Cyc
		Cmd_Out_Stop_Hv(
    .Clk_In(clk),
    .Rst_N(reset_n),
    .Cmd_In(in_from_usb_ControlWord),
    .Cmd_En(in_from_usb_Ctr_rd_en),
    .Output_Valid_Sig(Sig_Stop_Hv)
    );
	assign Out_Start_Stop_Hv = Sig_Start_Hv || Sig_Stop_Hv;
	assign Out_Start_Readout2 = Out_Start_Readout1;
endmodule
