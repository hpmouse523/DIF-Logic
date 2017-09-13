module Prepare_Register
( 
  input Clk,
  input Rst_N,
  input Start_In,


  /*-----------Slow Control Registers-----------*/    //add parameter when
  // necessary

  input [9:0]       In_DAC_Gain_Select,
  input [9:0]       In_Dac_Trigger,
  input             In_Select_Main_Backup,//select main SCAs of backup SCA
  input [3:0]       In_Sel_Feedback_Capacitance,// 4 bits input  indicate Callback capacitance 1111 means use all 4 capacitances. 1000 means use the smallest cap.
  input [2:0]       In_Sel_Comp_PA, //3bit select compensation capacitances commands default 111
  input             In_Sel_Work_Mode,//0means normal mode  1means Clai mode

  input             In_Sel_ADC_Test,//1means Select ADC test input as input to ADC
  input [7:0]       In_Chip_ID_Bin, // 8 bits Chip ID 
  input             In_Select_TDC_On,


  /*-----------Exfifo--------------------------*/
  output reg        Out_Ex_Fifo_Wr_En,
  output reg  [7:0] Out_Ex_Fifo_Din,

  /*-----------End_Flag-----*/
  output reg        End_Flag
);

wire          [7:0] Sig_Chip_ID_Gray;



