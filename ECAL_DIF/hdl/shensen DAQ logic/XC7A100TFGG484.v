// Verilog created by ORCAD Capture

module XC7A100TFGG484 
 ( 
		SR_LOAD, 
		SR_OUT, 
		SR_IN, 
		SR_CK, 
		SR_RSTB, 
		SELECT, 
		END_READOUT2, 
		END_READOUT1, 
		START_READOUT2, 
		START_READOUT1, 
		START_CONVB, 
		CHIPSATB, 
		TRANSMIT_ON2B, 
		TRANSMIT_ON1B, 
		DOUT2B, 
		DOUT1B, 
		RESETB, 
		HOLDB_ALT, 
		HOLDB_CONN, 
		RESETB_PA, 
		OR36, 
		FLAG_TDC_EXT, 
		START_RAMPB_ADC_EXT, 
		CY_FD, 
		CY_IFCLK, 
		CY_SLRD, 
		FIFOADR0, 
		CY_PKTEND, 
		CY_SLCSN, 
		CY_SLOE, 
		FPGA_GLOBAL_CLK, 
		FPGA_RESET, 
		CY_WAKEUP, 
		CY_WU2, 
		FIFOADR1, 
		STARTACQ, 
		PWR_ON_D, 
		PWR_ON_A, 
		PWR_ON_ADC, 
		PWR_ON_DAC, 
		TRIG_EXT_P, 
		TRIG_EXT_N, 
		DIGITAL_PROBE1, 
		DIGITAL_PROBE2, 
		SRIN_READ, 
		CLK_READ, 
		RESETB_READ, 
		SROUT_READ, 
		RESETB_DELAY, 
		CY_FLAGA, 
		CY_FLAGB_FULL, 
		CY_FLAGC_EMPTY, 
		CY_SLWR, 
		PLL_OUT, 
		TEST1, 
		TEST2, 
		TEST3, 
		TEST4, 
		TEST5, 
		TEST6, 
		LED, 
		AVDD_PROBE, 
		AVDD_SLOWCONTROL, 
		TEST_SMA2, 
		TEST_SMA1, 
		CLK_40M_P ,	//named 40M_P in fpga 
		CLK_40M_N ,	//named 40M_N in fpga
		CLK_5M_P ,	//named 5M_P in fpga
		CLK_5M_N ,	//named 5M_N in fpga
		R_C_P, 
		R_C_N, 
		V_E_P, 
		V_E_N, 
		ADC_DOUT, 
		ADC_CNV, 
		ADC_DIN, 
		ADC_CLK, 
		ADC_TURBO, 
		PDREF, 
		D1, 
		D2 );
		
		//-------------------------------------------FPGA config---------------------------------------
		input	FPGA_GLOBAL_CLK;
		input	FPGA_RESET;

		//-------------------------------------------Connect to ASIC(SPIROC2b)--------------------------------------

		//CLOCK Val_Evt & Raz_chn & trig_ext
		output	CLK_40M_P;
		output	CLK_40M_N;
		output	CLK_5M_P;
		output	CLK_5M_N;

		output	V_E_P;	//--
		output	V_E_N;	//--
		
		output	R_C_P;	//--
		output	R_C_N;	//--

		output	TRIG_EXT_P;	//--
		output	TRIG_EXT_N;	//--

		//RESET
		output RESETB_PA;	//--reset preamp
		output RESETB_DELAY;	//--reset delay cell
		//STATE Control
		output	RESETB;	//reset digital part
		output	STARTACQ;
		output	START_CONVB;
		output	START_READOUT1;
		output	START_READOUT2;	//--
		
		input	TRANSMIT_ON1B;	//--
		input	TRANSMIT_ON2B;	//--
		input	END_READOUT1;
		input	END_READOUT2;	//--
		input	CHIPSATB;

		//DATA PORT
		input	DOUT1B;	//--
		input	DOUT2B;	//--

		//POWER MANAGER
		output	PWR_ON_A;	//--
		output	PWR_ON_D;	//--	
		output	PWR_ON_ADC;	//--
		output	PWR_ON_DAC;	//--

		//SLOW CONTROL
		output	SELECT;
		output	SR_LOAD;
		output	SR_IN;
		output	SR_CK;
		output	SR_RSTB;
		input	SR_OUT;

		//READ FUNCTION
		output	RESETB_READ;	//--reset read function register 
		output	SRIN_READ;	//--
		output	CLK_READ;	//--	
		input	SROUT_READ;	//--
		
		//AUXILIARY SIGNAL
		input	DIGITAL_PROBE1;	//--
		input	DIGITAL_PROBE2;	//--
		input	OR36;	//--
		output	FLAG_TDC_EXT;	//--
		output	START_RAMPB_ADC_EXT;	//--
		input	HOLDB_CONN;	//--input from outside
		output	HOLDB_ALT;	//--output to jumper then to spiroc2b
		
		//	-----------------USB-------------------------

		output	CY_IFCLK;	//InterFace CLK
		inout	[15:0]	CY_FD;
		output	CY_WAKEUP;
		output	CY_WU2;
		output	CY_SLOE;	//enable with programmable polarity for the slave FIFOs connected to FD[7..0] or FD[15..0]
		output	CY_SLWR;
		output	CY_SLRD;
		output	CY_SLCSN;
		output	FIFOADR0;
		output	FIFOADR1;
		output	CY_PKTEND;

		input	CY_FLAGA;
		input	CY_FLAGB_FULL;
		input	CY_FLAGC_EMPTY;



		//	-----------------TEST------------------------
		output	PLL_OUT;	//--
		output	TEST1;	//--
		output	TEST2;	//--
		output	TEST3;	//--
		output	TEST4;	//--
		output	TEST5;	//--
		output	TEST6;	//--
		output	[5:0] LED;	//--
		
		input	TEST_SMA1;	//--
		output	TEST_SMA2;	//--

		//--------------------ADC--------------------------
		input	ADC_DOUT;	//--
		output	ADC_DIN;	//--
		output	ADC_CNV;	//--
		output	ADC_CLK;	//--
		output	PDREF;	// --when low, internal ref is enabled;
		output	ADC_TURBO;//--high, no power down between conversion


		//-----------------HV CONTROL----------------------
		output	D1;	//RX data port with HV module
		input	D2;	//TX data port with HV module

		output	AVDD_PROBE;	//--
		output	AVDD_SLOWCONTROL;	//--


		assign PWR_ON_A = 1'b1;
		assign PWR_ON_D = 1'b1;
		assign PWR_ON_ADC = 1'b1;
		assign PWR_ON_DAC = 1'b1;

		//assign HOLDB_ALT = 1'b1;
		//assign FLAG_TDC_EXT = 1'b1;
		//assign RESETB_PA = 1'b1;
		//assign SRIN_READ = 1'b0;
		//assign CLK_READ = 1'b0;
		//assign SROUT_READ = 1'b0;

		wire	clk;
		wire	clk5M;
		wire	locked;	//not used
		wire	flagd;	//not used 
		wire	[15:0]	txf_data;
		wire	txf_empty;
		//wire	txf_full;
		wire	txf_rden;
		wire	[15:0]	rx_cmd;
		wire	[7:0]	cfig_data;
		wire	rxf_sync_out;
		wire	[1:0]	cy_fifoadr;
		(*mark_debug = "true"*)wire OR36;

		assign	FIFOADR0	=	cy_fifoadr[0];
		assign	FIFOADR1	=	cy_fifoadr[1];

		wire	rst_delay;	//for fifo reset
		wire	rst_spiroc;
		soft_rst	rst_delay_inst	(
				.clk		(clk),
				.rst_n		(FPGA_RESET),
				.rst_req	(rst_spiroc),
				.soft_rst	(rst_delay)
		);

		clk_wiz_0	clk_divider	(
				.resetn		(FPGA_RESET),
				.clk_in1	(FPGA_GLOBAL_CLK),	//40M
				.clk_out1	(clk),	//40M
				.clk_out2	(CY_IFCLK),
				.clk_out3	(clk10M),
				.clk_out4	(clk5M),
				.locked		(locked)
		);
		
		wire	v_e;
		wire	r_c;
		OBUFDS	clk_40M_ds	(
				.O	(CLK_40M_P),
				.OB	(CLK_40M_N),
				.I	(clk)
		);
		OBUFDS	clk_5M_ds	(
				.O	(CLK_5M_P),
				.OB	(CLK_5M_N),
				.I	(clk5M)
		);
		OBUFDS	valid_enable_ds	(
				.O	(V_E_P),
				.OB	(V_E_N),
				.I	(v_e)
		);
		OBUFDS	erase_ds	(
				.O	(R_C_P),
				.OB	(R_C_N),
				.I	(r_c)
		);

		// trig ext is routed wrongly
		assign TRIG_EXT_N = ~TRIG_EXT_P;
		//assign v_e = 1'b1;
		//assign r_c = 1'b1;
		//assign TRIG_EXT_P = 1'b0;


		wire txf_valid;
		wire [7:0] txf_data_1;
		wire [7:0] txf_data_2;
		assign txf_data_1 = txf_data[7:0];
		assign txf_data_2= txf_data[15:8];

		assign CY_SLCSN = 1'b0;
		Cy_Driver_new	cy_driver_0	(

				.usb_ifclk		(CY_IFCLK),
				.rstn           (FPGA_RESET),

				//interface to CY68013 outside
				.cy_flaga		(CY_FLAGA),
				.cy_flagb		(CY_FLAGB_FULL),
				.cy_flagc		(CY_FLAGC_EMPTY),
				.cy_flagd		(1'b1),  //FLAGD not used
				
				.cy_sloe		(CY_SLOE),
				.cy_slrd		(CY_SLRD),
				.cy_slwr		(CY_SLWR),
				.cy_pktend		(CY_PKTEND),

				.cy_wakeup		(CY_WAKEUP),
				.cy_wakeup2		(CY_WU2),

				.cy_fifoaddr	(cy_fifoadr[1:0]),
				.cy_data		(CY_FD[15:0]),


				// interface to tx_fifo in fpga

				.usb_fifo_in_data	({txf_data_1,txf_data_2}),
				.usb_fifo_in_empty	(txf_empty),
				.usb_fifo_in_rd_en	(txf_rden),
				.usb_fifo_in_valid	(txf_valid),

				// interface to rx_fifo for cmd in fpga
		
				.usb_cmd_wr_en	(rxf_sync_out),
				.usb_cmd_data	(rx_cmd[15:0])

		);
		wire	cmd_valid;
		wire	hv_config_en;
		wire	state_idle;
		wire	hv_config_end;
		wire	sc_start;
		wire	[1:0] avdd_select;
		wire	read_en;
		wire	self_trigger_en;
		command	command_0	(	/*vlog_aide:auto_inst command.v*/
				/*vlog_aide:auto_inst begin*/
				/*vlog_aide:auto_inst input ports*/
				.cmd_data_in    (rx_cmd[15:0]),
				.cmd_en         (rxf_sync_out),
				.rd_clk         (clk),
				.wr_clk			(CY_IFCLK),
				.rst_n          (FPGA_RESET),
				.soft_rst		(rst_delay),
				.idle			(state_idle),
				/*vlog_aide:auto_inst output ports*/
				.select			(SELECT),
				.start_en       (start_en),
				.rd_valid		(cmd_valid),		// temproray not used
				.cfig_data      (cfig_data[7:0]),
				.cfg_data_valid	(cfg_data_valid),
				.end_en         (end_en),
				.sc_start       (sc_start),
				.rd_en          (rd_en),
				.hv_config_en	(hv_config_en),
				.hv_config_end	(hv_config_done),
				.read_en		(read_en),
				.rst_spiroc		(rst_spiroc),
				.data_socket2_en	(data_socket2_en),
				.avdd_select	(avdd_select),
				.t_e			(self_trigger_en),
				.v_e			(v_e),
				.r_c			(r_c)
				/*vlog_aide:auto_inst end*/
		);
		/*
		auto_trigger #(.divider_rate(256)) auto_trigger_inst (
				//input
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.enable	(self_trigger_en),
				//output
				.out	(TRIG_EXT_P)
		);
		*/

		assign TRIG_EXT_P = self_trigger_en && TEST_SMA1;
		//assign TRIG_EXT_P = TEST_SMA1;
		//AVDD adjustable;
		//assign AVDD_PROBE = avdd_select[0];
		//assign AVDD_SLOWCONTROL = avdd_select[1];
		//AVDD is fixed to 3V3
		assign AVDD_PROBE = 1'b0;
		assign AVDD_SLOWCONTROL = 1'b0;
		
		assign HOLDB_ALT = 1'b1;
		assign FLAG_TDC_EXT = avdd_select[0];

		assign TEST1 = cy_fifoadr[0];
		assign TEST2 = CY_IFCLK;
		assign TEST3 = CY_SLWR;
		assign TEST4 = CY_PKTEND;
		assign TEST5 = CY_FLAGB_FULL;

		//------------------------------------------------
		//control reset of spiroc
		spiroc_reset spiroc_rst_control (
				//input
				.fast_clk (clk),
				.slow_clk (clk5M),
				.rst_n	(FPGA_RESET),
				.rst_spiroc (rst_spiroc),

				//output
				.resetb_read (RESETB_READ),
				.resetb	(RESETB),
				.resetb_pa	(RESETB_PA),
				.resetb_delay	(RESETB_DELAY)
		);


		//--------------auto_mod inst----------------//
		wire	socket_full1;
		wire	clear_flag;
		
		auto_mod auto_mod_inst	(
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.auto_start	(start_en),
				.auto_end	(end_en),
				.idle	(state_idle),	//come from state machine
				.chipsat	(~CHIPSATB),
				.acquisition	(acq_inter)
		);

		wire	[15:0]	data;
		wire	[7:0]	uart_tx;
		wire	uart_valid;
		wire	socket_wr_en1 = ~TRANSMIT_ON1B;


	/*	
		data_gen test_data_gen_inst (
				// data clock domain
				.control_clk (clk),
				.data_clk (clk5M),
				.start (start_en), //40M pulse
				.stop (end_en), //40M pulse
				.rst_n (FPGA_RESET),

				.dout(test_data),
				.valid(test_valid)
		);
*/
		

		data_socket	data_socket_inst	(
				//general signal
				.rst_n	(FPGA_RESET),
				.soft_rst	(rst_delay),
				
				//input 1
				.wr_clk1	(clk5M),
				.wr_en1 (socket_wr_en1),

				//.clear_flag	(clear_flag),
				
				.din1	(~DOUT1B),		//DOUT is low active
				.empty1	(socket_empty1),

				//input 2
				.wr_clk2	(clk),
				.wr_en2	(data_socket2_en),
				.din2	(cfig_data[7:0]),

				//read
				.rd_clk	(CY_IFCLK),	//input
				.rd_en	(txf_rden),
				.empty	(txf_empty),
				.rd_valid (txf_valid),
				.dout	(txf_data[15:0])
		);
		/*
		data_fifo	data_fifo0	(
				.wr_clk	(clk),
				.rd_clk	(CY_IFCLK),
				.rst	(rst_delay),
				.din	(data[15:0]),
				.wr_en	(up_wren),
				.rd_en	(up_rden),
				.dout	(up_data[15:0]),
				.full	(up_fifo_full),
				.empty	(up_fifo_empty)
		);
		*/
		state_machine	state_machine_0 (
				//input
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.acquisition	(acq_inter),
				.chipsat(~CHIPSATB),
				.sc_req(sc_start),
				.sc_done(sc_done),
				.hv_config_en	(hv_config_en),
				.hv_config_done	(hv_config_done),
				.end_readout(END_READOUT1),

				//output
				.idle(state_idle),
				.acq(STARTACQ),			//active high
				.conv(START_CONVB),	//active low
				.read(START_READOUT1),	//active high
				.sc(sc),		//active high
				.hv_config(hv),
				.error(state_machine_error)
		);

		wire sc_data_valid = cfg_data_valid & sc;
		SlowControl	sc_controler (

				//input
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.wr_en	(sc_data_valid),
				.sc	(sc),
				.sc_data	(cfig_data[7:0]),
				.sc_data_back	(SR_OUT),
				.soft_rst	(rst_delay),
				.select		(SELECT),
				//output
				.sc_done	(sc_done),
				.sc_dout	(SR_IN),
				.sc_clk		(SR_CK),
				.sc_rstb	(SR_RSTB),
				.sc_load	(SR_LOAD)
		);

		shifter_send read_cfg (
				//input
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.wr_en	(read_en),
				.cs_chn	(cfig_data[7:0]),

				.sr_out	(SROUT_READ),

				//output
				.read_clk	(CLK_READ),
				.sr_in		(SRIN_READ)
		);

		wire	uart_idle;
		hv_control	hv_control_inst	(
				//input
				.clk	(clk),
				.rst_n	(FPGA_RESET),
				.soft_rst	(rst_delay),
				.tx	(D2),
				.rx_en	(hv_config_en),
				.din	(cfig_data[7:0]),

				//output
				.rx	(TEST_SMA2),
				.dout	(uart_tx[7:0]),
				.valid	(uart_valid),
				.idle	(uart_idle)
		);


		assign LED[0] = 1'b1;	//CY_IFCLK working	
		assign LED[1] = 1'b1;
		assign LED[2] = 1'b1;
		assign LED[3] = 1'b1;
		assign LED[4] = 1'b1;
		assign LED[5] = 1'b1;
endmodule
