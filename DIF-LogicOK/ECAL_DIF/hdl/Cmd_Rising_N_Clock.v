`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/24 21:07:10
// Design Name: 
// Module Name: Cmd_Rising_N_Clock
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


module Cmd_Rising_N_Clock(
    input Clk_In,
    input Rst_N,
    input [16:1] Cmd_In,
    input Cmd_En,
    output reg Output_Valid_Sig
    );
    
    
		parameter [16:1] EFFECT_CMD = 16'h0; //default 0
	  parameter [8:1] LAST_CYC = 8'd10; //default :10 Clock




	localparam [3:0] STATE_IDLE = 4'd0;
	localparam [3:0] STATE_LOOP = 4'd1;



    reg [3:0]             State;
                          
    reg [7:0]             Cnt_State;
                  
    
    always @ (posedge Clk_In , negedge Rst_N) begin
      if(~Rst_N)
        begin
          State                      <= STATE_IDLE;
          Output_Valid_Sig           <= 1'b0;
          Cnt_State                  <= 8'd0;
        end   
      else
        begin
          case(State)
            STATE_IDLE:
              begin
                if(Cmd_En && Cmd_In  == EFFECT_CMD)
                  begin
                    State            <= STATE_LOOP;
                    Output_Valid_Sig <= 1'b1;
                  end   
                else
                  begin
                    State            <= STATE_IDLE;
                    Cnt_State        <= 8'd0;
                    Output_Valid_Sig <= 1'b0;
                  end   
              end   
            STATE_LOOP:
              begin
                if(Cnt_State > LAST_CYC-2)
                  begin
                    State            <= STATE_IDLE;
                    Output_Valid_Sig <= 1'b0;
                    Cnt_State        <= 8'd0;
                  end   
                else
                  begin
                    State            <= STATE_LOOP;
                    Cnt_State        <= Cnt_State + 1'b1;
                    Output_Valid_Sig <= 1'b1;
                  end   
              end   
          endcase
        end   
    
    end

endmodule
