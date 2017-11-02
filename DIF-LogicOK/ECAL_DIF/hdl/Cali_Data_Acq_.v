/*Cali Acq mode is used for VA cali of all channel
* It's my latest module writen on  2016-5-3. I have learned lots of tips of
* writing logic from before. Thanks Professor Feng Changqing for his teaching,
  * so mych.                            Ma siyuan*/
 module Cali_Data_Acq(
    input                   Clk,
    input                   Rst_N,
    /*--IO of Control Signal--*/
    input                   In_Sel_Work_Mode,   //1 for cali mode, 0 for normal mode
    input                   In_Trig,
    /*--IO of ADC-------------*/
    input       [4:1]       In_Sdo,
    output                  Out_Pdref,
    output                  Out_CNV,
    output                  Out_Turb,
    output                  Out_Sck,
    /*--IO of VATA160---------*/
    output reg  [4:1]       Out_Shift_In_N_VA,
    output reg              Out_Ckb_N_VA,
    output reg              Out_Hold_VA, //This is not low active ,is high active !!!!!!!!!!!!!! 
    output reg              Out_Dreset_VA,
    /*--IO of 
    * Cali_State                    <=Cali_Start------*/
    output reg              Out_Cali_Start_Control, // Control ADG741 Switch , 1 for closed ,0 for open
    /*--IO of Exfifo----------*/
    output      [15:0]      Out_Data_2_Exfifo,
    input                   In_Data_Rd_of_Ge_Fifo_En,
    output                  Out_Ge_Fifo_Empty

  );
/*--Signal of ADC_fifo and Ge fifo---*/
wire          [15:0]        Data_Out_2_Fifo_1;
wire          [15:0]        Data_Out_2_Fifo_2;
wire          [15:0]        Data_Out_2_Fifo_3;
wire          [15:0]        Data_Out_2_Fifo_4;
wire                        Data_Out_En_2_Fifo_1;
wire                        Data_Out_En_2_Fifo_2;
wire                        Data_Out_En_2_Fifo_3;
wire                        Data_Out_En_2_Fifo_4;
wire                        Acq_End_Sig;
reg                         Acq_End_Sig_Delay1;
reg                         Acq_End_Sig_Delay2;
wire          [15:0]        Data_Out_2_Ge_Fifo_1;
wire          [15:0]        Data_Out_2_Ge_Fifo_2;
wire          [15:0]        Data_Out_2_Ge_Fifo_3;
wire          [15:0]        Data_Out_2_Ge_Fifo_4;
reg                         Adc_Fifo_Rd_1;
reg                         Adc_Fifo_Rd_2;
reg                         Adc_Fifo_Rd_3;
reg                         Adc_Fifo_Rd_4;
wire                        Adc_Fifo_Empty_1;
wire                        Adc_Fifo_Empty_2;
wire                        Adc_Fifo_Empty_3;
wire                        Adc_Fifo_Empty_4;
wire                        Adc_Fifo_Full_1;
wire                        Adc_Fifo_Full_2;
wire                        Adc_Fifo_Full_3;
wire                        Adc_Fifo_Full_4;

reg                         Data_Wr_of_Ge_Fifo_En;
reg                         Data_Wr_of_Ge_Fifo_En_Delay;
reg           [15:0]        Data_In_2_Ge_Fifo;
reg           [15:0]        Data_Start;

/*--Adc signals----------------------*/
reg                         Start_Converting_Sig;

/*--State signal for puting data into Ge fifo--*/
localparam    [1:0]         STATE_IDLE   = 2'b00;
localparam    [1:0]         STATE_START  = 2'b01;
localparam    [1:0]         STATE_PROCESS= 2'b10;
localparam    [1:0]         STATE_END    = 2'b11;
reg           [1:0]         State        = STATE_IDLE;

localparam    [5:0]         TOTAL_LENGTH_START = 6'd2; //length of Start words
localparam    [5:0]         FIRST_WORD = 6'd0;
localparam    [5:0]         SECOND_WORD = 6'd1;
reg           [5:0]         Cnt_Length_Start;

reg           [4:0]         Data_Choose_2_Ge_Fifo;

