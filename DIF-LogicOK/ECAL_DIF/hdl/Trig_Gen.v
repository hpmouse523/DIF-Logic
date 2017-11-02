//This module is for Generating Trig signals
//there are 3 trig modes: inside  exide and self
//inside mode: can set interval time
//exide mode: trig from exide, espcially in signal sweeping test
//self test: generate trig signals according to hit sig of VATA160s
module Trig_Gen(
    input                Clk,
    input                Rst_N,
    
    input                In_Start_Stop_Trig,
    input          [3:0] In_Control_Trig_Mode,
    input          [7:0] In_Set_Trig_Inside_Time,    

    input          [4:1] In_Valid_TA_for_Self_Mod,    //Control which TA to use for Self Trig mode  1111for all use 0001for only use TA1 
    /*--IO of Ex ----*/
    input                In_Ex_Trig,
    /*-----IO of Hit_Signal-----*/
    input          [4:1] In_Hitout_TA,

    output reg           Out_Trig_Sigal



);


reg [15:0]                Cnt_1ms;
reg                       Time_1ms;

reg [1:0]                 State_Inside;
reg [1:0]                 Next_State_Inside;
localparam [1:0]          IDLE_IN = 2'b00,
                          CNT_IN  = 2'b01,
                          HIGH_IN = 2'b10;
localparam [7:0]          WIDTH_OF_TRIG = 8'd25;//25*20ns = 500ns
reg [7:0]                 Cnt_Num_Of_1ms;
reg [7:0]                 Cnt_High_of_Trig_Inside;
reg                       Trig_of_Inside_Mode;

reg                       Trig_of_Self_Mode;    //This is OR mode
reg                       Trig_of_Self_Mode_And; //This is AND mode
reg [11:0]                Cnt_High_of_Trig_And,
                          Cnt_Busy_of_Trig_And;

/*-----Sig of Self AND mode----*/
reg                       Trig_of_And_Mode;
localparam [3:0]          SELF_AND_IDLE       =   4'd0,
                          SELF_AND_HIGH       =   4'd1,
                          SELF_AND_ALWAYS_HIGH=   4'd2;
reg [11:0]                Cnt_High_And_TA1,
                          Cnt_High_And_TA2,
                          Cnt_High_And_TA3,
                          Cnt_High_And_TA4;
reg [4:1]                 State_Hit;
reg [3:0]                 State_And_TA1,
                          State_And_TA2,
                          State_And_TA3,
                          State_And_TA4;
reg [3:0]                 State_And_Next_TA1,
                          State_And_Next_TA2,
                          State_And_Next_TA3,
                          State_And_Next_TA4;
reg [3:0]                 And_State,
                          And_State_Next;

/*---Sig of Ex_Mode-----*/
reg                       Ex_Trig_Delay1,
                          Ex_Trig_Delay2;//Used for synchronize input signal
reg [7:0]                 Cnt_High_of_Trig_Ex;
reg                       Trig_of_Exide_Mode;
reg [11:0]                Cnt_High_End_Ex;
reg [11:0]                Cnt_Busy_End_Ex;
localparam  [11:0]        CNT_BUSY_END        =   12'd2500;//50 us  = 2500   200 ns  = 10
reg         [3:0]         Ex_State,
                          Ex_State_Next;
localparam  [3:0]         EX_STATE_IDLE       =   4'd0,
                          EX_STATE_SEND_TRIG  =   4'd1,
                          EX_STATE_BUSY       =   4'd2;   //Busy time doesn't allow another trig. 50us
/*-----Sig of Self_Mode-----*/
reg           [4:1]       Hitout_TA_Delay1,
                          Hitout_TA_Delay2;     //  for Tell posedge of Hit Signal input

localparam    [3:0]       SELF_STATE_IDLE           =   4'd0,
                          SELF_STATE_SEND_TRIG      =   4'd1,
                          SELF_STATE_BUSY           =   4'd2; //Busy time doesn't allow another trig, 50us
