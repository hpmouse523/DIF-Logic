`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:54:36 03/08/2017 
// Design Name: 
// Module Name:    Test_Just 
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
module Test_Just(
    input Clk,
    input Rst_N,
    input Din,
	 input [3:0] In1,
    output reg Dout,
	 output reg [3:0] Do1
    );

always @ (posedge Clk or negedge Rst_N)
begin
if(~Rst_N)
Dout  <=	0;
else
Dout 	<=	Din;
end		

always @ (In1)
begin
Do1 = 0;
case(In1)
1:Do1 = 1;
2:Do1 = 2;
endcase

end		


endmodule
