/*This module is used to Config TA chip
* TA Chip has 165 bit for Configration.
  * By Siyuan                 2016-05-27*/
 module TA_Config(
 
    input                 Clk,
    input                 Rst_n,
    /*-----Control signals from usb interpreter---*/
    input          [5:1]  In_TA_Mode,                   //Significant Config mode bit 
    input         [32:1]  In_Disable_Channel,           //Disabe Channel for testing every channel, 1 for desable. default all 0.
    input                 In_Start_Config,              //to start Config

    /*-----Output of SSP and GED------------------*/
    output                Out_SSP,                      
    output                Out_GED,
    /*-----Inout of TA160 Chip--------------------*/
    output reg      [4:1] Out_Reg_In,
    input           [4:1] In_Reg_Out,
    output                Out_Clk_TA,
    output reg            Out_Read_Back,
    output reg            Out_Load                      // 1us's impulse

  );
/*-----Signal of CLK_TA------*/
  reg                     Clk_TA_Cfg;
  reg                     Clk_TA_Readback;
/*-----signal of usb interpreter---*/
  reg                     Start_Config_Delay1,
                          Start_Config_Delay2;        //Used to detect rising edge
  reg                     Start_Read_Back_Delay1,
                          Start_Read_Back_Delay2;      
  reg                     Start_Read_Back          = 1'b1;            //This signal is rising edge effect
  reg                     End_Read_Back            = 1'b1;
  reg                     End_Read_Back_Delay1,                       //rising edge effect
                          End_Read_Back_Delay2;
  reg                     Select_Cfg_Readback;                        //sensetive to Start_Read_Back and End_Read_Back signals  0 for cfg. 1 for readback 
/*-----State of Config-------------*/
localparam          [4:0] TA_CONFIG_IDLE           = 5'd0,
                          TA_CONFIG_SET_REGIN      = 5'd1,
                          TA_CONFIG_SEND_CLK       = 5'd2,
                          TA_CONFIG_WAIT_RECOVERY  = 5'd3,
                          TA_CONFIG_SEND_LOAD      = 5'd4;
 reg                [4:0] State_TA_Config,
                          State_TA_Config_Next;

 
 reg               [11:0] Cnt_Set_Regin,
                          Cnt_Send_CLK,
                          Cnt_Wait_Recovery,
                          Cnt_Send_Load;
 
 reg               [7:0]  Cnt_Sent_Bit;             //used to count num of sent bit

 localparam        [7:0]  TA_CMD_LENGTH             = 8'd165;   //Length of Cmd  = 165 if Test ,change this number to 5. Maybe need another CLK_TA rising edge

 reg                      Clk_TA_Delay1,
                          Clk_TA_Delay2,
                          Clk_TA_Readback_Delay1,
                          Clk_TA_Readback_Delay2;
 

/*-----165 Bit command to be sent and read back-----*/
  reg             [165:1] Command_2_TA;     // 165bit command is in the inverted order. 
  //1~32 bit: TESTMASK (32-bit logic high enables the switch to the  cal_ta input). Not use.
  //33~128 bit: TRIMDACS (96 bits, 3-bit DACs for threshold trimming) Not Use.
  //129~160 bit: DIS (32 bits, logic high disables the corresponding channels)
  //161 bit:  SSP (Select signal polarity) 
  //162 bit:  GED (gain stage, 0 for use gain stage. the gain inverse signal)
  //163 bit:  GAINMSB (gain signal) not use
  //164 bit:  GAINLSB (gain signal) not use
  //165 bit:  TESTMODE (1 enable the test mode)
  reg             [165:1] Command_Readback_From_TA1,
                          Command_Readback_From_TA2,
                          Command_Readback_From_TA3,
                          Command_Readback_From_TA4;
/*-----State of Readback--------------*/
localparam          [4:0] TA_READBACK_IDLE            = 5'd0,
                          TA_READBACK_SEND_READBACK   = 5'd1,
                          TA_READBACK_WAIT_FOR_CLK    = 5'd2,
                          TA_READBACK_SEND_CLK        = 5'd3,
                          TA_READBACK_WAIT_RECOVER    = 5'd4,
                          TA_READBACK_GET_DATA        = 5'd5;
 reg                [4:0] State_TA_Readback,
                          State_TA_Readback_Next;
 reg               [11:0] Cnt_Send_Readback,
                          Cnt_Wait_For_CLK,
                          Cnt_Send_CLK_Readback,
                          Cnt_Wait_Recovery_Readback;



 reg               [7:0]  Cnt_Sent_Bit_Readback;

 localparam        [7:0]  TA_READBACK_LENGTH          = 8'd165;