reg           [3:0]       Self_State,
                          Self_State_Next;
reg           [11:0]      Cnt_High_of_Trig_Self,
                          Cnt_Busy_End_Self;



/*------------And Mode----------*/ //modified by Siyuan on 20161101 Tuesday
// discription: only when In_Valid_TA_for_Self_Mod is used can Hit_Status be
// high when the negedge is detected. TA1~TA4 is seperated judged.
always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State_And_TA1                 <=  SELF_AND_IDLE;
      end   
    else
      begin
        State_And_TA1                 <=  State_And_Next_TA1;
      end   
  end   
always @ (*)
  begin
    if(~Rst_N)
      begin
        State_And_Next_TA1                =   SELF_AND_IDLE;
      end   
    else
        State_And_Next_TA1                =   SELF_AND_IDLE;

      begin
        case(State_And_TA1)
          SELF_AND_IDLE:
            begin
              if(!Hitout_TA_Delay1[1] && Hitout_TA_Delay2[1] )
                begin     
                  State_And_Next_TA1      =   SELF_AND_HIGH;
                end   
              else if(In_Valid_TA_for_Self_Mod[1] == 1'b0)
                begin
                  State_And_Next_TA1      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA1      =   SELF_AND_IDLE;
                end   
            end   
          SELF_AND_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[1]  ==  1'b0)
                begin
                  State_And_Next_TA1      =   SELF_AND_ALWAYS_HIGH;
                end   
              else if(Cnt_High_And_TA1 < 12'd50)        //50*20ns = 1us Means the Last of High 
                begin
                  State_And_Next_TA1      =   SELF_AND_HIGH;
                end     
              else
                begin
                  State_And_Next_TA1      =   SELF_AND_IDLE;
                end   

            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[1] == 1'b0)
                begin
                  State_And_Next_TA1      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA1      =   SELF_AND_IDLE;
                end   
            end   
          default:
            begin
              State_And_Next_TA1          =   SELF_AND_IDLE;
            end   
        endcase
      end   
  end   
always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_High_And_TA1                <=  12'd0;
        State_Hit[1]                    <=  1'b1;
      end   
    else
      begin
        case(State_And_TA1)
          SELF_AND_IDLE:
            begin
              Cnt_High_And_TA1          <=  12'd0;
              State_Hit[1]              <=  1'b0;
            end   
          SELF_AND_HIGH:
            begin
              Cnt_High_And_TA1          <=  Cnt_High_And_TA1 + 1'b1;
              State_Hit[1]              <=  1'b1;
            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              Cnt_High_And_TA1          <=  12'd0;
              State_Hit[1]              <=  1'b1;
            end   
        default:
          begin
              Cnt_High_And_TA1          <=  12'd0;
              State_Hit[1]              <=  1'b1;

          end   
          
        endcase 
      end   
  end     


//TA2 's Hit_Status High 



always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State_And_TA2                 <=  SELF_AND_IDLE;
      end   
    else
      begin
        State_And_TA2                 <=  State_And_Next_TA2;
      end   
  end   
always @ (*)
  begin
    if(~Rst_N)
      begin
        State_And_Next_TA2                =   SELF_AND_IDLE;
      end   
    else
        State_And_Next_TA2                =   SELF_AND_IDLE;

      begin
        case(State_And_TA2)
          SELF_AND_IDLE:
            begin
              if(!Hitout_TA_Delay1[2] && Hitout_TA_Delay2[2] )
                begin     
                  State_And_Next_TA2      =   SELF_AND_HIGH;
                end   
              else if(In_Valid_TA_for_Self_Mod[2] == 1'b0)
                begin
                  State_And_Next_TA2      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA2      =   SELF_AND_IDLE;
                end   
            end   
          SELF_AND_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[2]  ==  1'b0)
                begin
                  State_And_Next_TA2      =   SELF_AND_ALWAYS_HIGH;
                end   
              else if(Cnt_High_And_TA2 < 12'd50)        //50*20ns = 1us Means the Last of High 
                begin
                  State_And_Next_TA2      =   SELF_AND_HIGH;
                end     
              else
                begin
                  State_And_Next_TA2      =   SELF_AND_IDLE;
                end   

            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[2] == 1'b0)
                begin
                  State_And_Next_TA2      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA2      =   SELF_AND_IDLE;
                end   
            end   
          default:
            begin
              State_And_Next_TA2          =   SELF_AND_IDLE;
            end   
        endcase
      end   
  end   
always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_High_And_TA2                <=  12'd0;
        State_Hit[2]                    <=  1'b1;
      end   
    else
      begin
        case(State_And_TA2)
          SELF_AND_IDLE:
            begin
              Cnt_High_And_TA2          <=  12'd0;
              State_Hit[2]              <=  1'b0;
            end   
          SELF_AND_HIGH:
            begin
              Cnt_High_And_TA2          <=  Cnt_High_And_TA2 + 1'b1;
              State_Hit[2]              <=  1'b1;
            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              Cnt_High_And_TA2          <=  12'd0;
              State_Hit[2]              <=  1'b1;
            end   
        default:
          begin
              Cnt_High_And_TA2          <=  12'd0;
              State_Hit[2]              <=  1'b1;

          end   
          
        endcase 
      end   
  end     




always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State_And_TA3                 <=  SELF_AND_IDLE;
      end   
    else
      begin
        State_And_TA3                 <=  State_And_Next_TA3;
      end   
  end   
always @ (*)
  begin
    if(~Rst_N)
      begin
        State_And_Next_TA3                =   SELF_AND_IDLE;
      end   
    else
        State_And_Next_TA3                =   SELF_AND_IDLE;

      begin
        case(State_And_TA3)
          SELF_AND_IDLE:
            begin
              if(!Hitout_TA_Delay1[3] && Hitout_TA_Delay2[3] )
                begin     
                  State_And_Next_TA3      =   SELF_AND_HIGH;
                end   
              else if(In_Valid_TA_for_Self_Mod[3] == 1'b0)
                begin
                  State_And_Next_TA3      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA3      =   SELF_AND_IDLE;
                end   
            end   
          SELF_AND_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[3]  ==  1'b0)
                begin
                  State_And_Next_TA3      =   SELF_AND_ALWAYS_HIGH;
                end   
              else if(Cnt_High_And_TA3 < 12'd50)        //50*20ns = 1us Means the Last of High 
                begin
                  State_And_Next_TA3      =   SELF_AND_HIGH;
                end     
              else
                begin
                  State_And_Next_TA3      =   SELF_AND_IDLE;
                end   

            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[3] == 1'b0)
                begin
                  State_And_Next_TA3      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA3      =   SELF_AND_IDLE;
                end   
            end   
          default:
            begin
              State_And_Next_TA3          =   SELF_AND_IDLE;
            end   
        endcase
      end   
  end   
always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_High_And_TA3                <=  12'd0;
        State_Hit[3]                    <=  1'b1;
      end   
    else
      begin
        case(State_And_TA3)
          SELF_AND_IDLE:
            begin
              Cnt_High_And_TA3          <=  12'd0;
              State_Hit[3]              <=  1'b0;
            end   
          SELF_AND_HIGH:
            begin
              Cnt_High_And_TA3          <=  Cnt_High_And_TA3 + 1'b1;
              State_Hit[3]              <=  1'b1;
            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              Cnt_High_And_TA3          <=  12'd0;
              State_Hit[3]              <=  1'b1;
            end   
        default:
          begin
              Cnt_High_And_TA3          <=  12'd0;
              State_Hit[3]              <=  1'b1;

          end   
          
        endcase 
      end   
  end     

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State_And_TA4                 <=  SELF_AND_IDLE;
      end   
    else
      begin
        State_And_TA4                 <=  State_And_Next_TA4;
      end   
  end   
always @ (*)
  begin
    if(~Rst_N)
      begin
        State_And_Next_TA4                =   SELF_AND_IDLE;
      end   
    else
        State_And_Next_TA4                =   SELF_AND_IDLE;

      begin
        case(State_And_TA4)
          SELF_AND_IDLE:
            begin
              if(!Hitout_TA_Delay1[4] && Hitout_TA_Delay2[4] )
                begin     
                  State_And_Next_TA4      =   SELF_AND_HIGH;
                end   
              else if(In_Valid_TA_for_Self_Mod[4] == 1'b0)
                begin
                  State_And_Next_TA4      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA4      =   SELF_AND_IDLE;
                end   
            end   
          SELF_AND_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[4]  ==  1'b0)
                begin
                  State_And_Next_TA4      =   SELF_AND_ALWAYS_HIGH;
                end   
              else if(Cnt_High_And_TA4 < 12'd50)        //50*20ns = 1us Means the Last of High 
                begin
                  State_And_Next_TA4      =   SELF_AND_HIGH;
                end     
              else
                begin
                  State_And_Next_TA4      =   SELF_AND_IDLE;
                end   

            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              if(In_Valid_TA_for_Self_Mod[4] == 1'b0)
                begin
                  State_And_Next_TA4      =   SELF_AND_ALWAYS_HIGH;
                end   
              else
                begin
                  State_And_Next_TA4      =   SELF_AND_IDLE;
                end   
            end   
          default:
            begin
              State_And_Next_TA4          =   SELF_AND_IDLE;
            end   
        endcase
      end   
  end   



always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_High_And_TA4                <=  12'd0;
        State_Hit[4]                    <=  1'b1;
      end   
    else
      begin
        case(State_And_TA4)
          SELF_AND_IDLE:
            begin
              Cnt_High_And_TA4          <=  12'd0;
              State_Hit[4]              <=  1'b0;
            end   
          SELF_AND_HIGH:
            begin
              Cnt_High_And_TA4          <=  Cnt_High_And_TA4 + 1'b1;
              State_Hit[4]              <=  1'b1;
            end   
          SELF_AND_ALWAYS_HIGH:
            begin
              Cnt_High_And_TA4          <=  12'd0;
              State_Hit[4]              <=  1'b1;
            end   
        default:
          begin
              Cnt_High_And_TA4          <=  12'd0;
              State_Hit[4]              <=  1'b1;

          end   
          
        endcase 
      end   
  end     
/*-------------And State----------------*/
always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        And_State                      <=  SELF_STATE_IDLE;
      end   
    else
      begin
        And_State                      <=  And_State_Next;
      end   
  end   

always @ ( * )
  begin
    if(~Rst_N)
      begin
        And_State_Next                 =   SELF_STATE_IDLE;
      end   
    else
      begin
        And_State_Next                 =   SELF_STATE_IDLE;
        case(And_State)
          SELF_STATE_IDLE:
            begin
              if(State_Hit[1] && State_Hit[2] && State_Hit[3] && State_Hit[4] )     //All the Hit state AND the no use TA will always be high
                begin
                  And_State_Next       =   SELF_STATE_SEND_TRIG;
                end                   
              else
                begin
                  And_State_Next       =   SELF_STATE_IDLE;
                end   
            end   
          SELF_STATE_SEND_TRIG:
            begin
              if(Cnt_High_of_Trig_And    < WIDTH_OF_TRIG - 1'b1)
                begin
                  And_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else
                begin
                  And_State_Next       =   SELF_STATE_BUSY;
                end   
            end   
          SELF_STATE_BUSY:
            begin
              if(Cnt_Busy_of_Trig_And        < CNT_BUSY_END - 1'b1)
                begin
                  And_State_Next       =   SELF_STATE_BUSY;
                end   
              else
                begin
                  And_State_Next       =   SELF_STATE_IDLE;
                end   
            end   
          default:
            begin
              And_State_Next           =   SELF_STATE_IDLE;
            end   
        endcase         
      end   
  end   


  always @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          Cnt_High_of_Trig_And             <=  12'd0;
          Cnt_Busy_of_Trig_And             <=  12'd0;
          Trig_of_And_Mode                 <=  1'b0;
        end  
      else
        begin
          case(And_State)
            SELF_STATE_IDLE:
              begin
                Cnt_High_of_Trig_And             <=  12'd0;
                Cnt_Busy_of_Trig_And             <=  12'd0;
                Trig_of_And_Mode                 <=  1'b0;
              
              end   
            SELF_STATE_SEND_TRIG:
              begin
                Cnt_High_of_Trig_And             <=  Cnt_High_of_Trig_And + 1'b1;
                Cnt_Busy_of_Trig_And             <=  12'd0;
                Trig_of_And_Mode                 <=  1'b1;
                
              end   
            SELF_STATE_BUSY:
              begin
                Cnt_High_of_Trig_And             <=  12'd0;
                Cnt_Busy_of_Trig_And             <=  Cnt_Busy_of_Trig_And + 1'b1;
                Trig_of_And_Mode                 <=  1'b0;
                
              end   
            default:
              begin
                Cnt_High_of_Trig_And             <=  12'd0;
                Cnt_Busy_of_Trig_And             <=  12'd0;
                Trig_of_And_Mode                 <=  1'b0;
                
              end   
          endcase           
        end   
    end   

/*-------------Inside mode--------------*/
//every 1 ms Time_1ms = 1'b1, last 1 cycle.
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Time_1ms <= 1'b0;
      Cnt_1ms  <= 16'h0;
    end
  else
    begin
      if(Cnt_1ms == 16'd50000 - 1'b1) //50000 = C350  Set 1ms  Why - 1? : if == 5  the Cnt is 0 1 2 3 4 5 0 1 2 3 4 5 0 ... there are 6 cycs between 0 to 0. So need - 1;  
        begin
          Cnt_1ms <= 16'h0;
          Time_1ms<= 1'b1; 
        end
      else
        begin
          Cnt_1ms <= Cnt_1ms + 1'b1;
          Time_1ms<= 1'b0; 
        end
    end
end

//Generate Trig of Inside mode

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      State_Inside         <= IDLE_IN;

    end
  else
    begin
      State_Inside         <= Next_State_Inside; 
    end
end

always @ ( * )
begin
  if(~Rst_N)
    begin
      Next_State_Inside             = IDLE_IN;
    end
  else 
    begin
      Next_State_Inside             = IDLE_IN;

      case (State_Inside)
        IDLE_IN:            
          begin
            if(In_Control_Trig_Mode == 4'b0001)
              begin
                Next_State_Inside   = CNT_IN;
              end
            else
              begin
                Next_State_Inside   = IDLE_IN;
              end
          end
        CNT_IN:                           //Cnt total 1ms until In_Set_Trig_Inside_Time
          begin
            if(In_Control_Trig_Mode != 4'b0001)
              begin
                Next_State_Inside   = IDLE_IN;//When mode is changed, Turn to IDLE
              end
            else if(Cnt_Num_Of_1ms == In_Set_Trig_Inside_Time )
              begin
                Next_State_Inside   = HIGH_IN;
              end
            else
              begin
                Next_State_Inside   = CNT_IN;
              end
          end
        HIGH_IN:
          begin
            if(Cnt_High_of_Trig_Inside == WIDTH_OF_TRIG - 1'b1)// Why - 1 ?   : Cnt_High_of_Trig_Inside is decided by HIGH_IN of State, but state is delayed 1cyc to Next_State, Next state is synchronized to Cnt_High_of_Trig_Inside. If Cnt is decided by next,then ==Width but Cnt is decided by state So == WIDTH - 1
              Next_State_Inside     = CNT_IN;
            else
              Next_State_Inside     = HIGH_IN;
          end
        default:
            Next_State_Inside       = IDLE_IN;
      endcase   
    end
end
//Cnt num of 1ms until == In_Set_Trig_Inside_Time
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
          Cnt_Num_Of_1ms <= 8'h0;
    end
  else if(State_Inside == CNT_IN) // all Cyc is this  +  HIGH time.  if 1ms , then High time can be ignored. Since  Cnt_Num_Of_1ms == 14 last only 1 cyc (other last 1Ms) ,then Cnt_Num_Of_1ms == In_Set_Trig_Inside_Time is just OK
    begin
      if(Time_1ms)
        begin
          Cnt_Num_Of_1ms <= Cnt_Num_Of_1ms + 1'b1;
        end
      else if (Cnt_Num_Of_1ms == In_Set_Trig_Inside_Time)
        begin
          Cnt_Num_Of_1ms <= 8'h0;
        end
      else
        begin
          Cnt_Num_Of_1ms <= Cnt_Num_Of_1ms;
        end
    end
  else
    begin
      Cnt_Num_Of_1ms <= 8'h0;
    end
end
// Cnt Trig High time until Cnt == WIDTH_OF_TRIG
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Cnt_High_of_Trig_Inside <= 8'h0;
      Trig_of_Inside_Mode     <= 1'b0; //Inside Trig signal
    end
   else if(State_Inside == HIGH_IN)
    begin
      Cnt_High_of_Trig_Inside <= Cnt_High_of_Trig_Inside + 1'b1;
      Trig_of_Inside_Mode     <= 1'b1;
    end
   else
    begin
      Cnt_High_of_Trig_Inside <= 8'h0;
      Trig_of_Inside_Mode     <= 1'b0;
    end

end
//Decide which Trig signal to use

always @ ( * )
begin
  if(In_Start_Stop_Trig == 1'b0)
    begin
      Out_Trig_Sigal          = 1'b0;
    end
  else
  begin
    case(In_Control_Trig_Mode)
    4'b0001:
      begin
        Out_Trig_Sigal        = Trig_of_Inside_Mode;
        
      end
    4'b0010:
      begin
        Out_Trig_Sigal        = Trig_of_Exide_Mode;
      end
    4'b0100:
      begin
        Out_Trig_Sigal        = Trig_of_Self_Mode;
      end
    4'b1000:
      begin
        Out_Trig_Sigal        = Trig_of_And_Mode;
      end   
    default:
        Out_Trig_Sigal        = Trig_of_Inside_Mode;
    endcase
  end
end


/*--------------Ex_Mode--------------------*/
always  @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Ex_Trig_Delay1              <=  1'b0;
      Ex_Trig_Delay2              <=  1'b0;
    end   
  else
    begin
      Ex_Trig_Delay1              <=  In_Ex_Trig;
      Ex_Trig_Delay2              <=  Ex_Trig_Delay1;
    end   
end   

always  @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N )
    begin
      Ex_State                    <=  EX_STATE_IDLE;
    end   
  else
    begin
      Ex_State                    <=  Ex_State_Next;
    end   
end   

always @ (*)
begin
  if(~Rst_N)
    begin
      Ex_State_Next               =   EX_STATE_IDLE;
    end   
  else
    begin
      Ex_State_Next               =   EX_STATE_IDLE;
      case(Ex_State)
        EX_STATE_IDLE:
          begin
            if(Ex_Trig_Delay2)
              begin
                Ex_State_Next     =   EX_STATE_SEND_TRIG;
              end   
            else
              begin
                Ex_State_Next     =   EX_STATE_IDLE;                
              end   
          end   
        EX_STATE_SEND_TRIG:
          begin
            if(Cnt_High_of_Trig_Ex  ==  WIDTH_OF_TRIG - 1'b1)
              begin
                Ex_State_Next     =   EX_STATE_BUSY;
              end   
            else
              begin
                Ex_State_Next     =   EX_STATE_SEND_TRIG;
              end   
          end   
        EX_STATE_BUSY:
          begin
            if(Cnt_Busy_End_Ex      ==  CNT_BUSY_END  - 1'b1)
              begin
                Ex_State_Next     =   EX_STATE_IDLE;

              end
            else
              begin
                Ex_State_Next     =   EX_STATE_BUSY;
              end   
          end   
        default:  Ex_State_Next   =   EX_STATE_IDLE;
      endcase         
    end   
 
end   

always  @ (posedge  Clk or negedge  Rst_N)
begin
  if(~Rst_N)
    begin
      Cnt_Busy_End_Ex             <=  12'd0;
      Cnt_High_End_Ex             <=  12'd0;
      Trig_of_Exide_Mode          <=  1'b0;
    end   
  else
    begin
      case(Ex_State)
        EX_STATE_IDLE:
          begin
            Cnt_Busy_End_Ex       <=  12'd0;
            Cnt_High_of_Trig_Ex   <=  12'd0;
            Trig_of_Exide_Mode    <=  12'd0;
          end   
        EX_STATE_SEND_TRIG:
          begin
            Cnt_High_of_Trig_Ex   <=  Cnt_High_of_Trig_Ex + 1'b1;
            Cnt_Busy_End_Ex       <=  12'd0;
            Trig_of_Exide_Mode    <=  1'b1;
          end   
        EX_STATE_BUSY:
          begin
            Trig_of_Exide_Mode    <=  1'b0;
            Cnt_High_of_Trig_Ex   <=  12'd0;
            Cnt_Busy_End_Ex       <=  Cnt_Busy_End_Ex + 1'b1;
          end
        default:
          begin
            Cnt_Busy_End_Ex       <=  12'd0;
            Cnt_High_of_Trig_Ex   <=  12'd0;
            Trig_of_Exide_Mode    <=  12'd0;            
          end   
      endcase       
    end   
end   

/*-----Self Trig mode-----*/
always @ (posedge Clk or negedge Rst_N)                 //for Valid Hit Signal
  begin
    if(~Rst_N)
      begin
        Hitout_TA_Delay1[1]             <=  1'b0;
        Hitout_TA_Delay2[1]             <=  1'b0;
      end   
    else if(~In_Valid_TA_for_Self_Mod[1])
      begin
        Hitout_TA_Delay1[1]             <=  1'b0;
        Hitout_TA_Delay2[1]             <=  1'b0;
      end   
    else
      begin
        Hitout_TA_Delay1[1]             <=  In_Hitout_TA[1];
        Hitout_TA_Delay2[1]             <=  Hitout_TA_Delay1[1];
      end
  end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Hitout_TA_Delay1[2]             <=  1'b0;
        Hitout_TA_Delay2[2]             <=  1'b0;
      end   
    else if(~In_Valid_TA_for_Self_Mod[2])
      begin
        Hitout_TA_Delay1[2]             <=  1'b0;
        Hitout_TA_Delay2[2]             <=  1'b0;
      end   
    else
      begin
        Hitout_TA_Delay1[2]             <=  In_Hitout_TA[2];
        Hitout_TA_Delay2[2]             <=  Hitout_TA_Delay1[2];
      end
  end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Hitout_TA_Delay1[3]             <=  1'b0;
        Hitout_TA_Delay2[3]             <=  1'b0;
      end   
    else if(~In_Valid_TA_for_Self_Mod[3])
      begin
        Hitout_TA_Delay1[3]             <=  1'b0;
        Hitout_TA_Delay2[3]             <=  1'b0;
      end   
    else
      begin
        Hitout_TA_Delay1[3]             <=  In_Hitout_TA[3];
        Hitout_TA_Delay2[3]             <=  Hitout_TA_Delay1[3];
      end
  end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Hitout_TA_Delay1[4]             <=  1'b0;
        Hitout_TA_Delay2[4]             <=  1'b0;
      end   
    else if(~In_Valid_TA_for_Self_Mod[4])
      begin
        Hitout_TA_Delay1[4]             <=  1'b0;
        Hitout_TA_Delay2[4]             <=  1'b0;
      end   
    else
      begin
        Hitout_TA_Delay1[4]             <=  In_Hitout_TA[4];
        Hitout_TA_Delay2[4]             <=  Hitout_TA_Delay1[4];
      end
  end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Self_State                      <=  SELF_STATE_IDLE;
      end   
    else
      begin
        Self_State                      <=  Self_State_Next;
      end   
  end   

always @ ( * )
  begin
    if(~Rst_N)
      begin
        Self_State_Next                 =   SELF_STATE_IDLE;
      end   
    else
      begin
        Self_State_Next                 =   SELF_STATE_IDLE;
        case(Self_State)
          SELF_STATE_IDLE:
            begin
              if(!Hitout_TA_Delay1[1] && Hitout_TA_Delay2[1])     //tell the falling edge
                begin
                  Self_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else if(!Hitout_TA_Delay1[2] && Hitout_TA_Delay2[2])
                begin
                  Self_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else if(!Hitout_TA_Delay1[3] && Hitout_TA_Delay2[3])
                begin
                  Self_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else if(!Hitout_TA_Delay1[4] && Hitout_TA_Delay2[4])
                begin
                  Self_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else
                begin
                  Self_State_Next       =   SELF_STATE_IDLE;
                end   
            end   
          SELF_STATE_SEND_TRIG:
            begin
              if(Cnt_High_of_Trig_Self    < WIDTH_OF_TRIG - 1'b1)
                begin
                  Self_State_Next       =   SELF_STATE_SEND_TRIG;
                end   
              else
                begin
                  Self_State_Next       =   SELF_STATE_BUSY;
                end   
            end   
          SELF_STATE_BUSY:
            begin
              if(Cnt_Busy_End_Self        < CNT_BUSY_END - 1'b1)
                begin
                  Self_State_Next       =   SELF_STATE_BUSY;
                end   
              else
                begin
                  Self_State_Next       =   SELF_STATE_IDLE;
                end   
            end   
          default:
            begin
              Self_State_Next           =   SELF_STATE_IDLE;
            end   
        endcase         
      end   
  end   


  always @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          Cnt_High_of_Trig_Self         <=  12'd0;
          Cnt_Busy_End_Self             <=  12'd0;
          Trig_of_Self_Mode             <=  1'b0;
        end  
      else
        begin
          case(Self_State)
            SELF_STATE_IDLE:
              begin
                Cnt_High_of_Trig_Self   <=  12'd0;
                Cnt_Busy_End_Self       <=  12'd0;
                Trig_of_Self_Mode       <=  1'b0;
              end   
            SELF_STATE_SEND_TRIG:
              begin
                Cnt_High_of_Trig_Self   <=  Cnt_High_of_Trig_Self + 1'b1; //Cnt to 500ns
                Cnt_Busy_End_Self       <=  12'd0;
                Trig_of_Self_Mode       <=  1'b1;                     //Send Trig Self mode
              end   
            SELF_STATE_BUSY:
              begin
                Cnt_High_of_Trig_Self   <=  12'd0;                    //Remain 0
                Cnt_Busy_End_Self       <=  Cnt_Busy_End_Self + 1'b1;
                Trig_of_Self_Mode       <=  1'b0;                       //remain 0
              end   
            default:
              begin
                Cnt_High_of_Trig_Self   <=  12'd0;
                Cnt_Busy_End_Self       <=  12'd0;
                Trig_of_Self_Mode       <=  1'b0;
              end   
          endcase           
        end   
    end   

endmodule
/*Inside Mode */
