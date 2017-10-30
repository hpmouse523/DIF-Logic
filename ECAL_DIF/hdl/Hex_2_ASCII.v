`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 17:15:55
// Design Name: 
// Module Name: Hex_2_ASCII
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


module Hex_2_ASCII(
    input [4:1] In_Hex,
    output [8:1] Out_ASCII
    );

	assign Out_ASCII = (In_Hex > 4'd9 ) ? In_Hex + 8'h37 : In_Hex + 8'h30;
endmodule