/*-----This always is for tell rising edge of control signal--*/
 always @ (posedge Clk or negedge Rst_n)        
   begin
     if(~Rst_n)
       begin
         Start_Config_Delay1                  <=  1'b0;
         Start_Config_Delay2                  <=  1'b0;
         Start_Read_Back_Delay1               <=  1'b1;
         Start_Read_Back_Delay2               <=  1'b1;
         End_Read_Back_Delay1                 <=  1'b1;
         End_Read_Back_Delay2                 <=  1'b1;
       end    
     else
       begin
         Start_Config_Delay1                  <=  In_Start_Config;
         Start_Config_Delay2                  <=  Start_Config_Delay1;
         Start_Read_Back_Delay1               <=  Start_Read_Back;
         Start_Read_Back_Delay2               <=  Start_Read_Back_Delay1;
         End_Read_Back_Delay1                 <=  End_Read_Back;
         End_Read_Back_Delay2                 <=  End_Read_Back_Delay1;
       end    
   end    
/*-----Change CLK_TA Channel from config to readback-----*/
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Select_Cfg_Readback                 <=  1'b0;                 //0for Cfg   1 for Readback
        end
      else if (Start_Read_Back_Delay1 && !Start_Read_Back_Delay2)
        begin
          Select_Cfg_Readback                 <=  1'b1;                 //Chang to Read back CLK_TA
        end
      else if (End_Read_Back_Delay1 && ! End_Read_Back_Delay2)
        begin
          Select_Cfg_Readback                 <=  1'b0;
        end   
      else
        begin
          Select_Cfg_Readback                 <=  Select_Cfg_Readback;
        end   
    end      
/*-----for Telling the Rising edge of CLK_TA to count num of Sent bit--*/
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Clk_TA_Delay1                       <=  1'b0;
          Clk_TA_Delay2                       <=  1'b0;
          Clk_TA_Readback_Delay1              <=  1'b0;
          Clk_TA_Readback_Delay2              <=  1'b0;
        end   
      else
        begin
          Clk_TA_Readback_Delay1              <=  Clk_TA_Readback;
          Clk_TA_Readback_Delay2              <=  Clk_TA_Readback_Delay1;
          Clk_TA_Delay1                       <=  Clk_TA_Cfg;
          Clk_TA_Delay2                       <=  Clk_TA_Delay1;
        end   
    end   

  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Cnt_Sent_Bit                        <=  8'd0;         //Cnt_Sent_Bit ++ when tell the rising edge of Clk_TA. and return to 0 when sending load signal.
        end
      else if(Clk_TA_Delay1 && !Clk_TA_Delay2)
        begin
          Cnt_Sent_Bit                        <=  Cnt_Sent_Bit  + 1'b1;
        end   
      else if(State_TA_Config ==  TA_CONFIG_SEND_LOAD || State_TA_Config == TA_CONFIG_IDLE)
        begin
          Cnt_Sent_Bit                        <=  8'd0;
        end   
      else
        begin
          Cnt_Sent_Bit                        <=  Cnt_Sent_Bit;
        end   

    end   

/*-----Assign Command------*/
  always @ (*)
    begin
      //Command_2_TA[166]                        =  1'b0;               //compensation for test
      Command_2_TA[165:38]                     =  128'd0;             //the Rest is all 0.
      Command_2_TA[37:6]                       =  In_Disable_Channel;  //1 for disable
      Command_2_TA[5:1]                        =  In_TA_Mode;         //5 bit most important bits
    end   

