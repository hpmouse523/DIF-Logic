`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Siyuan Ma  
// 
// Create Date:    11:25:07 03/13/2017 
// Design Name: 
// Module Name:    Read_Register_Set 
// Project Name: 
// Target Devices:FPGA Spartan 6 XC6SLX45 FG484 
// Tool versions: 1.0
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Read_Register_Set(
    input Clk,
    input Rst_N,
    input In_Enable_Register,
    input [64:1] In_Choose_Channel,
    input In_Start_Set_Register,
    output Out_Srin_Read,
    output Out_Ck_Read
    );

reg           Sig_Srin_Read,
              Sig_Ck_Read,
              Sig_Ck_Read_Delay;
assign        Out_Srin_Read       =   Sig_Srin_Read;
assign        Out_Ck_Read         =   Sig_Ck_Read;


reg   [7:0]   Cnt_Set_Bit,
              Cnt_Send_Bit,
              Cnt_Sent_Bit;

reg   [64:1]  Shift_64_Bit;
always@(posedge Clk)
  begin
    Sig_Ck_Read_Delay     <=  Sig_Ck_Read;
  end   
always  @ (posedge Clk or negedge Rst_N )
  begin
    if(~Rst_N)
      begin
        Cnt_Sent_Bit        <=  8'd0;
      end   
    else if( Sig_Ck_Read && !Sig_Ck_Read_Delay)
      begin
        Cnt_Sent_Bit        <=  Cnt_Sent_Bit  + 1'b1;
      end   
    else if(Status    ==  STATE_IDLE)

      begin
        Cnt_Sent_Bit        <=  8'd0;
      end   
    else
      begin
        Cnt_Sent_Bit        <=  Cnt_Sent_Bit;
      end   
  end   


reg   [3:0]   Status,
              Status_Next;
localparam    [3:0]     STATE_IDLE      = 4'd0,
                        STATE_SET_BIT   = 4'd1,
                        STATE_SEND_BIT  = 4'd2,
                        STATE_SHIFT_BIT = 4'd3;
always  @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Status    <=  STATE_IDLE;
      end   
    else
      begin
        Status    <=  Status_Next;
      end   
  end   

always  @ (*)
  begin
    if(~Rst_N)
      begin
        Status_Next       =   STATE_IDLE;
      end   
    else
      begin
        Status_Next       =   STATE_IDLE;
        case(Status)
          STATE_IDLE:
            begin
              if(~In_Enable_Register)
                begin
                  Status_Next         =   STATE_IDLE;
                end   
              else if (In_Start_Set_Register)
                begin
                  Status_Next         =   STATE_SET_BIT;
                end   
              else
                begin
                  Status_Next         =   STATE_IDLE;
                end   
            end   
          STATE_SET_BIT:
            begin
              if(Cnt_Set_Bit  < 8'd2) 
                begin
                  Status_Next         =   STATE_SET_BIT;
                end   
              else
                begin
                  Status_Next         =   STATE_SEND_BIT;
                end   
            end   
          STATE_SEND_BIT:
            begin
              if(Cnt_Send_Bit <8'd3)
                begin
                  Status_Next         =   STATE_SEND_BIT;
                end   
              else
                begin
                  if(Cnt_Sent_Bit <8'd64)
                    begin
                      Status_Next     =   STATE_SHIFT_BIT;
                    end   
                  else
                    begin
                      Status_Next     =   STATE_IDLE;
                    end   
                end   
            end   
          STATE_SHIFT_BIT:
            begin
              Status_Next             =   STATE_SET_BIT;
            end   
        endcase
      end   
  end   


always  @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Sig_Srin_Read         <=  1'b0;
        Sig_Ck_Read           <=  1'b0;
        Shift_64_Bit          <=  64'd0;
        Cnt_Set_Bit           <=  8'd0;
        Cnt_Send_Bit          <=  8'd0;

      end   
    else
      begin
        Sig_Srin_Read         <=  1'b0;
        Sig_Ck_Read           <=  1'b0;
        Shift_64_Bit          <=  In_Choose_Channel;
        Cnt_Set_Bit           <=  8'd0;
        Cnt_Send_Bit          <=  8'd0;

        
        case(Status)
          STATE_IDLE:
            begin
              Sig_Srin_Read         <=  1'b0;
              Sig_Ck_Read           <=  1'b0;
              Shift_64_Bit          <=  In_Choose_Channel;
              Cnt_Set_Bit           <=  8'd0;
              Cnt_Send_Bit          <=  8'd0;

            end
          STATE_SET_BIT:
            begin
              Sig_Srin_Read         <=  Shift_64_Bit[64];
              Sig_Ck_Read           <=  1'b0;
              Shift_64_Bit          <=  Shift_64_Bit;
              Cnt_Set_Bit           <=  Cnt_Set_Bit   + 1'b1;
              Cnt_Send_Bit          <=  8'd0;


            end   
          STATE_SEND_BIT:
            begin
              Sig_Srin_Read         <=  Sig_Srin_Read;
              Sig_Ck_Read           <=  1'b1;
              Shift_64_Bit          <=  Shift_64_Bit;
              Cnt_Set_Bit           <=  8'd0;
              Cnt_Send_Bit          <=  Cnt_Send_Bit  + 1'b1;
            end   
          STATE_SHIFT_BIT:
            begin
              Sig_Srin_Read         <=  Sig_Srin_Read;
              Sig_Ck_Read           <=  1'b0;
              Shift_64_Bit          <=  Shift_64_Bit  << 1;
              Cnt_Set_Bit           <=  8'd0;
              Cnt_Send_Bit          <=  8'd0;
            end   
        endcase
      end   
  end   

endmodule
