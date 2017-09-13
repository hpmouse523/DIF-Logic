`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Siyuan Ma  
// 
// Create Date:    14:51:33 03/06/2017 
// Design Name: 
// Module Name:    Auto_Charge_Sent 
// Project Name: 
// Target Devices:FPGA Spartan 6 XC6SLX45 FG484 
// Tool versions: 1.0
// Description: This module is used to generate a Charge to input of SKIROC
//
// Dependencies: 
//
// Revision: 1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Auto_Charge_Sent(
    input Clk,
    input Rst_N,
    input [7:0] In_Interval_Time,//Range is 1-256ms
    input In_Start_Stop,
    output Out_Control_ADG
    );


reg               Sig_Control_ADG;
assign            Out_Control_ADG   =   Sig_Control_ADG;

reg               Time_1ms;
reg [15:0]        Cnt_1ms;
reg [7:0]         Cnt_Num_Of_1ms;
/*-/every 1 ms Time_1ms = 1'b1, last 1 cycle*/
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
      else if(State_Inside != CNT_IN)
        begin
          Cnt_1ms <=  16'd0;
          Time_1ms<=  1'b0;
        end   
      else
        begin
          Cnt_1ms <= Cnt_1ms + 1'b1;
          Time_1ms<= 1'b0; 
        end
    end
end
/*---------------------------------*/

reg [3:0]         State_Inside,
                  Next_State_Inside;

localparam  [3:0] IDLE_IN     =   4'd0,
                  CNT_IN      =   4'd1,
                  HIGH_IN     =   4'd2;

localparam  [7:0] WIDTH_OF_LAST = 8'd100; //10means 200ns of last time   100means 2us
reg [7:0]         Cnt_High_of_Trig_Inside;


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
            if(In_Start_Stop == 1'b1)
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
            if(In_Start_Stop != 1'b1)
              begin
                Next_State_Inside   = IDLE_IN;//When mode is changed, Turn to IDLE
              end
            else if(Cnt_Num_Of_1ms == In_Interval_Time )
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
            if(Cnt_High_of_Trig_Inside == WIDTH_OF_LAST - 1'b1)// Why - 1 ?   : Cnt_High_of_Trig_Inside is decided by HIGH_IN of State, but state is delayed 1cyc to Next_State, Next state is synchronized to Cnt_High_of_Trig_Inside. If Cnt is decided by next,then ==Width but Cnt is decided by state So == WIDTH - 1
              Next_State_Inside     = CNT_IN;
            else
              Next_State_Inside     = HIGH_IN;
          end
        default:
            Next_State_Inside       = IDLE_IN;
      endcase   
    end
end


always @ (posedge Clk or negedge Rst_N)
  begin
    if(~Rst_N)
      begin
        Cnt_High_of_Trig_Inside           <=  8'd0;
        Sig_Control_ADG                   <=  1'b0;
      end   
    else
      begin
        if(State_Inside     ==  HIGH_IN)
          begin
            Cnt_High_of_Trig_Inside       <=  Cnt_High_of_Trig_Inside     + 1'b1;
            Sig_Control_ADG               <=  1'b1;
          end   
        else
          begin
            Cnt_High_of_Trig_Inside       <=  8'd0;
            Sig_Control_ADG               <=  1'b0;
          end   
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
      else if (Cnt_Num_Of_1ms == In_Interval_Time)
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



endmodule
