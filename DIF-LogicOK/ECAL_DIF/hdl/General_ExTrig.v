`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/14 17:30:03
// Design Name: 
// Module Name: General_ExTrig
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module General_ExTrig(
    input Clk,
    input Rst_N,
    input In_Trig_SMA,
    output Out_Ex_Trig
    );


	reg Sig_Ex_Trig;
  reg In_Trig_SMA_Delay1;
  reg In_Trig_SMA_Delay2;

always @ (posedge Clk or negedge Rst_N)
begin
	if(~Rst_N)
	begin
		In_Trig_SMA_Delay1 <= 1'b0;
		In_Trig_SMA_Delay2 <= 1'b0;
	end		
	else
	begin
		In_Trig_SMA_Delay1 <= In_Trig_SMA;
		In_Trig_SMA_Delay2 <= In_Trig_SMA_Delay1;
	end		
end		


localparam    [3:0]   STATE_SET_DAC_IDLE = 4'd0,
                      STATE_SET_DAC_LOOP = 4'd1;

reg [3:0]             State_Trig;                      
reg [7:0]             Cnt_State_Trig;
              

always @ (posedge Clk , negedge Rst_N) begin
  if(~Rst_N)
    begin
      State_Trig               <= STATE_SET_DAC_IDLE;
      Sig_Ex_Trig              <= 1'b0;
			Cnt_State_Trig           <= 8'd0;
    end   
  else
    begin
      case(State_Trig)
        STATE_SET_DAC_IDLE:
          begin
            if(In_Trig_SMA_Delay1 && !In_Trig_SMA_Delay2) //rising edge effect
              begin
                State_Trig     <= STATE_SET_DAC_LOOP;
                Sig_Ex_Trig    <= 1'b1;
                Cnt_State_Trig <= Cnt_State_Trig + 1'b1;
              end   
            else
              begin
                State_Trig     <= STATE_SET_DAC_IDLE;
                Cnt_State_Trig <= 8'd0;
                Sig_Ex_Trig    <= 1'b0;
              end   
          end   
        STATE_SET_DAC_LOOP:
          begin
            if(Cnt_State_Trig > 8'd5)//1 means 2clk 5= 6*12.5 = 75 ns   40 means 41*12.5 =  512ns
              begin
                State_Trig     <= STATE_SET_DAC_IDLE;
                Sig_Ex_Trig    <= 1'b0;
                Cnt_State_Trig <= 8'd0;
              end   
            else
              begin
                State_Trig     <= STATE_SET_DAC_LOOP;
                Cnt_State_Trig <= Cnt_State_Trig + 1'b1;
                Sig_Ex_Trig    <= 1'b1;
              end   
          end   
      endcase
    end   

end


	assign Out_Ex_Trig = Sig_Ex_Trig;

endmodule
