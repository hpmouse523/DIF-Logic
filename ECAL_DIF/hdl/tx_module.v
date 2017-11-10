`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/11 20:41:20
// Design Name: 
// Module Name: tx_module
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


module tx_module(
    input clk,
    input rst_n,
    input din,
    output [DATA_BIT_NUM - 1:0] dout,
    output valid
    );

		parameter DATA_BIT_NUM = 8;


		//------------------------------------------------
		//asyn start baud_clk
		//clk is 40M hz, baud freq is 38400 bit/s
		wire START_flag = (state == IDLE && din == 1'b0) ? 1'b1 : 1'b0 ;

		topulsesignal #(.size (1)) start_detect (
				.clk	(clk),
				.rst_n	(rst_n),
				.din	(START_flag),
				.dout	(START_detected_pulse)
		);
		
		clk_divider #(.DIV_RATE (40000000/38400)) tx_clk_gen (
				.clk_in		(clk),
				.rst_n		(!START_detected_pulse),
				.clk_out	(baud_pulse)
		);


		//------------------------------------------------
		// state machine
		// idle --> start --> bit0 --> .... --> bit7 --> check --> stop --> valid --> idle
		//                                                    L-- error  --> idle
		
		reg [2:0] state;
		reg [2:0] next_state;
		reg [2:0] count;
		reg bit_buffer;
		always @ (posedge clk or negedge rst_n) begin
				if ( !rst_n ) begin
						state <= IDLE;
						bit_buffer <= 1'b0;
				end

				else if (baud_pulse) begin
						state <= next_state;
						bit_buffer <= din;
				end
				else begin
						state <= state;
						bit_buffer <= bit_buffer;
				end
		end
		
		//------------------------------------------------
		//counter
		always @ (posedge clk or negedge rst_n ) begin
				if ( !rst_n ) begin
						count <= 0;
				end
				else if (state == DATA) begin
						if (baud_pulse) begin
								count <= count + 1;
						end
						else begin
								count <= count;
						end
				end
				else begin 
						count <= 0;
				end
		end

		localparam	IDLE = 3'b000;
		localparam	START = 3'b001;
		localparam	DATA = 3'b011;
		localparam	CHECK = 3'b111;
		localparam	STOP = 3'b101;
		localparam	VALID = 3'b100;
		localparam  ERR = 3'b110;

		wire check_bit = ^dout;
		reg	[7:0]	dout_reg;
		assign	dout = dout_reg;
		wire	err = ( check_bit == bit_buffer ) ? 1'b1 : 1'b0 ;	//may be cost electricity a lot
		always @ (*) begin
				case (state)
						IDLE: begin
								if (din == 1'b0) begin
										next_state <= START;
								end
								else begin
										next_state <= IDLE;
								end
						end

						START: begin
								next_state <= DATA;
						end

						DATA:	begin
								if(count == DATA_BIT_NUM - 1 ) begin
										next_state <= CHECK;
								end
								else begin
										next_state <= DATA;
								end
								dout_reg[count] <= bit_buffer;
						end

						CHECK:	begin
								if (err == 0) begin
										next_state <= ERR;
								end
								else begin
										next_state <= STOP;
								end
						end

						STOP:	begin
								next_state <= VALID;
						end

						VALID:	begin
								next_state <= IDLE;
						end

						default: begin
								next_state <= IDLE;
								dout_reg   <= 8'd0;
						end
				endcase
		end
		
		//------------------------------------------------
		//valid signal output
		reg	valid_reg;
		always @ ( posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						valid_reg <= 1'b0;
				end

				else if ( state == VALID && baud_pulse == 1'b1) begin
						valid_reg <= 1'b1;
				end

				else	begin
						valid_reg <= 1'b0;
				end
		end
		assign valid = valid_reg;
endmodule
