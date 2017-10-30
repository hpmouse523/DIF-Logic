`timescale 1ns/1ps

module	hv_control_tb;
		
		reg	clk;
		reg	rst_n;
		reg	tx;
		reg	[7:0] din;
		reg	rx_en;

		wire	rx;
		wire	[7:0] dout;
		wire	valid;
		wire	idle;

		wire soft_rst;
		hv_control	DUT (
				//input
				.clk	(clk),
				.rst_n	(rst_n),
				.soft_rst	(soft_rst),
				.tx		(tx),
				.din	(din),
				.rx_en	(rx_en),
				//output
				.rx		(rx),
				.dout	(dout),
				.valid	(valid),
				.idle	(idle)
		);
		

		soft_rst	rst_delay	(
				.clk	(clk),
				.rst_n	(rst_n),
				.soft_rst	(soft_rst)
		);

		// variable initial
		initial begin
				clk = 1'b0;
				rst_n = 1'b1;
				tx = 1'b1;
				din = 8'h00;
				rx_en = 1'b0;
		end

		//clock
		always #12.5 clk = ~clk;
		
		//------------------------------------------------
		//stimulus here
		reg temp;
		initial begin
				//reset
				#3
				rst_n = 1'b0;
				tic(8);
				rst_n = 1'b1;

				wait(soft_rst);
				wait(!soft_rst);
				
				
				
				#20000 rx_send(8'h02);
				rx_send(8'ha5);
				rx_send(8'h5a);
				rx_send(8'h03);
				rx_send(8'hff);
				rx_send(8'h0d);
		end


		//------------------------------------------------
		//task defination
		task tic;
				input [3:0] clk_count;
				begin
						repeat (clk_count)	begin
								#25;
						end
				end
		endtask

		task rx_send;
				input	[7:0] rx_data;
				begin
						din <= rx_data;
						rx_en <= 1'b1;
						tic(1);
						rx_en <= 1'b0;
				end
		endtask

endmodule





