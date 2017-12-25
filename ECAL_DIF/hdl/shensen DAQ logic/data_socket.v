`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/14 11:16:41
// Design Name: 
// Module Name: data_socket
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



module data_socket(
		//general signal
		input rst_n,
		input soft_rst,
		
		//input 1
		input wr_clk1,
		input din1,
		input wr_en1,
		//output clear_flag,
		output empty1,

		//input 2
		input wr_clk2,
		input [7:0] din2,
		input wr_en2,

		//output
		input rd_clk,
		input rd_en,
		output empty,
		output rd_valid,
		output [15:0] dout
		
    );
		
		parameter DOUTSIZE = 16;
		// serial data transform to paralle data
		reg	[15:0] shift_reg;
		reg [4:0] count;

		// put din in MSB and shift towards to LSB
		// 0bit at MSB
		always @ (posedge wr_clk1 or negedge rst_n) begin
				if (!rst_n) begin
						shift_reg <= 16'b0;
				end

				else if (wr_en1)	begin
						shift_reg[15:1] <= shift_reg[14:0];
						shift_reg[0] <= din1;
				end
				
				else
						shift_reg <= 16'b0;
		end

		always @ (posedge wr_clk1 or negedge rst_n) begin
				if (!rst_n) begin
						count <= 4'b0;
			
				end
				else if(count == (DOUTSIZE - 1)) begin
						count <= 1'b0;
		
				end
				else if(wr_en1) begin
						count <= count + 4'b1;
	
				end

				else
						count <= 4'b0;

		end


		reg load1;
		always @ (posedge wr_clk1 or negedge rst_n) begin
				if ( !rst_n ) begin
						load1 <= 1'b0;
				end
				else if (count == (DOUTSIZE - 1)) begin
						load1 <= 1'b1;
				end
				else begin
						load1 <= 1'b0;
				end
		end

		//gray code to binary code transfer
		wire [11:0] binary_code;
		
		Gray_to_Binary #(.N(12)) decoder (
				.gray_code (shift_reg[11:0]),
				.binary_code (binary_code[11:0])
		);


		wire rd_en1;
		wire [15:0] dout1;
		wire empty1;
		wire wr_en1;
		wire full1;
		

		reg load_buf;
		reg [15:0] data_in_buf;
		always @ (posedge wr_clk1 or negedge rst_n) begin
				if ( !rst_n ) begin
						load_buf <= 1'b0;
						data_in_buf <= 16'h5aa5;
				end
				else begin
						load_buf <= load1;
						data_in_buf <= {shift_reg[15:12], binary_code[11:0]};
				end
		end


		// detect edge of wr_en1 and output after 3 period
		reg [3:0] wr_en1_delay;
		always @ (posedge wr_clk1) begin
				wr_en1_delay[0] <= wr_en1;
				wr_en1_delay[3:1] <= wr_en1_delay[2:0];
		end
		wire wr_en1_rise = ~wr_en1_delay[3] & wr_en1_delay[2];
		wire wr_en1_fall = wr_en1_delay[3] & ~wr_en1_delay[2];
			
		// multiplexier

		reg [15:0] data_1_reg;
		wire [15:0] data_1;
		always @ (wr_en1_rise or wr_en1_fall or data_in_buf) begin
				case({wr_en1_rise,wr_en1_fall})
						2'b00:	data_1_reg = data_in_buf;
						2'b10:	data_1_reg = 16'hfa5a;
						2'b01:	data_1_reg = 16'hfeee;
						2'b11:	data_1_reg = 16'hffff;
						default:	data_1_reg = 16'hffff;
				endcase
		end
		assign data_1 = data_1_reg;




		data_fifo data_fifo_inst (
				.wr_clk	(wr_clk1),
				.rd_clk	(rd_clk),
				.rst	(soft_rst),

				.din	(data_1),
				.wr_en	(load_buf || wr_en1_rise || wr_en1_fall),
				.full	(full1),
				
				.dout	(dout1[15:0]),
				.rd_en	(rd_en1),
				
				.valid	(rd_valid),
				.empty	(empty1)
		);
		

		//------------------------------------------------
		//input2
		wire rd_en2;
		wire empty2;
		wire [15:0] dout2;
		p8top16 input2buffer (
				.rst	(soft_rst),
				
				.wr_clk	(wr_clk2),
				.wr_en	(wr_en2),
				.din	(din2[7:0]),
				
				.rd_clk (rd_clk),
				.rd_en	(rd_en2),
				.empty	(empty2),

				.dout	(dout2)
		);

		//switch output
		assign rd_en1 = rd_en && ~empty1;	//high priority 
		assign rd_en2 = rd_en && (empty1 && ~empty2); //low priority
		assign empty = empty1 && empty2; //low active
		assign dout = (empty2) ? dout1 : dout2;


endmodule
