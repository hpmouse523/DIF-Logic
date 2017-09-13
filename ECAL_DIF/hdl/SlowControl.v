`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/14 11:24:52
// Design Name: 
// Module Name: SlowControl
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

module SlowControl(
		// input
		input	clk,	//clock
		input	rst_n,	//reset
		input	soft_rst,
		
		input	sc_start,
		input	wr_en,
		input	[7:0]	sc_data,
		input	sc_data_back,

		output	reg	sc_done,
		output	sc_dout,
		output  sc_clk,
		output	sc_rstb,
		output	reg	sc_load

    );
		
		parameter	data_length = 929;
		wire	empty;
		wire	full;

		//------------------------------------------------
		//generate a 1M Hz clk for sc_clk
		reg	clk1M_reg;
		wire clk1M;
		reg [4:0] count1;
		wire twenty;
		always @(posedge clk or negedge rst_n) begin
				if(!rst_n) begin
						count1 <= 5'b0;
				end
				else if (count1 == 19) begin
						count1 <= 5'b0;
				end
				else begin
						count1 <= count1 + 5'b1;
				end
		end
		assign twenty = (count1 == 19) ? 1'b1 : 1'b0;
		always @(posedge clk or negedge rst_n) begin
				if (!rst_n) begin
						clk1M_reg <= 1'b0;
				end
				else if (twenty) begin
						clk1M_reg <= ~clk1M_reg;
				end
				else begin
						clk1M_reg <= clk1M_reg;
				end
		end
		assign clk1M = clk1M_reg;

		//------------------------------------------------
		//fifo   8bits to 1bit	MSB first
		wire rd_en;
		wire dout;
		wire valid;
		//wire fifo_rst;
		//assign fifo_rst = soft_rst;
		p8tos	p2s	(
				.wr_clk	(clk),
				.rd_clk	(clk1M),
				.rst	(soft_rst),
				
				.wr_en	(wr_en),
				.din	(sc_data[7:0]),
				.rd_en	(rd_en),
				.valid	(valid),
				.dout	(dout),
				.empty	(empty),
				.full	(full)
		);
		
		reg sc_dout_sync;
		always @ (negedge clk1M) begin
				sc_dout_sync <= dout;
		end
		assign sc_dout = sc_dout_sync;
     	//------------------------------------------------
		//rd_en
		/*
		always @ ( posedge clk1M or negedge rst_n)	begin
				if(!rst_n) begin
						rd_en <= 1'b0;
				end

				else if (sc_start && !almost_empty && !finish)	begin
						rd_en <= 1'b1;
				end

				else
						rd_en <= 1'b0;
		end
		*/
		assign rd_en = ~empty && sc_start ;
		//------------------------------------------------
		//clk gating 
		assign sc_rstb = ~soft_rst;	// attention ! this is low active
		reg clk_gate;

		always @ ( negedge clk1M ) begin	//! attention of using negedge clk
				if ( !finish ) begin
						clk_gate <= valid;
				end
				else	begin
						clk_gate <= 1'b0;
				end
		end

		BUFGCE BUFGCE_inst (
				.O	(sc_clk),
				.CE	(clk_gate),
				.I	(clk1M)
		);
		//assign sc_clk = clk1M && clk_gate;


		// fall edge to generate finish flag
		reg finish;
		reg [9:0]	bit_count;
		always @ ( negedge clk1M or negedge rst_n)	begin
				if (!rst_n) begin
						finish <= 1'b0;
				end
				else if (sc_start == 1'b0)
						finish <= 1'b0;

				else if (bit_count == data_length) begin
						finish <= 1'b1;
				end

				else
						finish <= finish;
		end

		//------------bit_count-----------
		always @(posedge clk1M or negedge rst_n)
		begin
				if (!rst_n) begin
						bit_count <= 10'b0;	
				end

				else if (rd_en) begin
						bit_count <= bit_count + 10'b1;
				end
				else if (!sc_start) begin
						bit_count <= 10'b0;
				end
				else begin
						bit_count <= bit_count;
				end
		end
		

		//------------------------------------------------
		//delay finish and generate load signal
		wire finish_delay;
		
		D delay_cell (
				.clk	(clk1M),
				.in		(finish),
				.out	(finish_delay)
		);
		//-----------sc_load-----------
		reg [1:0]	buf1;
		always @ ( posedge clk1M)
		begin
				buf1[0] <= (!finish_delay) && finish;
				buf1[1] <= buf1[0];
				sc_load <= buf1[1];
		end


		//-----------sc_done-----------
		always @ ( posedge clk1M or negedge rst_n)
		begin
				if (!rst_n) begin
						sc_done <= 1'b0;
				end
				else if (sc_start == 1'b0)
						sc_done <= 1'b0;

				else if (sc_load == 1'b1)
						sc_done <= 1'b1;
				else
						sc_done <= sc_done;
		end


endmodule
