`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/29 11:00:17
// Design Name: 
// Module Name: clk_divider 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 		there are one parameter to config clk_divider:
//				1. divider rate: if divider rate is 2, then (freq of
		//				clk_in)/(freq of clk_out) is 2.
		//				divider rate must larger than 1.
// Dependencies: 
//
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_divider(
				input   clk_in,
				input		rst_n,
				output		clk_out
    );
		
    		parameter DIV_RATE = 1;
		
		reg [19:0] counter;
		always @( posedge clk_in or negedge rst_n) begin
				if ( !rst_n ) begin
						counter <= DIV_RATE/2;
				end
				else if (counter == DIV_RATE - 1) begin
						counter <= 0;
				end
				else begin
						counter = counter + 1;
				end
		end
//
//		reg clk_out_reg;
//		always @( posedge clk) begin
//				if (counter == DIV_RATE - 1) begin
//						clk_out_reg <= ~clk_out_reg;
//				end
//				else begin
//						clk_out_reg <= clk_out_reg;
//				end
//		end

		assign clk_out = (counter == 0) ? 1'b1 : 1'b0; 

endmodule
