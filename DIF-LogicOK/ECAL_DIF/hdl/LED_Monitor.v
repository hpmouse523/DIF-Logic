//Module of LED_Monitor
//Actel FPGA Smartfusion2 M2S050 FG484
//University of Science and Technology of China
//By Siyuanma 2016.3.21  





module LED_Monitor (
  input Clk, //40M
  input Rst_N,
 
  output [5:0] LED
);

parameter T1S = 40000000;


parameter STATE_1 = 6'b00_0001;
parameter STATE_2 = 6'b00_0010;
parameter STATE_3 = 6'b00_0100;
parameter STATE_4 = 6'b00_1000;
parameter STATE_5 = 6'b01_0000;
parameter STATE_6 = 6'b10_0000;
parameter STATE_IDLE = 6'b00_0000;
  
reg [27:0] Cnt_Num; //to Count 1s 40M
reg [5:0] State;
reg [5:0] Next_State;

assign LED = State;

always @ (posedge Clk , negedge Rst_N)
begin
    if(~Rst_N)
    begin
     Cnt_Num <= 28'd0;
    end
    else if (Cnt_Num == T1S ) //1s
    begin
      Cnt_Num <= 28'd0;
    end
    else
    begin
      Cnt_Num <= Cnt_Num + 1'b1;
    end
 
end

always @ (posedge Clk , negedge Rst_N)
begin
  if(~Rst_N)
    State <= STATE_IDLE;
  else
    State <= Next_State;
end

always @ (*)
begin
  case(State)
    STATE_IDLE: 
      Next_State = STATE_1;
    STATE_1:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_2;
      else
        Next_State = STATE_1;
    end
    STATE_2:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_3;
      else
        Next_State = STATE_2;
    end
    STATE_3:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_4;
      else
        Next_State = STATE_3;
    end
    STATE_4:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_5;
      else
        Next_State = STATE_4;
    end
    STATE_5:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_6;
      else
        Next_State = STATE_5;
    end
    STATE_6:
    begin
      if(Cnt_Num == T1S)
        Next_State = STATE_1;
      else
        Next_State = STATE_6;
    end
    default:
      Next_State = STATE_IDLE;
  endcase
end

endmodule
