`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/11 18:20:31
// Design Name: 
// Module Name: rx_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		send 8 bit data in the protocal of uart.
//		1 start bit
//		8 data bit
//		1 even check bit
//		1 stop bit
//
//		clk must have higher freqency than baud_pulse
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx_module(
    input clk,
    input rst_n,
    input baud_pulse,
    input rx_valid,
    input rx_en,
    input [DATA_BIT_NUM - 1 :0] din,
    output dout,
    output idle
    );

		parameter	DATA_BIT_NUM = 8;

		//idle_reg
		reg idle_reg;
		always @ ( posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						idle_reg <= 1'b1;
				end

				else if (rx_en) begin
						idle_reg <= 1'b0;
				end

				else if (finish && ~rx_en_slow_sync) begin
						idle_reg <= 1'b1;
				end



		end
		assign	idle = idle_reg;
		//assign	idle = (state == STOP) || (state == IDLE);

		//data latch
		reg [DATA_BIT_NUM - 1 :0] data;
		always @ (posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						data <= 8'h00;
				end
				else if (rx_valid) begin
						data <= din;
				end
				else begin
						data <= data;
				end
		end

		reg [2:0] state;
		reg [2:0] next_state;
		reg [2:0] count;
		
		always @ (posedge clk) begin
				if (baud_pulse) begin
						state <= next_state;
				end
				else begin
						state <= state;
				end
		end

		//------------------------------------------------
		//rx_en_slow_sync
		//synchronize rx_en with baud clk as rx_en_slow_sync
		reg	rx_en_slow_sync;
		always @ (posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						rx_en_slow_sync <= 1'b0;
				end
				else if (rx_en) begin
						rx_en_slow_sync <= 1'b1;
				end
				else if (baud_pulse) begin
						rx_en_slow_sync <= 1'b0;
				end
				else begin
						rx_en_slow_sync <= rx_en_slow_sync;
				end
		end

		localparam	IDLE = 3'b000;
		localparam	START = 3'b001;
		localparam	DATA = 3'b011;
		localparam	CHECK = 3'b111;
		localparam	STOP = 3'b101;
		localparam	FINISH = 3'b100;

		
		wire check_bit = ^data;
		reg	rx_reg;
		always @ (*) begin
				case (state)
						IDLE:	begin
								if (rx_en_slow_sync) begin
										next_state <= START;
								end
								else begin
										next_state <= state;
								end
								rx_reg <= 1'b1;
						end
						START:	begin
								next_state <= DATA;
								rx_reg <= 1'b0;
						end
						DATA:	begin
								if (count == 3'b111) begin
										next_state <= CHECK;
								end
								else begin
										next_state <= state;
								end
								rx_reg <= data[count];
						end

						CHECK:	begin
								next_state <= STOP;
								rx_reg <= check_bit;
						end

						STOP: begin
								if(rx_en_slow_sync) begin
										next_state <= START;
								end
								else	begin
										next_state <= IDLE;
								end
								rx_reg <= 1'b1;
						end
						

						default: begin
								next_state <= IDLE;
								rx_reg <= 1'b1;
						end

				endcase
		end
		assign	dout = rx_reg;
		always @ (posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						count <= 3'b000;
				end

				else if ( state == DATA) begin
						if (baud_pulse == 1'b1) begin
								count <= count + 1;
						end
						else begin
								count <= count;
						end
				end

				else begin
						count <= 3'b000;
				end
		end

		wire finish = (state == STOP) ? 1'b1 : 1'b0;

		
		

endmodule
