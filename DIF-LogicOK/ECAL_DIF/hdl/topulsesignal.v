`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/01 10:08:49
// Design Name: 
// Module Name: topulsesignal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  check posedge of signal and generate a pulse according the time of posedge
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//parameter pulse_length = 1;

module topulsesignal(
    input [size-1:0] din,
    output [size-1:0] dout,
    input clk,
    input rst_n
    );
		parameter size = 8;
		reg [size-1:0] din_delay [1:0];
		always @ (posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						din_delay[0] <= 8'h0;
						din_delay[1] <= 8'h0;
				end
				else begin
						din_delay[0] <= din;
						din_delay[1] <= din_delay[0];
				end
		end

		assign dout = din & ~din_delay[1];
		
endmodule