/*-----State machine to config TA---*/
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          State_TA_Config                     <=  TA_CONFIG_IDLE;
        end   
      else
        begin
          State_TA_Config                     <=  State_TA_Config_Next;
        end   
    end 
  always @ (*)
    begin
      if(~Rst_n)
       begin
         State_TA_Config_Next                  =  TA_CONFIG_IDLE;
       end
      else
       begin
         State_TA_Config_Next                  =  TA_CONFIG_IDLE;
         case(State_TA_Config)
           TA_CONFIG_IDLE:
             begin
               if(Start_Config_Delay1 && !Start_Config_Delay2)  //rising edge of Start_Config.
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SET_REGIN; 
                 end    
               else
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_IDLE;
                 end    
             end    
           TA_CONFIG_SET_REGIN:
             begin
               if(Cnt_Set_Regin  < 12'd4)
                begin
                  State_TA_Config_Next         =  TA_CONFIG_SET_REGIN;
                end   
               else
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SEND_CLK;
                 end    
             end    
           TA_CONFIG_SEND_CLK:
             begin
               if(Cnt_Send_CLK  < 12'd7)
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SEND_CLK;
                 end    
               else
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_WAIT_RECOVERY;
                 end    
             end    
           TA_CONFIG_WAIT_RECOVERY:
             begin
               if(Cnt_Wait_Recovery  < 12'd9)
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_WAIT_RECOVERY;
                 end    
               else if(Cnt_Sent_Bit  < TA_CMD_LENGTH)
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SET_REGIN;
                 end    
               else
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SEND_LOAD;
                 end                 
             end    
           TA_CONFIG_SEND_LOAD:
             begin
               if(Cnt_Send_Load   < 12'd49)
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_SEND_LOAD;
                 end    
               else
                 begin
                   State_TA_Config_Next        =  TA_CONFIG_IDLE;
                 end    
             end    
            default:
              State_TA_Config_Next             =  TA_CONFIG_IDLE;
         endcase                
          
       end   
    end   
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Out_Reg_In                          <=  4'd0;
          Clk_TA_Cfg                          <=  1'b0;
          Out_Load                            <=  1'b0;
          Cnt_Set_Regin                       <=  12'd0;
          Cnt_Send_CLK                        <=  12'd0;
          Cnt_Wait_Recovery                   <=  12'd0;
          Cnt_Send_Load                       <=  12'd0;    
          Start_Read_Back                     <=  1'b1;
        end   
      else
        begin
          case(State_TA_Config)
            TA_CONFIG_IDLE:
              begin
                Out_Reg_In                    <=  4'd0;           
                Clk_TA_Cfg                    <=  1'b0;
                Out_Load                      <=  1'b0;
                Cnt_Set_Regin                 <=  12'd0;
                Cnt_Send_CLK                  <=  12'd0;
                Cnt_Wait_Recovery             <=  12'd0;
                Cnt_Send_Load                 <=  12'd0;
                Start_Read_Back               <=  1'b1;
              end
            TA_CONFIG_SET_REGIN:
              begin
                Out_Reg_In[1]                 <=  Command_2_TA[TA_CMD_LENGTH - Cnt_Sent_Bit];     //Set Regin      
                Out_Reg_In[2]                 <=  Command_2_TA[TA_CMD_LENGTH - Cnt_Sent_Bit];           
                Out_Reg_In[3]                 <=  Command_2_TA[TA_CMD_LENGTH - Cnt_Sent_Bit];           
                Out_Reg_In[4]                 <=  Command_2_TA[TA_CMD_LENGTH - Cnt_Sent_Bit];           
                Clk_TA_Cfg                    <=  1'b0;
                Out_Load                      <=  1'b0;
                Cnt_Set_Regin                 <=  Cnt_Set_Regin + 1'b1;                           //Cnt Regin till 100ns
                Cnt_Send_CLK                  <=  12'd0;
                Cnt_Wait_Recovery             <=  12'd0;
                Cnt_Send_Load                 <=  12'd0;                
                Start_Read_Back               <=  1'b1;
              end   
            TA_CONFIG_SEND_CLK:
              begin
                Out_Reg_In                    <=  Out_Reg_In;
                Clk_TA_Cfg                    <=  1'b1;         //Clk 1 Send Regin
                Out_Load                      <=  1'b0;
                Cnt_Set_Regin                 <=  12'd0;        //reset Cnt_Set_Regin
                Cnt_Send_CLK                  <=  Cnt_Send_CLK  + 1'b1;   //Cnt Send Clk till 160ns
                Cnt_Wait_Recovery             <=  12'd0;
                Cnt_Send_Load                 <=  12'd0;
                Start_Read_Back               <=  1'b1;
              end   
            TA_CONFIG_WAIT_RECOVERY:
              begin
                Out_Reg_In                    <=  Out_Reg_In; //Hold Regin
                Clk_TA_Cfg                    <=  1'b0;         //Reset Clk
                Out_Load                      <=  1'b0;
                Cnt_Set_Regin                 <=  1'b0;
                Cnt_Send_CLK                  <=  12'd0;      //reset Cnt_Send_CLK
                Cnt_Wait_Recovery             <=  Cnt_Wait_Recovery + 1'b1;
                Cnt_Send_Load                 <=  12'd0;
                Start_Read_Back               <=  1'b1;
              end   
            TA_CONFIG_SEND_LOAD:
              begin
                Out_Reg_In                    <=  4'd0;     //Reset Out_Reg_In
                Clk_TA_Cfg                    <=  1'b0; 
                Out_Load                      <=  1'b1;     //Send Load signal
                Cnt_Set_Regin                 <=  12'd0;
                Cnt_Send_CLK                  <=  12'd0;
                Cnt_Wait_Recovery             <=  12'd0;    //Reset Cnt_Wait_Recovery
                Cnt_Send_Load                 <=  Cnt_Send_Load + 1'b1; //Cnt till 1000ns
                Start_Read_Back               <=  1'b0;                 //Read back start
              end   
            default:
              begin
                Out_Reg_In                    <=  4'd0;           
                Clk_TA_Cfg                    <=  1'b0;
                Out_Load                      <=  1'b0;
                Cnt_Set_Regin                 <=  12'd0;
                Cnt_Send_CLK                  <=  12'd0;
                Cnt_Wait_Recovery             <=  12'd0;
                Start_Read_Back               <=  1'b1;
                Cnt_Send_Load                 <=  12'd0;
              end
          endcase               
        end   
    end   
 /*-----State Readback from TA-----*/
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          State_TA_Readback                   <=  TA_READBACK_IDLE;  
        end   
      else
        begin
          State_TA_Readback                   <=  State_TA_Readback_Next;
        end   
    end   
    
  always @ (*)
    begin
      if(~Rst_n)
        begin
          State_TA_Readback_Next              =   TA_READBACK_IDLE;
        end 
      else
        begin
          State_TA_Readback_Next              =   TA_READBACK_IDLE;
          case(State_TA_Readback)
            TA_READBACK_IDLE:
              begin
                if(Start_Read_Back_Delay1 && !Start_Read_Back_Delay2)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_SEND_READBACK;
                  end   
                else
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_IDLE;
                  end   
              end   
            TA_READBACK_SEND_READBACK:
              begin
                if(Cnt_Send_Readback  < 12'd49)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_SEND_READBACK;
                  end   
                else
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_WAIT_FOR_CLK;
                  end   
              end   
            TA_READBACK_WAIT_FOR_CLK:
              begin
                if(Cnt_Wait_For_CLK   < 12'd9)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_WAIT_FOR_CLK;
                  end   
                else
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_SEND_CLK;
                  end   
              end   
            TA_READBACK_SEND_CLK:
              begin
                if(Cnt_Send_CLK_Readback      < 12'd7)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_SEND_CLK;
                  end   
                else
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_GET_DATA;
                  end   
              end   
            TA_READBACK_GET_DATA:
              begin
                State_TA_Readback_Next        =   TA_READBACK_WAIT_RECOVER;
              end   
            TA_READBACK_WAIT_RECOVER:
              begin
                if(Cnt_Wait_Recovery_Readback   < 12'd9)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_WAIT_RECOVER;
                  end   
                else if(Cnt_Sent_Bit_Readback   < TA_READBACK_LENGTH)
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_SEND_CLK;
                  end   
                else  
                  begin
                    State_TA_Readback_Next    =   TA_READBACK_IDLE;
                  end   
              end   
          endcase                 
        end   
    end   
 
  always @ ( posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Cnt_Send_Readback                   <=  12'd0;
          Cnt_Wait_For_CLK                    <=  12'd0;
          Cnt_Send_CLK_Readback               <=  12'd0;
          Cnt_Wait_Recovery_Readback          <=  12'd0;
          Clk_TA_Readback                     <=  1'b0;
          Out_Read_Back                       <=  1'b0;    
          End_Read_Back                       <=  1'b1;
          Command_Readback_From_TA1           <=165'd0;
          Command_Readback_From_TA2           <=165'd0;
          Command_Readback_From_TA3           <=165'd0;
          Command_Readback_From_TA4           <=165'd0;
        end
      else
        begin
          case(State_TA_Readback)
            TA_READBACK_IDLE:
              begin 
                Cnt_Send_Readback                   <=  12'd0;
                Cnt_Wait_For_CLK                    <=  12'd0;
                Cnt_Send_CLK_Readback               <=  12'd0;
                Cnt_Wait_Recovery_Readback          <=  12'd0;
                Clk_TA_Readback                     <=  1'b0;
                Out_Read_Back                       <=  1'b0;    
                End_Read_Back                       <=  1'b1;             
              end    
           TA_READBACK_SEND_READBACK:
             begin
                Cnt_Send_Readback                   <=  Cnt_Send_Readback + 1'b1;     //Cnt_Send_Readback ++ to 1000ns
                Cnt_Wait_For_CLK                    <=  12'd0;
                Cnt_Send_CLK_Readback               <=  12'd0;
                Cnt_Wait_Recovery_Readback          <=  12'd0;
                Clk_TA_Readback                     <=  1'b0;
                Out_Read_Back                       <=  1'b1;                         // Send Out_Read_Back signal lase 1000 ns
                End_Read_Back                       <=  1'b1;             
             end  
           TA_READBACK_WAIT_FOR_CLK:
             begin
                Cnt_Send_Readback                   <=  12'd0;                        //Recover to 0
                Cnt_Wait_For_CLK                    <=  Cnt_Wait_For_CLK  + 1'b1;     //Cnt_Wait_For_CLK  ++  to 200ns
                Cnt_Send_CLK_Readback               <=  12'd0;
                Cnt_Wait_Recovery_Readback          <=  12'd0;
                Clk_TA_Readback                     <=  1'b0;                         //Recover to 0
                Out_Read_Back                       <=  1'b0;    
                End_Read_Back                       <=  1'b1;             
             end
           TA_READBACK_SEND_CLK:
             begin
                Cnt_Send_Readback                   <=  12'd0;
                Cnt_Wait_For_CLK                    <=  12'd0;                        //Recover to 0;
                Cnt_Send_CLK_Readback               <=  Cnt_Send_CLK_Readback + 1'b1; //Cnt_Send_CLK_Readback ++ to 160ns
                Cnt_Wait_Recovery_Readback          <=  12'd0;
                Clk_TA_Readback                     <=  1'b1;                         //Send Clk_TA_Readback
                Out_Read_Back                       <=  1'b0;    
                End_Read_Back                       <=  1'b0;                         //Begin to low End_Read_Back;                            

             end    
           TA_READBACK_GET_DATA:
             begin
                Cnt_Send_Readback                   <=  12'd0;
                Cnt_Wait_For_CLK                    <=  12'd0;                        //Recover to 0;
                Cnt_Send_CLK_Readback               <=  12'd0;                        //Recover to 0
                Cnt_Wait_Recovery_Readback          <=  12'd0;
                Clk_TA_Readback                     <=  1'b1;                         //Send Clk_TA_Readback
                Out_Read_Back                       <=  1'b0;    
                End_Read_Back                       <=  1'b0;                         //Begin to low End_Read_Back;                            
                Command_Readback_From_TA1[Cnt_Sent_Bit_Readback]    <=  In_Reg_Out[1];
                Command_Readback_From_TA2[Cnt_Sent_Bit_Readback]    <=  In_Reg_Out[2];
                Command_Readback_From_TA3[Cnt_Sent_Bit_Readback]    <=  In_Reg_Out[3];
                Command_Readback_From_TA4[Cnt_Sent_Bit_Readback]    <=  In_Reg_Out[4];
             end    
           TA_READBACK_WAIT_RECOVER:
             begin               
                Cnt_Send_Readback                   <=  12'd0;
                Cnt_Wait_For_CLK                    <=  12'd0;
                Cnt_Send_CLK_Readback               <=  12'd0;                        //Recover to 0;
                Cnt_Wait_Recovery_Readback          <=  Cnt_Wait_Recovery_Readback + 1'b1;//Cnt_Wait_Recovery_Readback++ to 200ns
                Clk_TA_Readback                     <=  1'b0;                         //Recover Clk_TA_Readback
                Out_Read_Back                       <=  1'b0;    
                End_Read_Back                       <=  1'b0;                         //continue to low End_Read_Back;       
             end  
           endcase
        end   
    end   
/*-----Cnt Cnt_Sent_Bit_Readback -----*/
  always @ (posedge Clk or negedge Rst_n)
    begin
      if(~Rst_n)
        begin
          Cnt_Sent_Bit_Readback                     <=  8'd0;
        end
      else if(Clk_TA_Readback_Delay1 && !Clk_TA_Readback_Delay2)
        begin
          Cnt_Sent_Bit_Readback                     <=  Cnt_Sent_Bit_Readback +1'b1;
        end
      else if(State_TA_Readback ==  TA_READBACK_IDLE)
        begin
          Cnt_Sent_Bit_Readback                     <=  8'd0;
        end   
      else
        begin
          Cnt_Sent_Bit_Readback                     <=  Cnt_Sent_Bit_Readback;
        end   
    end   
 assign Out_Clk_TA     = (Select_Cfg_Readback  ==  1'b0) ? Clk_TA_Cfg :  Clk_TA_Readback;
 assign Out_SSP        = Command_Readback_From_TA1[161];
 assign Out_GED        = Command_Readback_From_TA1[162];

 endmodule
