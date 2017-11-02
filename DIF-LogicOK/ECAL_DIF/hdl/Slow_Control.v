`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module is for configging slow control function
//By Siyuan Ma 2017.1.11
//Discription: 
//The ASIC SKIROC2 has 616bit slow control register which need to be filled
//before start acquisition.
//////////////////////////////////////////////////////////////////////////////////
module Slow_Control(
    input                 Clk, // 5MHz
    input                 Rst_N,
    input                 Start_In,     //Start Configging
    output reg            End_SC,

/*-------------Out to ASIC--------------*/
    output reg            Out_Sr_Ck,    //Clock of config
    output reg            Out_Sr_In,    //Dout of every bit
    output reg            Out_Sr_Rstb,   //Reset of register
/*--------------IO of Ex fifo----------*/
    input     [7:0]       In_Ex_Fifo_Data,   //Command to be config to register, modified outside this module in usbinterpreter module
    input                 In_Ex_Fifo_Empty,
    output reg            Out_Ex_Fifo_Rd_En
    );


  reg                     Start_In_Delay;     //for delay start signal to tell the rising edge
  reg                     Out_Sr_Ck_Delay;

  reg   [7:0]             Shift_8_Bit;


  reg   [7:0]             Cnt_Rst;
  reg   [7:0]             Cnt_Set_Bit,
                          Cnt_Send_Bit,
                          Cnt_Sent_Bit;
  reg   [11:0]            Cnt_Sent_Data;
                          


  reg   [4:0]             State,
                          State_Next;
  localparam  [4:0]       STATE_IDLE            =   5'd0,
                          STATE_RST             =   5'd1,
                          STATE_WAIT            =   5'd2,
                          STATE_GET_DATA        =   5'd3,
                          STATE_SET_BIT         =   5'd4,
                          STATE_SNED_BIT        =   5'd5,
                          STATE_READ_FIFO       =   5'd7,
                          STATE_SHIFT_DATA      =   5'd8,
                          STATE_END             =   5'd6;

//--------------Delay to tell the rising edge------//

 always @ (posedge Clk , negedge Rst_N)
   begin
     if(~Rst_N)
       begin
         Start_In_Delay         <=    1'b0;
       end    
     else
       begin
         Start_In_Delay         <=    Start_In;
       end    
   end    

/*-------------Telling the rising edge of Out_Sr_Ck ----*/

 always @ (posedge Clk  , negedge Rst_N)
   begin
     if(~Rst_N)
       begin
         Out_Sr_Ck_Delay        <=  1'b0;
       end    
     else
       begin
         Out_Sr_Ck_Delay        <=  Out_Sr_Ck;
       end    
   end    


/*------------Counting Sent bit-and data-----------------------*/

 always @ (posedge Clk  , negedge Rst_N)
   begin
     if(~Rst_N)
       begin
         Cnt_Sent_Data          <=  12'd0;
       end    
     else if(State    ==    STATE_IDLE)
       begin
         Cnt_Sent_Data          <=  12'd0;
       end    
     else if(Out_Sr_Ck  && !Out_Sr_Ck_Delay)
       begin
         Cnt_Sent_Data          <=  Cnt_Sent_Data + 1'b1;
       end    
     else
       begin
         Cnt_Sent_Data          <=  Cnt_Sent_Data;
       end    
       
   end    
 always @ (posedge Clk  , negedge Rst_N)
   begin
     if(~Rst_N)
       begin
         Cnt_Sent_Bit          <=  8'd0;
       end    
     else if(State    ==    STATE_IDLE || State ==  STATE_READ_FIFO)
       begin
         Cnt_Sent_Bit          <=  8'd0;
       end    
     else if(Out_Sr_Ck  && !Out_Sr_Ck_Delay)
       begin
         Cnt_Sent_Bit          <=  Cnt_Sent_Bit + 1'b1;
       end    
     else
       begin
         Cnt_Sent_Bit          <=  Cnt_Sent_Bit;
       end    
       
   end 
/*---------------State of Sending configing bits-------*/

always @ (posedge Clk   , negedge  Rst_N)
  begin
    if(~Rst_N)
      begin
        State              <=    STATE_IDLE;
      end   
    else
      begin
        State              <=    State_Next;
      end

  end   


 always @ (*)
   begin
    if(~Rst_N)
      begin
        State_Next                =     STATE_IDLE;
      end   
    else
      begin
        State_Next                =     STATE_IDLE;
        case(State)
          STATE_IDLE:
            begin
              if(Start_In && !Start_In_Delay)     //rising edge of start
                begin
                  State_Next      =     STATE_RST; 
                end   
              else
                begin
                  State_Next      =     STATE_IDLE;
                end   
            end   
          STATE_RST:
            begin
              if(Cnt_Rst < 8'd5)                  //Reset signal last for 5 cyc  1 us
                begin
                  State_Next      =     STATE_RST;
                end   
              else
                begin
                  State_Next      =     STATE_READ_FIFO;
                end               
            end   
          STATE_READ_FIFO:
            begin
              if(!In_Ex_Fifo_Empty)
                begin
                  State_Next      =     STATE_WAIT;
                end   
              else
                begin
                  State_Next      =     STATE_END;
                end   
            end   
          STATE_WAIT:
            begin
              State_Next          =     STATE_GET_DATA;
            end   
          STATE_GET_DATA:
            begin
              State_Next          =     STATE_SET_BIT;
            end   
          STATE_SET_BIT:
            begin
              if(Cnt_Set_Bit    < 8'd2)
                begin
                  State_Next      =     STATE_SET_BIT;
                end   
              else
                begin
                  State_Next      =     STATE_SNED_BIT;
                end   
            end   
          STATE_SNED_BIT:
            begin
              if(Cnt_Send_Bit   < 8'd3)
                begin
                  State_Next      =     STATE_SNED_BIT;
                end   
              else
                begin
                  if(Cnt_Sent_Bit  < 8'd8)
                    begin
                      State_Next  =     STATE_SHIFT_DATA;
                    end   
                  else
                    begin
                      State_Next  =     STATE_READ_FIFO;
                    end   
                end   
            end
          STATE_SHIFT_DATA:
            begin
              State_Next          =     STATE_SET_BIT;
            end   
          STATE_END:
            begin
              State_Next          =     STATE_IDLE;
            end   
          default:
            begin
              State_Next          =     STATE_IDLE;
            end   
        endcase     
      end   
   end    

always @ (posedge Clk , negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Out_Sr_Ck                 <=  1'b0;
        Out_Sr_In                 <=  1'b0;
        Out_Sr_Rstb               <=  1'b1;
        Shift_8_Bit               <=  8'd0;
        Out_Ex_Fifo_Rd_En         <=  1'b0;
        Cnt_Rst                   <=  8'b0;
        Cnt_Set_Bit               <=  8'b0;
        Cnt_Send_Bit              <=  8'd0;
        End_SC                    <=  1'b0;
        
      end 
    else
      begin
        case(State)
          STATE_IDLE:
            begin
              Out_Sr_Ck                 <=  1'b0;
              Out_Sr_In                 <=  1'b0;
              Out_Sr_Rstb               <=  1'b1;   //Do not reset
              Shift_8_Bit               <=  8'd0;
              Out_Ex_Fifo_Rd_En         <=  1'b0;
              Cnt_Rst                   <=  8'b0;
              Cnt_Set_Bit               <=  8'b0;
              Cnt_Send_Bit              <=  8'd0;
              End_SC                    <=  1'b0;

            end   
          STATE_RST:
            begin
              Out_Sr_Ck                 <=  1'b0;
              Out_Sr_In                 <=  1'b0;
              Out_Sr_Rstb               <=  1'b0;         //Reset slow control
              Shift_8_Bit               <=  8'd0;
              Out_Ex_Fifo_Rd_En         <=  1'b0;
              Cnt_Rst                   <=  Cnt_Rst   + 1'b1;
              Cnt_Send_Bit              <=  8'd0;
              Cnt_Set_Bit               <=  8'b0;
              End_SC                    <=  1'b0;
            end   
          STATE_READ_FIFO:
            begin
              if(!In_Ex_Fifo_Empty)
                begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;     
                  Shift_8_Bit               <=  8'd0;
                  Out_Ex_Fifo_Rd_En         <=  1'b1;     //Get ready to Read data from exfifo 
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;
                end   
              else
                begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;     
                  Shift_8_Bit               <=  8'd0;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;     //Do not read  
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;

                end   
            end   
          STATE_WAIT:
            begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;     //lose reset signal
                  Shift_8_Bit               <=  8'd0;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;     //Do not read  
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;

            end   
          STATE_GET_DATA:
            begin 
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;    
                  Shift_8_Bit               <=  In_Ex_Fifo_Data;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;   
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;
              
            end 
          STATE_SET_BIT:
            begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  Shift_8_Bit[7];
                  Out_Sr_Rstb               <=  1'b1;    
                  Shift_8_Bit               <=  Shift_8_Bit;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;     
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  Cnt_Set_Bit + 1'b1;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;

            end   
          STATE_SNED_BIT:
            begin
                  Out_Sr_Ck                 <=  1'b1;       //rising edge of Out_Sr_Ck
                  Out_Sr_In                 <=  Out_Sr_In;  //Hold for time
                  Out_Sr_Rstb               <=  1'b1;       //Do not reset
                  Shift_8_Bit               <=  Shift_8_Bit;//Hold
                  Out_Ex_Fifo_Rd_En         <=  1'b0;     
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  Cnt_Send_Bit  + 1'b1; //Cnt time
                  End_SC                    <=  1'b0;
              
            end   
          STATE_SHIFT_DATA:
            begin
                  Out_Sr_Ck                 <=  1'b0;       //falling edge       
                  Out_Sr_In                 <=  Out_Sr_In;    //Hold
                  Out_Sr_Rstb               <=  1'b1;    
                  Shift_8_Bit               <=  Shift_8_Bit <<  1;  //left shifting 1 bit
                  Out_Ex_Fifo_Rd_En         <=  1'b0;   
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b0;

            end   
          STATE_END:
            begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;    
                  Shift_8_Bit               <=  8'd0;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;   
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
                  End_SC                    <=  1'b1;
              
            end   
          default:
            begin
                  Out_Sr_Ck                 <=  1'b0;
                  Out_Sr_In                 <=  1'b0;
                  Out_Sr_Rstb               <=  1'b1;    
                  Shift_8_Bit               <=  8'd0;
                  Out_Ex_Fifo_Rd_En         <=  1'b0;   
                  Cnt_Rst                   <=  8'b0;
                  Cnt_Set_Bit               <=  8'b0;
                  Cnt_Send_Bit              <=  8'd0;
              
            end   

        endcase     
      end   
      
  end   

endmodule
