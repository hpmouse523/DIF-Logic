`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/15 15:27:51
// Design Name: 
// Module Name: test_Auto_DAC
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


module test_Auto_DAC(

    );
	reg Clk_10M;
	reg Rst_N;
	reg Start_Sig;
	wire [12:1] Ini_DAC = 12'ha00;
	wire [4:1] ID = 4'b1001;
	reg Hit_Sig;
	reg Trig_Sig;
	reg End_SC_Sig;
	wire Out_End_Flag;
	wire Out_Token_Sig;
	wire Out_Set_SC_Sig;
	wire [64:1] Out_Mask_Code;
	wire [12:1] Out_DAC_Code;
	wire [16:1] Out_Fifo_Din;
	wire Out_Fifo_Wr;

	initial 
	begin
		Clk_10M = 0;
		Rst_N = 0;
		Start_Sig = 0;
		Hit_Sig = 0;
		Trig_Sig = 0;
		#100
		Rst_N = 1'b1;
		#100
		Start_Sig = 1'b1;
		#500
		Start_Sig = 1'b0;
	end		

  always @ (*)
    begin
      #50
      Clk_10M <= ~Clk_10M; //10MHz Clock   
    end   
	
  always @ (*)
  begin
	  #5000
	  Trig_Sig <= ~Trig_Sig;
  end		
 /* always @ (posedge Trig_Sig )//100% hit
  begin
	#2000
	  Hit_Sig <= 1'b1;
	#500
	  Hit_Sig <= 1'b0;
  end		
*/

  always @(posedge Out_Set_SC_Sig)// 
  begin
	  #500
	  End_SC_Sig <= 1'b1;
	  #200
	  End_SC_Sig <= 1'b0;
  end		
 /*SKIROC2_S_Para_Scan SKIROC_Auto_TA_Inst(
    .Clk_10M(Clk_10M),
    .Rst_N(Rst_N),
    .In_Start(Start_Sig),
    .In_ID(ID),
    .In_Ini_DAC(Ini_DAC),
	.In_Hit_In(Hit_Sig),
    .In_Trig_In(Trig_Sig),//rising edge effect
	.In_Sc_End(End_SC_Sig),
    .Out_End(Out_End_Flag),
    .Out_Token(Out_Token_Sig),
    .Out_Set_SC(Out_Set_SC_Sig),
	.Out_Send_Trig(),
    .Out_Mask_Code(Out_Mask_Code),
    .Out_DAC_Code(Out_DAC_Code),
    .Out_Fifo_Din(Out_Fifo_Din),
    .Out_Fifo_Wr(Out_Fifo_Wr)
    );
*/
 Auto_TA_Scan Auto_TA_Scan_Inst(
     .Clk_10MHz(Clk_10M),
     .Rst_N(Rst_N),
     .Ini_DAC(Ini_DAC),
     .In_Trig_Ex_From_Signal(Trig_Sig),
     .In_Hit_From_SKIROC(Hit_Sig),
     .In_Start_Scan(Start_Sig),
	 .In_Finish_Sc(End_SC_Sig), //at least last 1cyc
     .Out_Finish_Scan(Out_End_Flag),
	 .Out_Set_SC(Out_Set_SC_Sig),
	 .Out_Set_DAC(Out_DAC_Code),//48bit but useful is 40bit
     .Out_Mask_Code(Out_Mask_Code),
     .Out_Fifo_Din(Out_Fifo_Din),
     .Out_Fifo_Wr(Out_Fifo_Wr)
    );
Fifo_Auto_TA FIFO_Auto_TA_Inst (
  .rst(~Rst_N),        // input wire rst
  .wr_clk(Clk_10M),  // input wire wr_clk
  .rd_clk(Clk_10M),  // input wire rd_clk
  .din(Out_Fifo_Din),        // input wire [15 : 0] din
  .wr_en(Out_Fifo_Wr),    // input wire wr_en
  .rd_en(1'b1),    // input wire rd_en
  .dout(),      // output wire [15 : 0] dout
  .full(),      // output wire full
  .empty()    // output wire empty
);
endmodule