reg           [7:0]         Cnt_Data_En_1;
reg                         Data_Out_En_2_Fifo_1_Delay1, 
                            Data_Out_En_2_Fifo_1_Delay2;

localparam    [7:0]         TOTAL_DATA_NUM = 8'd32;  //The number of Channel of every VATA160    not used in VA control process
/*--Signal of VA control--------*/
reg                         VA_Get_End;
reg           [7:0]         Cnt_ChnID;// = Cnt_Data_En_1
reg           [11:0]        Cnt_Hold;
reg           [11:0]        Cnt_Steady;
reg           [11:0]        Cnt_Recovery;
reg           [11:0]        Cnt_Ckb_Delay;                            //Ckb last for at least 200 ns ,which means last 10 cycles
reg           [11:0]        Cnt_Shift_Delay;
localparam    [11:0]        DELAY_FOR_RECOVERY        =     12'd4000;  //Delay 80us for recovery  max = 4096
localparam    [11:0]        HOLD_DELAY_TIME           =     12'd90; //Change delay time to meet the Cali shape  90*20 = 1.8us
localparam    [11:0]        DELAY_FOR_STEADY          =     12'd250;//Delay 5us for ADC input become steady
localparam    [11:0]        SHIFT_DELAY               =     12'd6;  //Delay for shift to become steady before send CKB


reg           [3:0]         Cali_State;
reg           [3:0]         Cali_State_Next;
localparam    [3:0]         CALI_STATE_IDLE           =     4'd0,
                            CALI_STATE_START          =     4'd8,
                            CALI_STATE_SHIFT          =     4'd1,
                            CALI_STATE_CKB            =     4'd2,
                            CALI_STATE_SEND_CHARGE    =     4'd3,
                            CALI_STATE_DELAY_HOLD     =     4'd4,
                            CALI_STATE_START_CONV     =     4'd5,
                            CALI_STATE_WAIT_ACQ       =     4'd6,
                            CALI_STATE_SEND_HOLD      =     4'd7,
                            CALI_STATE_WAIT_RECOVERY  =     4'd10,//for recover the Switch
                            CALI_STATE_DELAY_STEADY   =     4'd9,//for ADC input become steady need 5us
                            CALI_STATE_SEND_DRESET    =     4'd11;