wire          [616:1]       Parameter616;
assign        Parameter616[616:615]       =     2'b11;                  //Dout2 and Dout1: 1 meand enable
assign        Parameter616[614:613]       =     2'b11;                  //Enable TransmitOn2 and 1: 1 means Enabled
assign        Parameter616[612]           =     1'b1;                   //ChipSat Enabled :1 Enable
assign        Parameter616[611]           =     1'b1;                   //Start_Readout1 : 1means 1
assign        Parameter616[610]           =     1'b1;                   //End_Readout1   :  1means 1
assign        Parameter616[609]           =     1'b1;                   //LVDS rec On
assign        Parameter616[608]           =     1'b1;                   //Trigout Enable
assign        Parameter616[607]           =     1'b0;                   //Select Trig Ext or Trig In   1means only Ext Trig
assign        Parameter616[606:599]       =     Sig_Chip_ID_Gray;                  //Chip ID FF from MSB to LSB
assign        Parameter616[598]           =     1'b0;                   //Use ASIC commands 
assign        Parameter616[597]           =     1'b0;                   //0 if backup , In = 1
assign        Parameter616[596]           =     1'b0;//In_Force_Aout_High;                   //Use ASIC commands 1 means Ext; 0 means ASIC default 0
assign        Parameter616[595]           =     In_Select_TDC_On;                   //TDC on:1 0 means not use TDC ,force Analogout to Highgain or low gain default 1 if 2Gain output ,0
assign        Parameter616[594]           =     1'b0;                   //12 bits
assign        Parameter616[593]           =     1'b0;                   //No compensation
assign        Parameter616[592]           =     1'b0;                   //Use ASIC command
assign        Parameter616[591]           =     1'b0;                   //power pulsing mode
assign        Parameter616[590]           =     1'b1;                   //ADC ramp enabled
assign        Parameter616[589]           =     1'b1;                   //200ns
assign        Parameter616[588]           =     1'b0;                   //No Compensation
assign        Parameter616[587]           =     1'b0;                   //power pulsing mode of TDC ramp
assign        Parameter616[586]           =     1'b1;                   //TDC Ramp Enabled
assign        Parameter616[585:576]       =     In_DAC_Gain_Select;     //?10-bit DAC (From MSB to LSB) for Gain Select Discriminator Threshold
assign        Parameter616[575:566]       =     In_Dac_Trigger;         // ?10-bit DAC (From MSB to LSB) for Trigger Discriminator Threshold
assign        Parameter616[565]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[564]           =     1'b1;                   //DAC's enabled
assign        Parameter616[563]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[562]           =     1'b1;                   //Bandgap OTA disabled
assign        Parameter616[561]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[560]           =     1'b1;                   //ADC Dis Enabled
assign        Parameter616[559]           =     1'b1;                   //Gs Dis Enabled
assign        Parameter616[558]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[557]           =     In_Sel_ADC_Test;                   //OFF  ADC Test 0OFF 1means select ADC test as ADC input
assign        Parameter616[556]           =     1'b0;                   //No bypass
assign        Parameter616[555]           =     1'b0;                   //High gain:0  low gain :1
assign        Parameter616[554]           =     1'b1;                   //Auto Gain:1 mains auto gaim 0means select 
assign        Parameter616[553:546]       =     8'b00001110;           //Delay for the trigger signals
assign        Parameter616[545]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[544]           =     1'b1;                   //Trig Delay Enabled
assign        Parameter616[543:480]       =     64'b0;   //64'hffffffff00000000;//               //Alows to mask trigger channel 63:0 Low to H 0means no mask  ffffffff00000000 means mask 0~31
assign        Parameter616[479:224]       =     256'b0;                 //Discri 4bit DAC from channel0-63 (from 0-63) recommend 0001 , now is 0000
assign        Parameter616[223]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[222]           =     1'b1;                   //Trigger enabled
assign        Parameter616[221]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[220]           =     1'b1;                   //Adjustment Enabled
assign        Parameter616[219]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[218]           =     1'b1;                   //Prob Enabled Enable prob OTA 
assign        Parameter616[217]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[216]           =     1'b1;                   //Output OTA Enabled
assign        Parameter616[215]           =     1'b0;                   //Weak bias
assign        Parameter616[214]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[213]           =     1'b1;                   //Backup SCA Enabled
assign        Parameter616[212]           =     In_Select_Main_Backup;                   //15 depth SCA or backup 0means 15SCA default 0
assign        Parameter616[211]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[210]           =     1'b1;                   //SCA Enabled
assign        Parameter616[209:208]       =     2'b00;                  //Fast shaper time constant commands
assign        Parameter616[207]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[206]           =     1'b1;                   //Fast shaper Enabled
assign        Parameter616[205]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[204]           =     1'b1;                   //SS_G10 Enable slow shaper G10
assign        Parameter616[203]           =     1'b0;                   //Power Pulsing mode
assign        Parameter616[202]           =     1'b1;                   //Enable slow shaper G1 1 Enabled
assign        Parameter616[201:10]        =   (In_Sel_Work_Mode == 1'b0)?192'h0:192'h924924924924924924924924924924924924924924924924;//924means 100 which means high leakge normal mode//192'h492492492492492492492492492492492492492492492492; // 192'b0;  492means 010 all  cali             //All PA on No Ctest weak leakage  110means on ,high leakege cali mode
assign        Parameter616[9:6]           =     In_Sel_Feedback_Capacitance;                //PreAmp feedback capacitance commands
assign        Parameter616[5:3]           =     In_Sel_Comp_PA;                 //PreAmp compensation capacitances commands (2бн0)
assign        Parameter616[2]             =     1'b0;                   //Power Pulsing mode
assign        Parameter616[1]             =     1'b1;                   //PA Enabled

/*------------------Tell rising edge of Start_In-------*/
reg                     Start_In_Delay;
always @(posedge Clk)
  begin
    Start_In_Delay        <=    Start_In;
  end   

reg   [616:1]           Para616_Shiftreg;

reg   [3:0]             State,
                        State_Next;
localparam  [3:0]       IDLE                  =   4'd0,
                        STATE_SC_PROCESS      =   4'd1,
                        STATE_SC_LOOP         =   4'd2,
                        STATE_SC_END          =   4'd3;
reg   [11:0]            Cnt_Sc_Num;
localparam  [11:0]      SC_NUM                =   12'd77;//616 / 8



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
                State_Next            = STATE_SC_PROCESS;
              end   
            else
              begin
                State_Next            = IDLE;
              end   
          STATE_SC_PROCESS:
            begin
              State_Next              = STATE_SC_LOOP;
            end   
          STATE_SC_LOOP:
            begin
              if(Cnt_Sc_Num     < SC_NUM - 1'b1)
                begin
                  State_Next          = STATE_SC_PROCESS;
                end   
              else
                begin
                  State_Next          = STATE_SC_END;
                end   
            end   
          STATE_SC_END:
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
        Out_Ex_Fifo_Wr_En             <=  1'b0;
        Out_Ex_Fifo_Din               <=  8'b0;

        Cnt_Sc_Num                    <=  12'b0;       
        End_Flag                      <=  1'b0;
      end   
    else
      begin
        case(State)
          IDLE:
            begin
              Out_Ex_Fifo_Wr_En             <=  1'b0;
              Out_Ex_Fifo_Din               <=  8'b0;
              Para616_Shiftreg              <=  Parameter616;
              Cnt_Sc_Num                    <=  12'b0;    
              End_Flag                      <=  1'b0;
              
            end   
          STATE_SC_PROCESS:
            begin
              Out_Ex_Fifo_Wr_En             <=  1'b1;
              Out_Ex_Fifo_Din               <=  Para616_Shiftreg[616:609];
              Para616_Shiftreg              <=  Para616_Shiftreg;
              End_Flag                      <=  1'b0;
              Cnt_Sc_Num                    <=  Cnt_Sc_Num;
            end   
          STATE_SC_LOOP:
            begin
              Out_Ex_Fifo_Wr_En             <=  1'b0;
              Out_Ex_Fifo_Din               <=  Out_Ex_Fifo_Din;
              Para616_Shiftreg              <=  Para616_Shiftreg  << 8;
              End_Flag                      <=  1'b0;
              Cnt_Sc_Num                    <=  Cnt_Sc_Num  + 1'b1;
            end   
          STATE_SC_END:
            begin
              Out_Ex_Fifo_Wr_En             <=  1'b0;
              Out_Ex_Fifo_Din               <=  8'b0;
              Para616_Shiftreg              <=  Parameter616;
              End_Flag                      <=  1'b1;
              Cnt_Sc_Num                    <=  12'b0;
            end   
        endcase 
      end   
  end   


Bin_2_Gray Bin_2_Gray_Inst(
    .In_Bin(In_Chip_ID_Bin),
    .Out_Gray(Sig_Chip_ID_Gray)
    );

endmodule
