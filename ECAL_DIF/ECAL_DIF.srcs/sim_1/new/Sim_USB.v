`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/07 13:31:47
// Design Name: 
// Module Name: Sim_USB
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


module Sim_USB;
	reg Clk;
	reg Rst_N;
	reg Rd_En;
    reg Wr_En;


	localparam   [15:0] DATA_2_EXFIFO = 16'h55aa;
	wire [15:0] 	Fifo_Qout;
	wire			Fifo_Empty;
	 
 	initial begin
		Clk = 0;
		Rst_N = 0;
		Wr_En = 0;
		Rd_En = 0;
		#100;
		Rst_N = 1;
		#60;
		Wr_En = 1;

		#40
		Rd_En = 1;
	end


always @ (*) //50MHz 20ns
  begin
    #10
    Clk <= ~Clk;
  end   

 Ex_Fifo Ex_Fifo_Inst(
    // Inputs
    .din(DATA_2_EXFIFO),
    .clk(Clk),
    .rd_en(Rd_En),
    .rst(~Rst_N),
    .wr_en(Wr_En),
    // Outputs
    .empty(Fifo_Empty),
    .full(),
    .dout(Fifo_Qout)
  );

endmodule
