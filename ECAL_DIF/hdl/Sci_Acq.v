`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Siyuan Ma
// 
// Create Date:    15:07:26 02/24/2017 
// Design Name:    Sci_Acq
// Module Name:    Sci_Acq 
// Project Name:   SKIROC
// Target Devices: FPGA Spartan 6 XC6SLX45 FG484
// Tool versions:  1.0
// Description:    This module controls Acq function of SKIROC2 
//
// Dependencies: 
//
// Revision: 1.0
// Revision 0.01 - File Created
// Additional Comments: Built on 2017.2.24
//
//////////////////////////////////////////////////////////////////////////////////
module Sci_Acq(
    input             Clk,
    input             Rst_N,
    
    input             In_Start_Work,
    output   reg      Out_Acqing,
    /*-----IO of SKIROC-----*/
    input             In_Chipsatb,
    input             In_End_Readout,
    input             In_Ex_Trig,//Adding this signal as INput of Extrig from SignalGenerator, to count the num of signals. using for efficiency of trigger Posedge effective
    output   [19:0]   Cnt_Trig,
    output   reg      Out_Start_Acq,
    output   reg      Out_Start_Convb,
    output   reg      Out_Start_Readout,
    output   reg      Out_Pwr_On_D,
    output   reg      Out_Resetb_ASIC
    );
    

/*-------Signals----------*/
    reg     Chipsatb_Delay1,
            Chipsatb_Delay2;
    reg     Chipsatb_Falling_Edge,
            Chipsatb_Rising_Edge;

    reg     End_Readout_Delay1,
            End_Readout_Delay2;
    reg     In_Ex_Trig_Delay1,
            In_Ex_Trig_Delay2;

 assign Cnt_Trig            = Cnt_Num_Ex_Trig;

 
  always  @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          End_Readout_Delay1           <=  1'b0;
          End_Readout_Delay2           <=  1'b0;
        end   
      else
        begin
          End_Readout_Delay1           <=  In_End_Readout;
          End_Readout_Delay2           <=  End_Readout_Delay1;
        end   
    end   
  always  @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          In_Ex_Trig_Delay1           <=  1'b0;
          In_Ex_Trig_Delay2           <=  1'b0;
        end   
      else
        begin
          In_Ex_Trig_Delay1           <=  In_Ex_Trig;
          In_Ex_Trig_Delay2           <=  In_Ex_Trig_Delay1;
        end   
    end   

 

  always  @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          Chipsatb_Delay1           <=  1'b1;
          Chipsatb_Delay2           <=  1'b1;
        end   
      else
        begin
          Chipsatb_Delay1           <=  In_Chipsatb;
          Chipsatb_Delay2           <=  Chipsatb_Delay1;
        end   
    end   
  always  @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          Chipsatb_Falling_Edge     <=  1'b0;
          Chipsatb_Rising_Edge      <=  1'b0;
        end   
      else  if(!Chipsatb_Delay1 && Chipsatb_Delay2)
        begin
          Chipsatb_Falling_Edge     <=  1'b1;
        end   
      else  if(Chipsatb_Delay1 && !Chipsatb_Delay2)
        begin
          Chipsatb_Rising_Edge      <=  1'b1;
        end   
      else
        begin
          Chipsatb_Falling_Edge     <=  1'b0;
          Chipsatb_Rising_Edge      <=  1'b0;
        end   
        
    end   

    /*-------Signals of state------*/
    reg       [19:0]  Cnt_Reset,
                      Cnt_Wait_2_Acq,
                      Cnt_Wait_2_Convb,
                      Cnt_Start_Convb,
                      Cnt_Wait_2_Readout,
                      Cnt_Start_Readout,
                      Cnt_Wait_2_End,
                      Cnt_Start_Acq,
                      Cnt_Num_Ex_Trig,
                      Cnt_Wait_2_Next;
    localparam  [19:0]  RESET_TIME        =   20'd25,//500ns last of Reset signal
                        WAIT_2_ACQ_TIME   =   20'd50,//1000ns of TminRstStart
                        WAIT_2_CONVB_TIEM =   20'd50,//1us of TminAcqConv
                        START_READOUT     =   20'd25,//500ns Last of Readout signal
                        WAIT_2_NEXT       =   20'd50,//1us of Wait to next round
                        START_ACQ         =   20'd1000000,//20ms
                        START_CONVB       =   20'd2,//1000 ns of convb last,demand 50ns width   50means 1000ns    2 means 50ns
                        WAIT_2_READOUT    =   20'd250000,//5ms wait to readout
                        WAIT_2_END        =   20'd250000,//5ms Wait until readout
                        TOTAL_NUM_EX_TRIG =   20'd500;// count to this num StartAcq will stop for Triggers efficiency
    

    reg       [4:0]   State,
                      State_Next;
    localparam [4:0]  STATE_IDLE          =   5'd0,
                      STATE_RESET         =   5'd1,
                      STATE_WAIT_2_ACQ    =   5'd2,
                      STATE_ACQ_START     =   5'd3,
                      STATE_WAIT_2_CONVB  =   5'd4,
                      STATE_START_CONVB   =   5'd5,
                      STATE_WAIT_2_READOUT=   5'd6,
                      STATE_START_READOUT =   5'd7,
                      STATE_WAIT_2_END    =   5'd8,
                      STATE_WAIT_2_NEXT   =   5'd9;

/*-----------State of Acq---------------*/
always  @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        State             <=  STATE_IDLE;
      end   
    else
      State               <=  State_Next;
  end   


always  @ (*)
  begin
    if(~Rst_N)
      begin
        State_Next        =   STATE_IDLE;
      end
    else
      begin
        case(State)
          STATE_IDLE:
            begin
              if(~In_Start_Work)
                begin
                  State_Next        =   STATE_IDLE;
                end 
              else
                begin
                  State_Next        =   STATE_RESET;
                end   
            end   
          STATE_RESET:
            begin
              if(Cnt_Reset  < RESET_TIME)
                begin
                  State_Next        =   STATE_RESET;
                end   
              else if(~In_Start_Work)
                begin
                  State_Next        =   STATE_IDLE;
                end   
              else if(Cnt_Num_Ex_Trig     >= TOTAL_NUM_EX_TRIG)
                begin
                  State_Next        =   STATE_IDLE;
                end   
              else
                begin
                  State_Next        =   STATE_WAIT_2_ACQ;
                end   
            end   
          STATE_WAIT_2_ACQ:
            begin
              if(Cnt_Wait_2_Acq   < WAIT_2_ACQ_TIME)
                begin
                  State_Next        =   STATE_WAIT_2_ACQ;
                end   
              else
                begin
                  State_Next        =   STATE_ACQ_START;
                end   
            end   
          STATE_ACQ_START:
            begin
               if( Chipsatb_Falling_Edge)
             // if(Cnt_Start_Acq >  START_ACQ || Chipsatb_Falling_Edge)
                begin
                  State_Next        =   STATE_WAIT_2_CONVB;
                end
                else if(Cnt_Num_Ex_Trig     >= TOTAL_NUM_EX_TRIG )
                begin
                  State_Next        =   STATE_WAIT_2_CONVB;
                end   
              else

                begin
                  State_Next        =   STATE_ACQ_START;
                end   
             end
          STATE_WAIT_2_CONVB:
            begin
              if(Cnt_Wait_2_Convb < WAIT_2_CONVB_TIEM)
                begin
                  State_Next        =   STATE_WAIT_2_CONVB;
                end   
              else
                begin
                  State_Next        =   STATE_START_CONVB;
                end   
            end   
          STATE_START_CONVB:// Convertion stop when time up to 5ms  ./ or chipsat is up
            begin
              if(Cnt_Start_Convb  < START_CONVB)
                begin
                  State_Next        =   STATE_START_CONVB;
                end   
              else
                begin
                  State_Next        =   STATE_WAIT_2_READOUT;
                end   
            end   
          STATE_WAIT_2_READOUT:
            begin
              if(Cnt_Wait_2_Readout< WAIT_2_READOUT)
                begin
                  State_Next        =   STATE_WAIT_2_READOUT;
                end   
              else
                begin
                  State_Next        =   STATE_START_READOUT;
                end   
            end   
          STATE_START_READOUT:
            begin
              if(Cnt_Start_Readout  < START_READOUT)
                begin
                  State_Next        =   STATE_START_READOUT;
                end   
              else
                begin
                  State_Next        =   STATE_WAIT_2_END;
                end   
            end   
            STATE_WAIT_2_END://Readout end when time up to 5ms or receive endreadout signal flag
            begin
              if(End_Readout_Delay1  &&  !End_Readout_Delay2)
                begin
                  State_Next        =   STATE_WAIT_2_NEXT;
                end
              else if(Cnt_Wait_2_End <  WAIT_2_END)
                begin
                  State_Next        =   STATE_WAIT_2_END;
                end   
              else
                begin
                  State_Next        =   STATE_WAIT_2_NEXT;
                end   
            end   
          STATE_WAIT_2_NEXT:
            begin
              if(Cnt_Wait_2_Next  < WAIT_2_NEXT)
                begin
                  State_Next        = STATE_WAIT_2_NEXT;
                end   
              else
                begin
                  State_Next        = STATE_RESET;
                end   
            end   

          default:
            State_Next              = STATE_IDLE;

        endcase
      end   
    
  end   

  always  @ (posedge Clk or negedge Rst_N)
    begin
      if(~Rst_N)
        begin
          Out_Acqing                <=  1'b0;
          Out_Start_Acq             <=  1'b0;
          Out_Start_Convb           <=  1'b1;
          Out_Resetb_ASIC           <=  1'b1;
          Out_Start_Readout         <=  1'b0;
          Cnt_Reset                 <=  20'd0;
          Cnt_Wait_2_Acq            <=  20'd0;
          Cnt_Wait_2_Convb          <=  20'd0;
          Cnt_Start_Convb           <=  20'd0;
          Cnt_Wait_2_Readout        <=  20'd0;
          Cnt_Start_Readout         <=  20'd0;
          Cnt_Wait_2_End            <=  20'd0;
          Cnt_Start_Acq             <=  20'd0;
          Out_Pwr_On_D              <=  1'b0;
          Cnt_Wait_2_Next           <=  20'd0;
        end   
      else
        begin
          case(State)
          STATE_IDLE:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Cnt_Wait_2_Next           <=  20'd0;
             Out_Pwr_On_D              <=   1'b0;
            end
          STATE_RESET:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Out_Resetb_ASIC           <=  1'b0;    //Reset ASIC
             Cnt_Reset                 <=  Cnt_Reset  + 1'b1;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Cnt_Wait_2_Next           <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;
            end   
          STATE_WAIT_2_ACQ:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Out_Resetb_ASIC           <=  1'b1;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  Cnt_Wait_2_Acq + 1'b1;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Cnt_Wait_2_Next           <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;

            end   
          STATE_ACQ_START:
            begin
             Out_Acqing                <=  1'b1;  //Start ACq Signal
             Out_Start_Acq             <=  1'b1;  //Start Acq Signal
             Out_Start_Convb           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Out_Resetb_ASIC           <=  1'b1;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  Cnt_Start_Acq  + 1'b1;
             Cnt_Wait_2_Next           <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;
              
            end   
          STATE_WAIT_2_CONVB:                                         //test double Convb and Convb H active mode
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  Cnt_Wait_2_Convb + 1'b1;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;
             Cnt_Wait_2_Next           <=  20'd0;
            end   
          STATE_START_CONVB:
            begin/*
              if(Cnt_Start_Convb > 20'd15 && Cnt_Start_Convb < 20'd30)
                begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;//Start Convb Signal Active L
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  Cnt_Start_Convb  + 1'b1;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Cnt_Wait_2_Next           <=  20'd0;
                end
             else
              begin*/
                Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b0;//Start Convb Signal Active L
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  Cnt_Start_Convb  + 1'b1;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;
             Cnt_Wait_2_Next           <=  20'd0;
             // end
            end   
          STATE_WAIT_2_READOUT:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  Cnt_Wait_2_Readout + 1'b1;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b1;
             Cnt_Wait_2_Next           <=  20'd0;
            end
          STATE_START_READOUT:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b1;//Start Readout Signal
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  Cnt_Start_Readout  + 1'b1;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b0;
             Cnt_Wait_2_Next           <=  20'd0;
            end 
          STATE_WAIT_2_END:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  Cnt_Wait_2_End + 1'b1;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b0;
             Cnt_Wait_2_Next           <=  20'd0;
            end
          STATE_WAIT_2_NEXT:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b0;
             Cnt_Wait_2_Next           <=  Cnt_Wait_2_Next  + 1'b1;
            end
          default:
            begin
             Out_Acqing                <=  1'b0;
             Out_Start_Acq             <=  1'b0;
             Out_Start_Convb           <=  1'b1;
             Out_Resetb_ASIC           <=  1'b1;
             Out_Start_Readout         <=  1'b0;
             Cnt_Reset                 <=  20'd0;
             Cnt_Wait_2_Acq            <=  20'd0;
             Cnt_Wait_2_Convb          <=  20'd0;
             Cnt_Start_Convb           <=  20'd0;
             Cnt_Wait_2_Readout        <=  20'd0;
             Cnt_Start_Readout         <=  20'd0;
             Cnt_Wait_2_End            <=  20'd0;
             Cnt_Start_Acq             <=  20'd0;
             Out_Pwr_On_D              <=  1'b0;
             Cnt_Wait_2_Next           <=  20'd0;

              
            end   
          endcase
        end   
        
    end   

always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_Num_Ex_Trig               <=  20'd0;
      end   
    else if(In_Ex_Trig_Delay1 && !In_Ex_Trig_Delay2)
      begin
        Cnt_Num_Ex_Trig               <=  Cnt_Num_Ex_Trig + 1'b1;       
      end   
    else if(State == STATE_IDLE)
      begin
        Cnt_Num_Ex_Trig               <=  20'd0;
      end   
    else
      begin
        Cnt_Num_Ex_Trig               <=  Cnt_Num_Ex_Trig;
      end   
  end   
endmodule