/*--other signals--------------*/
reg                         Trig_Delay1;
reg                         Trig_Delay2;

                          
/*---Cali_VA_Control State machine------*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Cali_State                    <=  CALI_STATE_IDLE;
    end  
  else
    begin
      Cali_State                    <=  Cali_State_Next;
    end   
end  

always @ ( * )
begin
  if(~Rst_N)
    begin
      Cali_State_Next               =   CALI_STATE_IDLE;
    end  
  else
    begin
      Cali_State_Next               =   CALI_STATE_IDLE;
      case(Cali_State)
        CALI_STATE_IDLE:
          begin
            if(~In_Sel_Work_Mode)
              begin
                Cali_State_Next     =   CALI_STATE_IDLE;
              end    
            else if(Trig_Delay1 && !Trig_Delay2)
              begin
                Cali_State_Next     =   CALI_STATE_START;
              end     
            else
              begin
                Cali_State_Next     =   CALI_STATE_IDLE;
              end   
          end   
        CALI_STATE_START:
          begin
              Cali_State_Next         =   CALI_STATE_SHIFT;
          end   
        CALI_STATE_SHIFT:
          begin
            if(Cnt_Shift_Delay  < SHIFT_DELAY)
              begin
                Cali_State_Next       = CALI_STATE_SHIFT;   
              end   
            else
              begin
                Cali_State_Next         =   CALI_STATE_CKB;
              end 
          end   
        CALI_STATE_CKB:
          begin
            if(Cnt_Ckb_Delay  <   12'd9)  //wait 200ns
              begin
                  Cali_State_Next     =   CALI_STATE_CKB;
              end   
            else
              begin
                if(Cnt_ChnID    ==  TOTAL_DATA_NUM)
                  begin
                    Cali_State_Next   =   CALI_STATE_SEND_DRESET;
                  end   
                else
                  begin
                    Cali_State_Next   =   CALI_STATE_SEND_CHARGE;
                  end   
              end
          end
        CALI_STATE_SEND_DRESET:
          begin
            Cali_State_Next         =   CALI_STATE_IDLE; 
          end   
        CALI_STATE_SEND_CHARGE:
          begin
            Cali_State_Next         =   CALI_STATE_DELAY_HOLD;
          end   
        CALI_STATE_DELAY_HOLD:
          begin
            if(Cnt_Hold             ==   HOLD_DELAY_TIME)
              begin
                Cali_State_Next     =   CALI_STATE_SEND_HOLD;
              end   
            else
              begin
                Cali_State_Next     =   CALI_STATE_DELAY_HOLD;
              end   
          end   
        CALI_STATE_SEND_HOLD:
          begin
            Cali_State_Next         =   CALI_STATE_DELAY_STEADY;
          end   
        CALI_STATE_DELAY_STEADY:
          begin
            if(Cnt_Steady           <  DELAY_FOR_STEADY - 1'b1)
              begin
                Cali_State_Next     =  CALI_STATE_DELAY_STEADY; 
              end   
            else
              begin
                Cali_State_Next     =  CALI_STATE_START_CONV;
              end   
          end   
        CALI_STATE_START_CONV:
          begin
            Cali_State_Next         =   CALI_STATE_WAIT_ACQ;
          end   
        CALI_STATE_WAIT_ACQ:
          begin
            if(Acq_End_Sig_Delay1 && !Acq_End_Sig_Delay2)
              begin
                Cali_State_Next     =   CALI_STATE_WAIT_RECOVERY;
              end   
            else
              begin
                Cali_State_Next     =   CALI_STATE_WAIT_ACQ;
              end   
          end   
        CALI_STATE_WAIT_RECOVERY:
          begin
            if(Cnt_Recovery         < DELAY_FOR_RECOVERY - 1'b1)
              begin
                Cali_State_Next     =   CALI_STATE_WAIT_RECOVERY;
              end   
            else
              begin
                Cali_State_Next     =   CALI_STATE_CKB;
              end   
          end   
        default: Cali_State_Next    =   CALI_STATE_IDLE;
      endcase             
    end  
end  
  
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
            Cnt_Shift_Delay             <=    12'd0;      
      Out_Shift_In_N_VA                 <=    4'b1111;
      Out_Ckb_N_VA                      <=    1'b1;
      Out_Hold_VA                     <=    1'b0;
      Out_Dreset_VA                     <=    1'b1;
      Start_Converting_Sig              <=    1'b0;
      VA_Get_End                        <=    1'b1;
      Out_Cali_Start_Control            <=    1'b0;
      Cnt_Hold                          <=    12'd0;
      Cnt_Steady                        <=    12'd0;
      Cnt_Recovery                      <=    12'd0;
      Cnt_Ckb_Delay                     <=    12'd0;
    end
  else
    begin
      case(Cali_State)
        CALI_STATE_IDLE:
          begin
            Cnt_Shift_Delay             <=    12'd0;       
            Out_Shift_In_N_VA           <=    4'b1111;  //Shift is 1 means no shift signal
            Out_Ckb_N_VA                <=    1'b1;     //CKb is low active 
            Out_Hold_VA               <=    1'b0;     //Hold is low active
            Out_Dreset_VA               <=    1'b0;     //Dreset is high active and is reset when finished CALI 
            Start_Converting_Sig        <=    1'b0;     //not start convertion
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            VA_Get_End                  <=    1'b1;     //VA end active high
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Cnt_Recovery                <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
          end     
        CALI_STATE_SEND_DRESET:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;  //Shift is 1 means no shift signal
            Out_Ckb_N_VA                <=    1'b1;     //CKb is low active 
            Out_Hold_VA                 <=    1'b0;     //Hold is low active
            Out_Dreset_VA               <=    1'b1;     //Dreset is high active and is reset when finished CALI trig
            Start_Converting_Sig        <=    1'b0;     //not start convertion
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            VA_Get_End                  <=    1'b1;     //VA end active high
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Cnt_Recovery                <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
          end   
        CALI_STATE_START:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;
            Out_Ckb_N_VA                <=    1'b1;
            Out_Hold_VA               <=    1'b0;
            Out_Dreset_VA               <=    1'b0;   //Dreset recover
            Start_Converting_Sig        <=    1'b0;
            VA_Get_End                  <=    1'b0;   //VA not end
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
            Cnt_Recovery                <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
         
          end   
        CALI_STATE_SHIFT:
          begin
            Cnt_Shift_Delay             <=    Cnt_Shift_Delay   + 1'b1;
            Out_Shift_In_N_VA           <=    4'b0000;    //  Send Shift signal
            Out_Ckb_N_VA                <=    1'b1;
            Out_Hold_VA               <=    1'b0;
            Out_Dreset_VA               <=    1'b0; 
            Start_Converting_Sig        <=    1'b0;
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        CALI_STATE_CKB:
          begin
            Cnt_Shift_Delay             <=    12'd0;
            Out_Shift_In_N_VA           <=    Out_Shift_In_N_VA;    //keep low in first cyc or keep high in other cycs
            Out_Ckb_N_VA                <=    1'b0;       //Send Ckb signal
            Out_Hold_VA               <=    1'b0;
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Start_Converting_Sig        <=    1'b0;
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
            Cnt_Recovery                <=    12'd0;
            VA_Get_End                  <=    1'b0;
            Cnt_Ckb_Delay               <=    Cnt_Ckb_Delay   + 1'b1;//Cnt_Ckb_Delay till 10 Cyc to make CKB signal last 200ns
          end
        CALI_STATE_SEND_CHARGE:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;    //Recover Shift
            Out_Ckb_N_VA                <=    1'b1;       //Recover Ckb 
            Out_Hold_VA               <=    1'b0;       
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b1;     //Close switch and send a controlled charge
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Start_Converting_Sig        <=    1'b0;
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
            Cnt_Recovery                <=    12'd0;
            VA_Get_End                  <=    1'b0;
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        CALI_STATE_DELAY_HOLD:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;    
            Out_Ckb_N_VA                <=    1'b1;      
            Out_Hold_VA               <=    1'b0;       
            Out_Dreset_VA               <=    1'b0; 
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Out_Cali_Start_Control      <=    1'b1;    
            Start_Converting_Sig        <=    1'b0;
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    Cnt_Hold    + 1'b1; //Cnt Hold ++ till 50
            Cnt_Ckb_Delay               <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
          end
        CALI_STATE_SEND_HOLD:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;    
            Out_Ckb_N_VA                <=    1'b1;      
            Out_Hold_VA               <=    1'b1;   //  Hold one Channel ,testing channel       
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b1;    
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Start_Converting_Sig        <=    1'b0;
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    12'd0;  //  Recover Cnt_Hold
            Cnt_Ckb_Delay               <=    12'd0;
          end 
        CALI_STATE_DELAY_STEADY:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;    
            Cnt_Steady                  <=    Cnt_Steady  + 1'b1;
            Out_Ckb_N_VA                <=    1'b1;      
            Out_Hold_VA               <=    1'b1;   //  Hold one Channel ,testing channel       
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b1;   // close the switch     
            Start_Converting_Sig        <=    1'b0;   // Start Converting
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        CALI_STATE_START_CONV:
          begin
            Out_Shift_In_N_VA           <=    4'b1111;    
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Out_Ckb_N_VA                <=    1'b1;      
            Out_Hold_VA               <=    1'b1;   //  Hold one Channel ,testing channel       
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b1;   // close the switch     
            Start_Converting_Sig        <=    1'b1;   // Start Converting
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        CALI_STATE_WAIT_ACQ:
          begin
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Out_Shift_In_N_VA           <=    4'b1111;    
            Out_Ckb_N_VA                <=    1'b1;      
            Out_Hold_VA               <=    1'b1;   //  Hold one Channel ,testing channel       
            Out_Dreset_VA               <=    1'b0; 
            Out_Cali_Start_Control      <=    1'b1;   // close the switch     
            Start_Converting_Sig        <=    1'b0;   
            VA_Get_End                  <=    1'b0;
            Cnt_Recovery                <=    12'd0;
            Cnt_Hold                    <=    12'd0;
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        CALI_STATE_WAIT_RECOVERY:
          begin
            Cnt_Steady                  <=    12'd0;
            Out_Shift_In_N_VA           <=    4'b1111;
            Out_Ckb_N_VA                <=    1'b1;
            Out_Hold_VA                 <=    1'b0;//not hold, for recover the output
            Out_Dreset_VA               <=    1'b0;
            Out_Cali_Start_Control      <=    1'b0;//open the switch and wait for recovery
            Start_Converting_Sig        <=    1'b0;
            VA_Get_End                  <=    1'b0;
            Cnt_Hold                    <=    12'd0;
            Cnt_Recovery                <=    Cnt_Recovery    + 1'b1;
            Cnt_Ckb_Delay               <=    12'd0;
          end   
        default:
          begin
             
            Out_Shift_In_N_VA           <=    4'b1111;  //Shift is 1 means no shift signal
            Out_Ckb_N_VA                <=    1'b1;     //CKb is low active 
            Out_Hold_VA               <=    1'b0;     //Hold is low active
            Cnt_Steady                  <=    12'd0;    //for input of ADC become steady
            Out_Dreset_VA               <=    1'b1;     //Dreset is high active and is reset when IDLE state
            Start_Converting_Sig        <=    1'b0;     //not start convertion
            Out_Cali_Start_Control      <=    1'b0;     //open the switch of ADG741
            VA_Get_End                  <=    1'b1;     //VA end active high
            Cnt_Hold                    <=    12'd0;    //Reset Cnt hold
            Cnt_Ckb_Delay               <=    12'd0;
              
          end   
      endcase         
    end   
end   



/*----Trig Delay--------------------*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Trig_Delay1                   <=  1'b0;
      Trig_Delay2                   <=  1'b0;
    end   
  else
    begin
      Trig_Delay1                   <=  In_Trig;
      Trig_Delay2                   <=  Trig_Delay1;
    end   
end   
/*--Delay for Acq_End and Data_Out_En---*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Data_Out_En_2_Fifo_1_Delay1    <= 1'b0;
      Data_Out_En_2_Fifo_1_Delay2    <= 1'b0;
      Acq_End_Sig_Delay1             <= 1'b0;
      Acq_End_Sig_Delay2             <= 1'b0;
    end
  else
    begin
      Data_Out_En_2_Fifo_1_Delay1    <= Data_Out_En_2_Fifo_1;
      Data_Out_En_2_Fifo_1_Delay2    <= Data_Out_En_2_Fifo_1_Delay1;
      Acq_End_Sig_Delay1             <= Acq_End_Sig;
      Acq_End_Sig_Delay2             <= Acq_End_Sig_Delay1;
    end   
end


/*Wr of Ge_Fifo Need a delay, cause Data_In_2_Ge_Fifo has been delayed--*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
   Data_Wr_of_Ge_Fifo_En_Delay      <= 1'b0; 
  end
  else 
    Data_Wr_of_Ge_Fifo_En_Delay     <= Data_Wr_of_Ge_Fifo_En;
end


/*--Cnt Data_Out_En number to TOTAL_DATA_NUM--*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
    Cnt_Data_En_1                   <= 8'd0;
    Cnt_ChnID                       <= 8'd0; 
  end
  else if(Data_Out_En_2_Fifo_1_Delay1 && !Data_Out_En_2_Fifo_1_Delay2 && Cnt_Data_En_1  < TOTAL_DATA_NUM )
  begin
    Cnt_Data_En_1                   <= Cnt_Data_En_1 + 1'b1;
    Cnt_ChnID                       <= Cnt_ChnID     + 1'b1;
  end
  else if(Cnt_Data_En_1 == TOTAL_DATA_NUM  && VA_Get_End)
  begin
    Cnt_Data_En_1                   <= 8'd0;
    Cnt_ChnID                       <= 8'd0;
  end
  else
  begin
    Cnt_Data_En_1                   <= Cnt_Data_En_1;
    Cnt_ChnID                       <= Cnt_ChnID;
  end
end


/*--Change the fifo data to put into Ge_Fifo---*/

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
   Data_In_2_Ge_Fifo                <= 16'b0;
  end
  else
  begin
    case(Data_Choose_2_Ge_Fifo)
    5'b1_0000:
    begin
      Data_In_2_Ge_Fifo[15:8]      <= Data_Start[7:0];
      Data_In_2_Ge_Fifo[7:0]       <= Data_Start[15:8];
    end
    5'b0_0001:
    begin
      Data_In_2_Ge_Fifo[15:8]      <= Data_Out_2_Ge_Fifo_1[15:8];//SCI data has already been changed the order
      Data_In_2_Ge_Fifo[7:0]       <= Data_Out_2_Ge_Fifo_1[7:0];
    end
    5'b0_0010:
    begin
      Data_In_2_Ge_Fifo[15:8]      <= Data_Out_2_Ge_Fifo_2[15:8];
      Data_In_2_Ge_Fifo[7:0]       <= Data_Out_2_Ge_Fifo_2[7:0];
    end

    5'b0_0100:
    begin
      Data_In_2_Ge_Fifo[15:8]      <= Data_Out_2_Ge_Fifo_3[15:8];
      Data_In_2_Ge_Fifo[7:0]       <= Data_Out_2_Ge_Fifo_3[7:0];
    end

    5'b0_1000:
    begin
      Data_In_2_Ge_Fifo[15:8]      <= Data_Out_2_Ge_Fifo_4[15:8];
      Data_In_2_Ge_Fifo[7:0]       <= Data_Out_2_Ge_Fifo_4[7:0];
    end

    5'b0_0000:
      Data_In_2_Ge_Fifo            <= 16'h0000;
    default:
      Data_In_2_Ge_Fifo            <= 16'h0000;

    endcase
  end
