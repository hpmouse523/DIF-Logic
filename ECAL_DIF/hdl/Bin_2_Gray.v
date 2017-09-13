`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:17 04/05/2017 
// Design Name: 
// Module Name:    Bin_2_Gray 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Bin_2_Gray(
    input [7:0] In_Bin,
    output [7:0] Out_Gray
    );
localparam    [4:0] SIZE  = 5'd8; //Name Size of width 8 means 8bit
reg [SIZE - 1:0]  Sig_Gray;
integer i;

always @ (*)
  begin
    Sig_Gray[SIZE - 1]  = In_Bin[SIZE - 1];
    for(i = 0 ; i<SIZE  - 1; i = i +1)
      begin
        Sig_Gray[SIZE - 2 - i]  = In_Bin[SIZE - 1 - i] ^In_Bin[SIZE - 2 -i];
      end   
  end   


  assign    Out_Gray  = Sig_Gray;

endmodule
