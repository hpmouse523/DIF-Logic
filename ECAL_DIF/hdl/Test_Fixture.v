`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:32:01 02/24/2017
// Design Name:   Sci_Acq
// Module Name:   D:/Work_File/CEPC/Logic/SKIROC/hdl/Test_Fixture.v
// Project Name:  SKIROC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Sci_Acq
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Test_Fixture;

	// Inputs
	reg Clk;
	reg Rst_N;
	reg In_Start_Work;
	reg In_Chipsatb;
	reg In_End_Readout;

	// Outputs
	wire Out_Acqing;
	wire Out_Start_Acq;
	wire Out_Start_Convb;
	wire Out_Start_Readout;
	wire Out_Resetb_ASIC;

	// Instantiate the Unit Under Test (UUT)
	Sci_Acq uut (
		.Clk(Clk), 
		.Rst_N(Rst_N), 
		.In_Start_Work(In_Start_Work), 
		.Out_Acqing(Out_Acqing), 
		.In_Chipsatb(In_Chipsatb), 
		.In_End_Readout(In_End_Readout), 
		.Out_Start_Acq(Out_Start_Acq), 
		.Out_Start_Convb(Out_Start_Convb), 
		.Out_Start_Readout(Out_Start_Readout), 
		.Out_Resetb_ASIC(Out_Resetb_ASIC)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Rst_N = 0;
		In_Start_Work = 0;
		In_Chipsatb = 0;
		In_End_Readout = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
    Rst_N = 1'b1;
    #100
    In_Start_Work  = 1'b1;
    In_Chipsatb    = 1'b1;
	end
  always @ (*)
    begin
      #10
      Clk <= ~Clk;   //Define 50MHz Clk
    end   




endmodule