end

/*--State Machine of putting Fifo into Ge_Fifo--*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
    State                          <= STATE_IDLE;
    Cnt_Length_Start               <= 6'd0;
    Data_Wr_of_Ge_Fifo_En          <= 1'b0;
    Adc_Fifo_Rd_1                  <= 1'b0;
    Adc_Fifo_Rd_2                  <= 1'b0;
    Adc_Fifo_Rd_3                  <= 1'b0;
    Adc_Fifo_Rd_4                  <= 1'b0;
    Data_Choose_2_Ge_Fifo          <= 5'd0;
    Data_Start                     <= 16'h0000;
  end
  else
  begin
    case(State)
      STATE_IDLE:                           //all control signals : State ;  Data_Choose_2_Ge_Fifo ; Data_Wr_of_Ge_Fifo_En ; Adc_Fifo_Rd_1 ; Cnt_Length_Start ; Data_Start ; Every signal must be Controlled at least twice in a State Cycle;
      begin
        if( Cnt_Data_En_1 == TOTAL_DATA_NUM && VA_Get_End )
        begin
          State                     <= STATE_START;
          Data_Choose_2_Ge_Fifo     <= 5'b1_0000;
        end
        else 
        begin
          State <= STATE_IDLE;
          Data_Choose_2_Ge_Fifo     <= 5'd0;
          Data_Wr_of_Ge_Fifo_En     <= 1'b0;
          Adc_Fifo_Rd_1             <= 1'b0;
          Adc_Fifo_Rd_2             <= 1'b0;
          Adc_Fifo_Rd_3             <= 1'b0;
          Adc_Fifo_Rd_4             <= 1'b0;
          Data_Start                <= 16'h0000;
        end
      end

      STATE_START:   /*to pack the data, I need a start as "55aa eb90"*/
      begin
        if(Cnt_Length_Start == TOTAL_LENGTH_START)
        begin
          State                     <= STATE_PROCESS;
          Data_Choose_2_Ge_Fifo     <= 5'b0_0001;
          Data_Wr_of_Ge_Fifo_En     <= 1'b1;
          Adc_Fifo_Rd_1             <= 1'b1;
          Cnt_Length_Start          <= 1'b0;
        end
        else
        begin
          State                 <= STATE_START;

          case(Cnt_Length_Start)       //Length of Data_Wr_of_Ge_Fifo_En = 1 + 1 + 1 + Datalength-1 + 1 + 1 =  9  * 20 = 180ns  actual = 140 ns  if first, then 160ns
            FIRST_WORD:
            begin
              Data_Start            <= 16'h55aa;
              Data_Wr_of_Ge_Fifo_En <= 1'b1;
              Cnt_Length_Start      <= Cnt_Length_Start + 1'b1;
            end
            SECOND_WORD:
            begin
              Data_Start            <= 16'heb90;
              Data_Wr_of_Ge_Fifo_En <= 1'b1;
              Cnt_Length_Start      <= Cnt_Length_Start + 1'b1;
              
            end
          endcase
        end
      end
      STATE_PROCESS:
      begin
        if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && Adc_Fifo_Empty_3 && Adc_Fifo_Empty_4 )
        begin
          State                     <= STATE_END;
          Data_Wr_of_Ge_Fifo_En     <= 1'b1; /*shows the end of the data as "5aa5"*/
          Data_Start                <= 16'h5aa5;
          Adc_Fifo_Rd_1             <= 1'b0;
          Adc_Fifo_Rd_2             <= 1'b0;
          Adc_Fifo_Rd_3             <= 1'b0;
          Adc_Fifo_Rd_4             <= 1'b0;
          Data_Choose_2_Ge_Fifo     <= 5'b1_0000;
        end
        else
        begin
          if(Adc_Fifo_Empty_1 && ~Adc_Fifo_Empty_2 && ~Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_2           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0010;
            end
          else if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && ~Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_3           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0100;
            end
          else if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_4           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_1000;
            end
          else
            begin
              Adc_Fifo_Rd_1           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0001;
            end
        end
      end
      STATE_END:
      begin
        Data_Wr_of_Ge_Fifo_En         <= 1'b1;
        State                         <= STATE_IDLE;
      end
      default:State                   <= STATE_IDLE;
    endcase 
  
  end

end




/*General Fifo to generate 4 ADC Fifos' data*/

Adc_Ge_Fifo Adc_Ge_Fifo_Inst_Cali(
    // Inputs
    .DATA(Data_In_2_Ge_Fifo),
    .RCLOCK(Clk),
    .RE(In_Data_Rd_of_Ge_Fifo_En),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Wr_of_Ge_Fifo_En_Delay),
    // Outputs
    .EMPTY(Out_Ge_Fifo_Empty),
    .FULL(),
    .Q(Out_Data_2_Exfifo)
);

