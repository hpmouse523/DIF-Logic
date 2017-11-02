`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/01 10:49:13
// Design Name: 
// Module Name: state_machine
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


module state_machine(
		input clk,
		input rst_n,
		input acquisition,	//from PC	
		input hv_config_en,
		input hv_config_rep_receive,
		input hv_config_done,

		input chipsat,			//p.e 
		input sc_req,
		input sc_done,
		input end_readout,
		output idle,
		//output busy,

		output acq,		//p.e.
		output conv,	//n.e.
		output read,	//p.e. 
		output sc,		//p.e.
		output hv_wr,
		output reg error	//p.e. 
    );
		
		parameter		IDLE = 5'b00000,
						ACQ = 5'b00001,
						CONV = 5'b00010,
						READ = 5'b00100,
						SC = 5'b01000,
						HV_CFG_WR = 5'b10000,
						HV_CFG_RD = 5'b11000;
		reg [4:0] state;
		//reg next_state[3:0];
		
		initial
		begin
				state <= IDLE;
		end
		
		//state transforming
		always@(posedge clk or negedge rst_n)
		begin
				if(!rst_n) begin
						state <= IDLE;
						error <= 1'b0;
				end

				else
						case(state)
								IDLE:	
										if(acquisition) 
												state <= ACQ;
										else if(sc_req)
												state <= SC;
										else if(hv_config_en)
												state <= HV_CFG_WR;
										else
												state <= IDLE;
								ACQ:
										// chip is full or stop early by PC 
										if(!acquisition && chipsat)
												state <= CONV;
										else
												state <= ACQ;
								CONV:
										if(!chipsat)
												state <= READ;
										else
												state <= CONV;
								READ:
										if(end_readout)
												state <= IDLE;
										else
												state <= READ;
								SC:
										if(sc_done)
												state <= IDLE;
										else
												state <= SC;

								HV_CFG_WR:
										if(hv_config_rep_receive)
												state <= HV_CFG_RD;
										else
												state <= HV_CFG_WR;
								HV_CFG_RD:
										if(hv_config_done)
												state <= IDLE;
										else
												state <= HV_CFG_RD;
								default:	begin
										state <= IDLE;
										error <= 1'b1;
								end		
						endcase
		end

		assign idle = (state == IDLE) ? 1'b1 : 1'b0;
		assign acq = (state == ACQ && acquisition) ? 1'b1 : 1'b0;
		assign conv = (state == CONV) ? 1'b0 : 1'b1;		//active low
		assign read = (state == READ) ? 1'b1 : 1'b0;
		assign sc = (state == SC) ? 1'b1 : 1'b0;
		assign hv_wr = (state == HV_CFG_WR) ? 1'b1 : 1'b0;

endmodule
