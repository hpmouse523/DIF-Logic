`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/29 11:00:17
// Design Name: 
// Module Name: hv_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 		there are some parameter to config uart communication:
// 		1. baud_rate: if we have clk_rate @ 40M,  so we output a pulse every
// 		40*10^6/38400 = 1042 clk period.
//		
//		2. bit of data: how many bits represent data. In spiroc2b, the number
//		is 8.
//
//		3. LSB first in here is fixed
//		4. stop bit width is 1 fixed
//		
//		because cmd_module always read next cmd unless cmd_fifo is empty,
//		there is one fifo for buffering config data from cmd_fifo.
//
//		when this module is active, other module must be disable to free the
//		bus and fifo. so we need send hv_start cmd to enter hv_config
//		status, and hv module will send hv_end signal to exit hv_config status. In hv_config
//		status, the bus and fifo only use for hv configing.
//		
// Dependencies: 
//
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hv_control(
		input		clk,//clk = 40MHz
		input		rst_n,
		input		soft_rst,
		input		tx,
		input		rx_en,
		input		[7:0] din,
		output		rx,
		output		[7:0] dout,
		output		valid,
		output		idle
);
		
		parameter BAUD_RATE = 38400;
		parameter DATA_BIT_NUM = 8;
		parameter CLK_RATE = 40000000;
		parameter DIV_RATE = CLK_RATE/BAUD_RATE + 1;
		
		//baud_clk is a pulse signal, whose pulse width is one period of
		wire	baud_clk;		
		//clk_in
		clk_divider #(.DIV_RATE (DIV_RATE)) uart_clk_gen(
				.clk_in				(clk),
				.rst_n			(rst_n),
				.clk_out		(baud_clk)
		);
		wire rd_en;
		wire [DATA_BIT_NUM - 1:0] buffer;
		
	fifo_generator_0 hv_fifo (
          .clk(clk),      // input wire clk
          .rst(~soft_rst),      // input wire rst
          .din(din),      // input wire [7 : 0] din
          .wr_en(rx_en),  // input wire wr_en
          .rd_en(rd_en),  // input wire rd_en
          .dout(buffer),    // output wire [7 : 0] dout
          .full(full),    // output wire full
          .empty(empty),  // output wire empty
          .valid(rx_valid)
        );


		/*fifo_generator_0 hv_fifo (
				//input
				.clk	(clk),
				.rst	(soft_rst),
				.din	(din),	//din[7:0]
				.wr_en	(rx_en),
				.rd_en	(rd_en),

				//output
				.dout	(buffer),	//dout[7:0]
				.full	(full),
				.empty	(empty),
				.valid	(rx_valid)
		);*/
		//assign rd_en = 1;
		assign rd_en = idle && ~empty;
		wire rx_temp;
		rx_module #(.DATA_BIT_NUM (DATA_BIT_NUM)) rx_sender(
				//input
				.clk		(clk),
				.rst_n		(rst_n),
				.baud_pulse		(baud_clk),
				.rx_en		(rd_en),
				.rx_valid		(rx_valid),		//connect to hv_config_en port of cmd module
				.din		(buffer[DATA_BIT_NUM - 1:0]),

				//output
				.dout		(rx_temp),
				.idle		(idle)
		);
		assign rx = rx_temp ? 1'bz : 1'b0;
		tx_module #(.DATA_BIT_NUM (DATA_BIT_NUM)) tx_receiver(
				//input
				.clk		(clk),
				.rst_n		(rst_n),
				.din		(tx),

				//output
				.dout		(dout[DATA_BIT_NUM - 1:0]),
				.valid		(valid)
		);

		wire tx_stx;
		wire tx_cr;
		wire rx_stx;
		wire rx_cr;
		wire err;
		assign tx_stx = (buffer == 8'h02) ? 1'b1 : 1'b0;
		assign tx_cr = (buffer == 8'h0d) ? 1'b1 : 1'b0;
		assign rx_stx = (dout == 8'h02) ? 1'b1 : 1'b0;
		assign rx_cr = (dout == 8'h0d) ? 1'b1 : 1'b0;

		reg [3:0] state;
		reg [3:0] next_state;
		parameter 		DISABLE = 4'b0000,
						TX = 4'b0001,
						WAIT_RX = 4'b0010,
						RX = 4'b0100,
						ERR = 4'b1000;

		always @ (posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						state <= DISABLE;
				end
				else begin
						state <= next_state;
				end
		end

		always @ (*) begin
				case(state)
						DISABLE:
								if (tx_stx) begin
										next_state <= TX;
								end
								else begin
										next_state <= state;
								end

						TX:
								if (err) begin
										next_state <= ERR;
								end
								else if (tx_cr) begin
										next_state <= WAIT_RX;
								end
								else begin
										next_state <= state;
								end
								
						WAIT_RX:
								if (rx_stx) begin
										next_state <= RX;
								end
								else begin
										next_state <= state;
								end

						RX:
								if (err) begin
										next_state <= ERR;
								end
								else if (rx_cr) begin
										next_state <= DISABLE;
								end
								else begin
										next_state <= state;
								end
								
						ERR:
								next_state <= state;

						default: begin
								next_state <= DISABLE;
						end
				
				endcase
		end




		 

endmodule