/*ADC Fifo to accept ADC's Data*/
Adc_Fifo Adc_Fifo_1_Cali(
    // Inputs
    .DATA(Data_Out_2_Fifo_1),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_1),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_1),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_1),
    .FULL(Adc_Fifo_Full_1),
    .Q(Data_Out_2_Ge_Fifo_1)
);
Adc_Fifo Adc_Fifo_2_Cali(
    // Inputs
    .DATA(Data_Out_2_Fifo_2),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_2),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_2),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_2),
    .FULL(Adc_Fifo_Full_2),
    .Q(Data_Out_2_Ge_Fifo_2)
);
Adc_Fifo Adc_Fifo_3_Cali(
    // Inputs
    .DATA(Data_Out_2_Fifo_3),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_3),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_3),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_3),
    .FULL(Adc_Fifo_Full_3),
    .Q(Data_Out_2_Ge_Fifo_3)
);
Adc_Fifo Adc_Fifo_4_Cali(
    // Inputs
    .DATA(Data_Out_2_Fifo_4),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_4),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_4),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_4),
    .FULL(Adc_Fifo_Full_4),
    .Q(Data_Out_2_Ge_Fifo_4)
);

/*--ADC_Module each for one ADC Chip--*/
ADC_AD7944 ADC_AD7944_1_Cali(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(In_Sdo[1]),
   .Turb(Out_Turb),
   .CNV(Out_CNV),
   .Pdref(Out_Pdref),
   .Sck(Out_Sck),
   .Data_Out(Data_Out_2_Fifo_1),
   .Tp(),
   .Data_Out_En(Data_Out_En_2_Fifo_1),
   .Out_Acq_End(Acq_End_Sig)
);
ADC_AD7944 ADC_AD7944_2_Cali(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(In_Sdo[2]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_2),
   .Data_Out_En(Data_Out_En_2_Fifo_2),
   .Out_Acq_End()
);
ADC_AD7944 ADC_AD7944_3_Cali(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(In_Sdo[3]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_3),
   .Data_Out_En(Data_Out_En_2_Fifo_3),
   .Out_Acq_End()
);
ADC_AD7944 ADC_AD7944_4_Cali(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(In_Sdo[4]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_4),
   .Data_Out_En(Data_Out_En_2_Fifo_4),
   .Out_Acq_End()
);
endmodule
