`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:23:48 04/05/2017 
// Design Name: 
// Module Name:    Gray_2_Bin 
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
module Gray_2_Bin(
    input [11:0] In_Gray,
    output [11:0] Out_Bin
    );

localparam  [4:0]   SIZE  = 5'd12;
reg     [SIZE - 1:0]  Sig_Bin;
integer   i;

always @(*)
begin
      Sig_Bin[SIZE-1]     = In_Gray[SIZE-1];
      for(i=0;i < SIZE-1; i = i + 1)
      begin
        Sig_Bin[SIZE - 2 -i]  = Sig_Bin[SIZE - 1 - i ] ^ In_Gray[SIZE - 2 -i];
      end   

end 
assign    Out_Bin   = Sig_Bin;


endmodule
