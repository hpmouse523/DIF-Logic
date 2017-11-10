///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: Top_Level.v
// File historyn
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description:
//This module is used for ECAL_DIF of SKIROC2 Chip

//
// Targeted device::FPGA A7 100T FG484
// Author: <Siyuan>
//
///////////////////////////////////////////////////////////////////////////////////////////////////

//`timescale <time_units> / <precision>
//for testing github function
module Top_Level(
	input  Clk_In,
	input  Rst_n,
	/*IO interface of USB*/
	input  Usb_Flaga,
	input  Usb_Flagb,
	input  Usb_Flagc/* synthesis syn_keep=1 */,
	input  Usb_Flagd,
	input  Usb_Ifclk,
	output Usb_Slwr,
	output Usb_Slrd,
	output Usb_Sloe,
	output Usb_Pktend,
	output [1:0]   Usb_Faddr,
	output Usb_Wu,

	inout  [15:0]   Usb_Fdata,

	/*--------IO of Slow_Control -------*/
	output Out_Sr_Ck                /* synthesis syn_keep=1 */,
	output Out_Sr_In                /* synthesis syn_keep=1 */,
	output Out_Sr_Rstb              /* synthesis syn_keep=1 */,
	output Out_Select,              /* Select SC 1 or ProbRegister0 mode*/
	input  In_Sr_Out,               /* input of Slow control SR command*/


	/* ---------IO of other SKIROCs'-------*/
	output Out_Start_Ramp_TDC_Ext,  // External TDC Ramp Start signal, Act H Default 0
	output Out_Start_Rampb_ADC_Ext, // Ex ADC Ramp Start signal, Act L, Default 1
	input  In_Trig_Outb,            // OR of the 64 Signals Act L Def 1
	input  In_Dout_1b,              // Data serial output
	input  In_Dout_2b,              // Data serial output
	input  In_TransmitOn_1B,        // Active data readout   Act H def 0
	input  In_TransmitOn_2B,        // Same as above
	input  In_Chipsatb,             // Analogue memory full / Acq stopped  Act H def 0
	output Out_Raz_Chn_N,           // Erase active Analogue Column ActH def 0
	output Out_Raz_Chn_P,
	output Out_Trig_Ext_P,          // External Trigger input   Act H def 0
	output Out_Trig_Ext_N,
	output Out_Val_Evt_P,           // Disable discriminator output signal ActL def 1
	output Out_Val_Evt_N,
	output Out_Start_Acq,           // Start_alow acquisition on analogue memory ActH def0  Level active
	output Out_Ck_40P,              // 40MHz Clock
	output Out_Ck_40N,
	output Out_Ck40_Test,           // Test 40MHz sigle input
	output Out_Ck_5P,
	output Out_Ck_5N,
	output Out_Start_Convb,         // Start conversion signal Act L def 1 Rising edge
	output Out_Start_Readout2,      // Digital RAM start readout signal ActH def 0
	output Out_Start_Readout1,
	output Out_Resetb,              // Reset ASIC digital part  Act L def 1
	output Out_Hold,                // Backup Analogue memory hold signal ActH def 0
	input  In_End_Readout1,         // Digital RAM end readout signal ActH def 0
	input  In_End_Readout2,
	input  In_Digital_Prob1_SK1,        // Digital probe output
	input  In_Digital_Prob2_SK1,
	input  In_Digital_Prob1_SK2,
	input  In_Digital_Prob2_SK2,
	input  In_Srout_Read,           // Read register output
	output Out_Pwr_On_D,            // Digital Power pulsing control Act H def 1
	output Out_Pwr_On_Dac,          // DAC power pulsing control ACtH def 0
	output Out_Pwr_On_Adc,          // ADC power Pulsing control Act H def 0
	output Out_Pwr_On_A,            // Analogue part Power pulsing control Act H ,def 0
	output Out_Srin_Read,           // Read Register Output
	output Out_Ck_Read,             // Read register Clock
	output Out_Rstb_Pa,             // Charge PreAmp Reset Signal Act L def 1

	/*---IO of DAC -----*/
	output Out_SCLK_Cali,
	output Out_Din_Cali,
	output Out_CS_n_Cali,

	/*----IO of  HV_Control-------*/
	input In_Hv_Tx,//input of return data
  output Out_Hv_Rx,//output to Hv_Module	

	// IO of LED and SMD    LED is also test point
	output [8:1]   LED,
	input  SMA_ExTrig_Cnt, //
	output SMA1







	);






	/*------------------------------*/
	wire        Sig_Sel_ADC_Test;
	wire        Sig_End_SC;
	wire				Sig_Hit_200ns;
	wire        Sig_Start_Auto_Scan;
	wire [8:1]  Sig_In_Hv_Control_Word;
	wire        Sig_In_Hv_Control_En;
	wire [4:1]  Sig_Set_Hv_1;
	wire [4:1]  Sig_Set_Hv_2;	
	wire [4:1]  Sig_Set_Hv_3;
	wire [4:1]  Sig_Set_Hv_4;
	//assign  Out_Resetb                          =   1'b1;
	wire        Sig_ExTrig_to_ExtPN;
	wire        Sig_Ex_Trig_Only_Exmode;
	wire        Sig_Sel_OnlyExTrig;
	wire [8:1]	Sig_Delay_Trig;
	wire [8:1]  Sig_Delay_Trig_Temp;//for translation
	wire [12:1] Sig_Test_Cnt_Hit;

	wire         Sig_Finish_Scan_Flag;
	wire         Sig_Start_Readout;
	wire         Sig_Ck_40;
	wire         Out_Force_Trig;
	wire         Sig_Raz_Chn;
	wire         Sig_Ck_5;
	wire         Clk_10M;
	wire         Clk_40M;
	wire         Sig_Pwr_On_D;
	wire         Sig_Val_Evt;
	wire         Sig_Main_Backup;
	wire         Sig_Start_Register;
	wire [64:1]  Sig_Choose_Channel_Register;
	wire         Sig_Select_Ramp_ADC;
	wire         Sig_Select_TDC_On;
	wire         Sig_Select_Start_SC;
	wire         Sig_Set_SC_Auto_Scan;
	wire         Sig_Start_SC_USB_Cmd;
	wire         Sig_Start_Cfg_Hv;
	wire         Sig_Start_Stop_Hv;
	wire [56:1]  Sig_7byte_Hv;

	wire         Sig_Flag_Start_Stop_Hv;
	wire  [48:1] Sig_Set_DAC_From_Auto;
	wire	[9:0]  Sig_TA_Thr_From_USB;
	wire [64:1]  Sig_Mask_Word;
	wire [256:1] Sig_DAC_Adj;
	wire [4:1]   Sig_DAC_Adj_Chn64;
	wire [64:1]  Sig_Mask_Word_From_Auto;
	wire [256:1] Sig_Mask_Word_From_Auto_256bit;
	wire [64:1]  Sig_Set_Mask64;
  wire [10:1]  Sig_Auto_Dac_Input_Chip1,
							Sig_Auto_Dac_Input_Chip2,
							Sig_Auto_Dac_Input_Chip3,
							Sig_Auto_Dac_Input_Chip4;
	// assign Sig_Val_Evt = 1'b1; // 0 means disable discriminator outputsignal
	// assign        Sig_Raz_Chn                   =   1'b1;//1means Erase active analogue column



	assign Out_Start_Readout1 = Sig_Start_Readout;
	assign Out_Start_Readout2 = Out_Start_Readout1;

	
	assign Sig_Auto_Dac_Input_Chip1[1] = Sig_Set_DAC_From_Auto[46];
	assign Sig_Auto_Dac_Input_Chip1[2] = Sig_Set_DAC_From_Auto[45];
	assign Sig_Auto_Dac_Input_Chip1[3] = Sig_Set_DAC_From_Auto[44];
	assign Sig_Auto_Dac_Input_Chip1[4] = Sig_Set_DAC_From_Auto[43];
	assign Sig_Auto_Dac_Input_Chip1[5] = Sig_Set_DAC_From_Auto[42];
	assign Sig_Auto_Dac_Input_Chip1[6] = Sig_Set_DAC_From_Auto[41];
	assign Sig_Auto_Dac_Input_Chip1[7] = Sig_Set_DAC_From_Auto[40];
	assign Sig_Auto_Dac_Input_Chip1[8] = Sig_Set_DAC_From_Auto[39];
	assign Sig_Auto_Dac_Input_Chip1[9] = Sig_Set_DAC_From_Auto[38];
	assign Sig_Auto_Dac_Input_Chip1[10] = Sig_Set_DAC_From_Auto[37];

	/*---- Diff buffer for Out_Raz_Chn_P -----*/

	OBUFDS #(
		.IOSTANDARD("BLVDS_25") // Specify the output I/O standard
	) OBUFDS_Raz (
		.O(Out_Raz_Chn_P),      // Diff_p output (connect directly to top-level port)
		.OB(Out_Raz_Chn_N),     // Diff_n output (connect directly to top-level port)
		.I(Sig_Raz_Chn)         // Buffer input
		);

	// [> ------Diff buffer for Out_Val_Evt_P--------<]

	OBUFDS #(
		.IOSTANDARD("BLVDS_25") // Specify the output I/O standard
	) OBUFDS_Val (
		.O(Out_Val_Evt_P),      // Diff_p output (connect directly to top-level port)
		.OB(Out_Val_Evt_N),     // Diff_n output (connect directly to top-level port)
		.I(Sig_Val_Evt)         // Buffer input
		);

	/* ----Diff buffer for  Out_Trig_Ext_P------*/

	OBUFDS #(
		.IOSTANDARD("BLVDS_25") // Specify the output I/O standard
	) OBUFDS_Trig (
		.O(Out_Trig_Ext_P),     // Diff_p output (connect directly to top-level port)
		.OB(Out_Trig_Ext_N),    // Diff_n output (connect directly to top-level port)
		.I(Sig_ExTrig_to_ExtPN)      // Buffer input
		);
	/* -------Out_Ck_40P--------------*/

	OBUFDS #(
		.IOSTANDARD("BLVDS_25") // Specify the output I/O standard
	) OBUFDS_Ck_40 (
		.O(Out_Ck_40P),         // Diff_p output (connect directly to top-level port)
		.OB(Out_Ck_40N),        // Diff_n output (connect directly to top-level port)
		.I(Sig_Ck_40)           // Buffer input
		);


	OBUFDS #(
		.IOSTANDARD("BLVDS_25") // Specify the output I/O standard
	) OBUFDS_Ck_5 (
		.O(Out_Ck_5P),          // Diff_p output (connect directly to top-level port)
		.OB(Out_Ck_5N),         // Diff_n output (connect directly to top-level port)
		.I(Sig_Ck_5)            // Buffer input
		);

ODDR_Clk ODDR_Clk_10M (
  .clk_in(Clk_10M),    // input wire clk_in
  .clk_out(Sig_Ck_5)  // output wire clk_out
);
ODDR_Clk ODDR_Clk_40M (
  .clk_in(Clk_40M),    // input wire clk_in
  .clk_out(Sig_Ck_40)  // output wire clk_out
);

	// ODDR2 #(
	//   .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1"
	//   .INIT(1'b0),            // Sets initial state of the Q output to 1'b0 or 1'b1
	//   .SRTYPE("SYNC")         // Specifies "SYNC" or "ASYNC" set/reset
	// ) ODDR2_Clk_5M
	// (
	//   .Q(Sig_Ck_5),           // 1-bit DDR output data
	//   .C0(Clk_10M),           // 1-bit clock input
	//   .C1(~Clk_10M),          // 1-bit clock input
	//   .CE(1'b1),              // 1-bit clock enable input
	//   .D0(1'b1),              // 1-bit data input (associated with C0)
	//   .D1(1'b0),              // 1-bit data input (associated with C1)
	//   .R(1'b0),               // 1-bit reset input
	//   .S(1'b0)                // 1-bit set input
	//   );





	OBUF #(
		.DRIVE(12),             // Specify the output drive strength
		.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
		.SLEW("SLOW")           // Specify the output slew rate
	) OBUF_inst (
		.O(Out_Ck40_Test),      // Buffer output (connect directly to top-level port)
		.I(Clk_40M)             // Buffer input
		);





	/*--Reset Delay signal--*/
	reg  Rst_n_Delay1;
	reg  Rst_n_Delay2;
	/*-----Power on Reset -----*/
	// reg  [23:0]        Cnt_Power_On_Reset  =   24'h0;     //Used to cnt until FFFFFF then high Rst_n_Delay2. It's 1.3*256 ms about 300ms

	/*Ex_Fifo*/
	wire [15:0] Fifo_Qout;

	wire [15:0] Sig_dout_Fifo_SKIROC2;
	wire [15:0] Sig_dout_Fifo_AutoTA;
	wire Fifo_Empty;

	wire Sig_Fifo_Empty_SKIROC2;
	wire Sig_Fifo_Empty_AutoTA;
	wire Fifo_Rd_En;

	wire Sig_Rd_Fifo_SKRIOC2;
	wire Sig_Rd_Fifo_AutoTA;
	/*for usb command*/
	wire [15:0] Cmd_From_Usb;
	wire Cmd_From_Usb_En;
	/*Clk*/
	/*-DAC-*/
	wire [11:0]    Sig_Set_DAC;
	wire Sig_Start_DAC;
	/*----------for Clk_5M-----------*/
	wire Clk_5M;

	/*----------IO of Fifo for Slow_Control-------*/
	wire [7:0]     Sig_Ex_Fifo_SC_Dout;
	wire [7:0]     Sig_Ex_Fifo_SC_Din;
	wire Sig_Ex_Fifo_SC_Rd_En;
	wire Sig_Ex_Fifo_SC_Empty;
	wire Sig_Ex_Fifo_SC_Wr_En;

	wire Sig_Fifo_Register_Done/* synthesis syn_keep=1 */;
	wire Sig_SC_Done;
	wire Sig_Start_SC;


	wire Clk_Out_2_All;
	wire Clk_2_Rst;

	/* -------- signals of DAC--------*/
	wire             Sig_Start_Stop_ADG;

	BUFG BUFG_inst (
		.O(Clk_Out_2_All),                   // 1-bit output: Clock buffer output
		.I(Clk_In)                           // 1-bit input: Clock buffer input
		);




	wire Status_Power_On_Control;
	// wire [15:0] Data_2_Exfifo;
	wire Choose_Data_2_Exfifo;
	// wire Exfifo_We_In;
	wire We_Control_2_Exfifo;

	localparam [15:0] DATA_2_USB = 16'haa55; // for test







	//ADC Constant module
	wire [13:0]                Set_Constant_Interval_Time_Sig;


	//Trig
	wire [3:0]                  Control_Trig_Mode_Sig;
	wire [7:0]                  Sig_Set_Interval_Time;

	wire                        Trig_Start_Stop_Sig;
	wire [12:1]                  Sig_Set_Ini_DAC_for_Auto_Scan;

	//DAC
	wire                        Start_Set_DAC_Sig;
	wire [1:0]                  Sel_Cali_TA_Sig;
	wire [11:0]                 Set_Cali_DAC_Sig;
	wire [9:0]                 Set_TA_Thr_DAC_Sig_12;
	wire [9:0]                 Sig_In_Dac_Trigger;


	//SC and Prob
	wire [192:1]              Sig_AnaProb_SS1_SS10_PA;
	wire [128:1]             Sig_AnaProb_Thre_Fsb;
	wire                     Sig_Ex_Fifo_Wr_En_From_Prob_Register;
	wire [7:0]               Sig_Ex_Fifo_Din_From_Register;
	wire                     End_Flag_From_Prob;
	wire                     In_To_Ex_Fifo_Wr_En;
	wire [7:0]               In_To_Ex_Fifo_Din;
	wire                     Start_In_SC_Prob;
	wire [3:0]               Sig_Sel_Feedback_Capacitance;



	wire                        Sel_Chn_A_B_Sig;
	/*-----TA Module------*/


	/*-----SCI module----*/
	wire                      Sig_Start_Acq;



	/*-------Select Normal or Cali mode-----*/
	wire                        Sel_Work_Mode_Sig;
	wire                        Sig_Sel_High_Low_Leakage;
	/*-------Output of Cali and Normal mode-*/

	/*---------CLK 40M-------------*/


	wire        Sig_Parallel_Data_En;
	wire [15:0] Sig_Parallel_Data;
	wire [15:0] Sig_Parallel_Data_Temp;
	wire [15:0] Sig_Parallel_Data_From_Auto_Scan;
	wire [15:0] Sig_Parallel_Data_From_Auto_Scan_Temp;
	wire				Sig_Parallel_Data_En_From_Auto_Scan;




	assign				Sig_Parallel_Data_From_Auto_Scan[15:8] = Sig_Parallel_Data_From_Auto_Scan_Temp[7:0];
	assign				Sig_Parallel_Data_From_Auto_Scan[7:0]  = Sig_Parallel_Data_From_Auto_Scan_Temp[15:8];
	assign        Sig_Parallel_Data[15:8]                = Sig_Parallel_Data_Temp[7:0];
	assign        Sig_Parallel_Data[7:0]                 = Sig_Parallel_Data_Temp[15:8];
	assign				Sig_Delay_Trig[8] = Sig_Delay_Trig_Temp[1];
	assign				Sig_Delay_Trig[7] = Sig_Delay_Trig_Temp[2];
	assign				Sig_Delay_Trig[6] = Sig_Delay_Trig_Temp[3];
	assign				Sig_Delay_Trig[5] = Sig_Delay_Trig_Temp[4];
	assign				Sig_Delay_Trig[4] = Sig_Delay_Trig_Temp[5];
	assign				Sig_Delay_Trig[3] = Sig_Delay_Trig_Temp[6];
	assign				Sig_Delay_Trig[2] = Sig_Delay_Trig_Temp[7];
	assign				Sig_Delay_Trig[1] = Sig_Delay_Trig_Temp[8];

	//////////////////////////////////
	// always @ (posedge Clk_2_Rst)
	// begin
	//   if(Cnt_Power_On_Reset   < 24'hFF_FFFD)
	//   begin
	//     Cnt_Power_On_Reset          <=  Cnt_Power_On_Reset  + 1'b1;
	//   end
	//   else
	//   begin
	//     Cnt_Power_On_Reset          <=  Cnt_Power_On_Reset;
	//   end
	// end
  //



	always @ (posedge Clk_Out_2_All )
	begin
		if( ~Rst_n   )
		begin
			Rst_n_Delay1        <=  1'b0;
			Rst_n_Delay2        <=  1'b0;                 //Power on Reset
		end
		else
		begin
			Rst_n_Delay1        <=    Rst_n;
			Rst_n_Delay2        <=    Rst_n_Delay1;
		end
	end

	/*-----------PLL of 5M for Slow_Control-------*/

	PLL_40M PLL_40M_Inst     // PLL 40MHz and 10MHz
	(
                           // Clock out ports
		.clk_out1(Clk_40M),    // output clk_out1: 40MHz
		.clk_out2(Clk_10M),    // output clk_out2: 10MHz

                           // Status and control signals
		.reset(~Rst_n_Delay2), // input reset
                           // Clock in ports
		.clk_in1(Clk_Out_2_All)
	);                       // input clk



	/////////////////////
	/*---------Fifo for Registers---*/


	Fifo_Register Fifo_Register_Inst (
		.clk(Clk_10M),                // input wire clk
		.rst(~Rst_n_Delay2),          // input wire rst
		.din(In_To_Ex_Fifo_Din),      // input wire [7 : 0] din
		.wr_en(In_To_Ex_Fifo_Wr_En),  // input wire wr_en
		.rd_en(Sig_Ex_Fifo_SC_Rd_En), // input wire rd_en
		.dout(Sig_Ex_Fifo_SC_Dout),   // output wire [7 : 0] dout
		.full(),                      // output wire full
		.empty(Sig_Ex_Fifo_SC_Empty)  // output wire empty
		);
                                  /* ---------Prepare Register----------*/
	Prepare_Register Prepare_Register_Inst(
		.Clk(Clk_10M),
		.Rst_N(Rst_n_Delay2),
		.Start_In(Sig_Start_SC),


		/*-----------Slow Control Registers-----------*/    //add parameter when
		// necessary

		.In_DAC_Gain_Select(Set_TA_Thr_DAC_Sig_12),
		.In_Dac_Trigger(Sig_In_Dac_Trigger),
		.In_Select_Main_Backup(~Sig_Main_Backup),
		.In_En_Trig_Discriminator(Sig_Val_Evt),
		.In_Sel_Feedback_Capacitance(Sig_Sel_Feedback_Capacitance),
		.In_Sel_Comp_PA(Sig_Sel_Feedback_Capacitance[2:0]),
		.In_Sel_Work_Mode(Sel_Work_Mode_Sig),
		.In_Sel_High_Low_Leakage(Sig_Sel_High_Low_Leakage),//1 means High leakage default 0
		.In_Sel_ADC_Test(Sig_Sel_ADC_Test),
		.In_Sel_OnlyExTrig(Sig_Sel_OnlyExTrig), //default 0 ,Select Trig only Ex  default 0 means In or Ex 1means Only Ex
		.In_Chip_ID_Bin(8'h01),
		.In_Delay_Trig(Sig_Delay_Trig), //default = 8'h70
		.In_Select_TDC_On(Sig_Select_TDC_On),

		.In_Mask_Word(Sig_Mask_Word),
		.In_DAC_Adj(Sig_DAC_Adj),
		/*-----------Exfifo--------------------------*/
		.Out_Ex_Fifo_Wr_En(Sig_Ex_Fifo_SC_Wr_En),
		.Out_Ex_Fifo_Din(Sig_Ex_Fifo_SC_Din),
		.Out_3Test_Pins(LED[8:6]),// 8:Leakage   7 Ctest   6 PAon
		/*-----------End_Flag-----*/
		.End_Flag(Sig_Fifo_Register_Done)
		);

	Prepare_Probe_Register Prepare_Probe_Register_Inst(
		.Clk(Clk_10M),
		.Rst_N(Rst_n_Delay2),
		.Start_In(Sig_Start_SC),
		.In_Select_Ramp_ADC(Sig_Select_Ramp_ADC),
		.In_AnaProb_SS1_SS10_PA(Sig_AnaProb_SS1_SS10_PA),
		.In_AnaProb_Thre_Fsb(Sig_AnaProb_Thre_Fsb),
		.In_Outt_Out_Delay(128'h0),
		.In_OutGain_Out_ADC(128'h0),
		.In_OR64_OR64delay(2'b10),
		.Out_Ex_Fifo_Wr_En(Sig_Ex_Fifo_Wr_En_From_Prob_Register),
		.Out_Ex_Fifo_Din(Sig_Ex_Fifo_Din_From_Register),
		.End_Flag(End_Flag_From_Prob)
		);



	/*----------Shitf bit of 616 Registers-----*/
	Slow_Control Slow_Control_or_Prob_Inst(
		.Clk(Clk_10M),                          // 10MHz
		.Rst_N(Rst_n_Delay2),
		.Start_In(Start_In_SC_Prob),           // Start Configging
		.End_SC(Sig_End_SC),
		.Out_Sr_Ck(Out_Sr_Ck),                 // Clock of config
		.Out_Sr_In(Out_Sr_In),                 // Dout of every bit
		.Out_Sr_Rstb(),                        // Reset of register

		.In_Ex_Fifo_Data(Sig_Ex_Fifo_SC_Dout), // Command to be config to register, modified outside this module in usbinterpreter module
		.In_Ex_Fifo_Empty(Sig_Ex_Fifo_SC_Empty),
		.Out_Ex_Fifo_Rd_En(Sig_Ex_Fifo_SC_Rd_En)
		);

	////////////////////
	USB_Con USB_Con_Inst(

		.USBCLK_i(Clk_Out_2_All),       // IN STD_LOGIC;-----IFCLK
		.SLRD_o(Usb_Slrd),              // OUT STD_LOGIC;
		.SLOE_o(Usb_Sloe),              // OUT STD_LOGIC;
		.SLWR_o(Usb_Slwr),              // OUT STD_LOGIC;
		.FlagA_i(Usb_Flaga),            // ----EP6 EMPTY FLAG // EP6 IS IN ENDPOINT // FLAGB=EP6 full flag  FLAGA=EP6 empty flag
		.FlagB_i(Usb_Flagb),            // ----EP6 FULL FLAG
		.FlagC_i(Usb_Flagc),            // ----EP2 EMPTY FLAG // EP2 IS OUT ENDPOINT // FLAGD=EP2 full flag  FLAGC=EP2 empty flag
		.FlagD_i(Usb_Flagd),            // ----EP2 FULL FLAG
		.PktEnd_o(Usb_Pktend),          // OUT STD_LOGIC;
		.WAKEUP(Usb_Wu),                // OUT STD_LOGIC;  -- modified by Junbin 2014/1/20
		.FifoAddr_o(Usb_Faddr),         // OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		.USBData(Usb_Fdata),            // INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                                    // connect with ExFifo
		.ExFifoData_i(Fifo_Qout[15:0]), // command_out//IN(15 DOWNTO 0); data write to usb_infifo, almost from fpga_fifo 16'ha5a5
		.ExFifoEmpty_i(Fifo_Empty),     // IN
		.ExFifoRdEn_o(Fifo_Rd_En),      // OUT STD_LOGIC;
                                    // connect with CtrReg
		.rst(Rst_n_Delay2),
		.EndUsbWr_i(1'b0),              // IN STD_LOGIC;
		.CtrData_o(Cmd_From_Usb[15:0]), // OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  data read from usb_outfifo
		.CtrDataEn_o(Cmd_From_Usb_En)


		);

		Ex_Fifo Ex_Fifo_For_AutoTA(
			.rst(~Rst_n_Delay2),                       // input wire rst
			.wr_clk(Clk_10M),                 // input wire wr_clk
			.rd_clk(Clk_Out_2_All),                    // input wire rd_clk
			.din(Sig_Parallel_Data_From_Auto_Scan),      // input wire [15 : 0] din
			.wr_en(Sig_Parallel_Data_En_From_Auto_Scan), // input wire wr_en
			.rd_en(Sig_Rd_Fifo_AutoTA),                        // input wire rd_en
			.dout(Sig_dout_Fifo_AutoTA),                          // output wire [15 : 0] dout
			.full(),                                   // output wire full
			.empty(Sig_Fifo_Empty_AutoTA)                         // output wire empty
			);


		Ex_Fifo Ex_Fifo_For_ReadoutSKIROC2(
			.rst(~Rst_n_Delay2),                       // input wire rst
			.wr_clk(Clk_40M),                 // input wire wr_clk
			.rd_clk(Clk_Out_2_All),                    // input wire rd_clk
			.din(Sig_Parallel_Data),      // input wire [15 : 0] din
			.wr_en(Sig_Parallel_Data_En), // input wire wr_en
			.rd_en(Sig_Rd_Fifo_SKRIOC2),                        // input wire rd_en
			.dout(Sig_dout_Fifo_SKIROC2),                          // output wire [15 : 0] dout
			.full(),                                   // output wire full
			.empty(Sig_Fifo_Empty_SKIROC2)                         // output wire empty
			);


		// Exfifo for writting into USB Chip


		Sci_Acq Sci_Acq_Inst (
			.Clk(Clk_Out_2_All),
			.Rst_N(Rst_n_Delay2),
			.In_Start_Work(Sig_Start_Acq),
			.Out_Acqing(),
			.In_Chipsatb(In_Chipsatb),
			.In_End_Readout(In_End_Readout1),
			.In_Ex_Trig(SMA_ExTrig_Cnt),//Rising edge
			.Cnt_Trig(),
			.Out_Start_Acq(Out_Start_Acq),
			.Out_Start_Convb(Out_Start_Convb),
			.Out_Start_Readout(Sig_Start_Readout),
			.Out_Pwr_On_D(Sig_Pwr_On_D),
			.Out_Resetb_ASIC()
			);

		DAC_TLV5618 Dac_For_Cali(
			.Clk(Clk_10M),
			.Rst_n(Rst_n_Delay2),
			.Usb_Cmd_En(Sig_Start_DAC),
			.In_Sel_A_B(1'b1),//Set Channel A
			.In_Set_Chn_DAC_Code(Sig_Set_DAC),

			//IO of TLV5618
			.Out_SCLK(Out_SCLK_Cali),
			.Out_Din(Out_Din_Cali),
			.Out_CS_n(Out_CS_n_Cali)
);





				Auto_TA_Scan Auto_TA_Scan_Inst(                  // used to scan the DAC threshold
					.Clk_10MHz(Clk_10M),
					.Rst_N(Rst_n_Delay2),
					.Ini_DAC(Sig_Set_Ini_DAC_for_Auto_Scan[10:1]), // need 10 bit  assert 12bit
					.In_Trig_Ex_From_Signal(SMA_ExTrig_Cnt),       // need rising edge
					.In_Hit_From_SKIROC(~Sig_Hit_200ns),
					.In_Start_Scan(Sig_Start_Auto_Scan),           // start auto scan
					.In_Finish_Sc(Sig_End_SC),                     // at least last 1cyc
					.Out_Finish_Scan(Sig_Finish_Scan_Flag),
					.Out_Set_SC(Sig_Set_SC_Auto_Scan),
					.Out_Set_DAC(Sig_Set_DAC_From_Auto),           // 48bit but useful is 40bit
					.Out_Mask_Code(Sig_Mask_Word_From_Auto_256bit),
					.Out_Fifo_Din(Sig_Parallel_Data_From_Auto_Scan_Temp),
					.Out_Token_All(Sig_Select_Start_SC),
					.Out_Fifo_Wr(Sig_Parallel_Data_En_From_Auto_Scan),
					.Out_Test_Cnt_Hit(Sig_Test_Cnt_Hit)
					);
				Read_Register_Set Read_Register_Set_Inst(                     // used for readout FIFO datas from SKIROC2
					.Clk(Clk_10M),
					.Rst_N(Rst_n_Delay2),
					.In_Enable_Register(~Sig_Main_Backup),
					.In_Choose_Channel(Sig_Choose_Channel_Register),
					.In_Start_Set_Register(Sig_Start_Register),
					.Out_Srin_Read(Out_Srin_Read),
					.Out_Ck_Read(Out_Ck_Read)
					);



				Readout_Dout Readout_Dout_Inst(
					.Clk(Clk_40M),
					.Rst_N(Rst_n_Delay2),
					.In_Doutb(In_Dout_1b),
					.In_TransmitOnb(In_TransmitOn_1B),
					.Out_Parallel_Data(Sig_Parallel_Data_Temp),
					.Out_Parallel_Data_En(Sig_Parallel_Data_En)
					);

				//Command(from USB Chip) interpreter
				usb_command_interpreter usb_command_interpreter_Inst(

					.clk(Clk_Out_2_All),
					.reset_n(Rst_n_Delay2),
					.in_from_usb_Ctr_rd_en(Cmd_From_Usb_En),
					.in_from_usb_ControlWord(Cmd_From_Usb[15:0]),
					.out_to_usb_Acq_Start_Stop(Sig_Start_Acq),
					.out_to_control_usb_data(Choose_Data_2_Exfifo),
					.LED(),
					.Out_DAC_Adj_Chn64(Sig_DAC_Adj_Chn64),
					.Out_Sel_Work_Mode(Sel_Work_Mode_Sig),
					.Out_Sel_High_Low_Leakage(Sig_Sel_High_Low_Leakage),
					.Out_Valid_TA_for_Self_Mod(),
					.Out_Val_Evt(Sig_Val_Evt),//default 1 en discriminator
					.Out_Trig_Start_Stop(Trig_Start_Stop_Sig),
					.Out_Sel_OnlyExTrig(Sig_Sel_OnlyExTrig),
					.Out_Hold(Out_Hold),
					.Out_Control_Trig_Mode(Control_Trig_Mode_Sig),
					.Out_Delay_Trig_Temp(Sig_Delay_Trig_Temp),
					.Out_Set_Trig_Inside_Time(Sig_Set_Interval_Time),
					.Out_Set_Constant_Interval_Time(Set_Constant_Interval_Time_Sig),
					.Out_Set_Ini_DAC_for_Auto_Scan(Sig_Set_Ini_DAC_for_Auto_Scan),
					.Out_Set_Hv_1(Sig_Set_Hv_1),//highest 4bit
					.Out_Set_Hv_2(Sig_Set_Hv_2),
					.Out_Set_Hv_3(Sig_Set_Hv_3),
					.Out_Set_Hv_4(Sig_Set_Hv_4),//lowest bit
					.Out_Sel_ADC_Test(Sig_Sel_ADC_Test),
					.Out_ADG_Switch(),
					.Out_Reset_ASIC_b(Out_Resetb),
					.Out_Start_Acq(Sig_Raz_Chn),
					.Out_Start_Conver_b(Sig_Start_Auto_Scan),
					.Out_Force_Trig(Out_Force_Trig),
					.Out_Start_Readout1(Sig_Start_DAC),
					.Out_Start_Cfg_Hv(Sig_Start_Cfg_Hv),
					.Out_Start_Stop_Hv(Sig_Start_Stop_Hv),
					.Out_Flag_Start_Stop_Hv(Sig_Flag_Start_Stop_Hv),
					.Out_Start_Readout2(),
					.Out_Start_Stop_ADG(Sig_Start_Stop_ADG),
					.Out_AnaProb_SS1_SS10_PA(Sig_AnaProb_SS1_SS10_PA),
					.Out_AnaProb_Thre_Fsb(Sig_AnaProb_Thre_Fsb),
					.Select_Main_Backup(Sig_Main_Backup),
					.Out_Set_Register(Sig_Start_Register),
					.Out_Sel_Feedback_Capacitance(Sig_Sel_Feedback_Capacitance),
					.Out_Choose_Channel_Resister(Sig_Choose_Channel_Register),
					.Out_Set_Mask64(Sig_Set_Mask64),
					.Out_Sel_Cali_TA(Sel_Cali_TA_Sig),
					.Out_Set_Cali_DAC(Sig_Set_DAC),
					.Out_Set_TA_Thr_DAC_12(Set_TA_Thr_DAC_Sig_12),
					.Out_Set_TA_Thr_DAC_34(Sig_TA_Thr_From_USB),
					.Out_TA_Mode(),
					.Out_Select_Ramp_ADC(Sig_Select_Ramp_ADC),
					.Out_Disable_Channel(),
					.Out_Start_Config(Sig_Start_SC_USB_Cmd),
					.Out_Select(Out_Select),
					.Out_Select_TDC_On(Sig_Select_TDC_On),
					.Out_Status_Power_On_Control(Status_Power_On_Control)

					);

				Flag_LED Flag_LED8(
					.Clk_In(Clk_Out_2_All), //80MHz
					.Rst_N(Rst_n_Delay2),
					.In_Start_Light(Sig_Start_Auto_Scan),
					.In_Stop_Extinguish(Sig_Finish_Scan_Flag),//(Sig_Finish_Scan_Flag),
					.Out_LED(),
					.Out_LED_Blink()
					);
				Hit_50_to_200ns Hit_50_to_200ns_Inst(
					.Clk_In(Clk_Out_2_All),//80MHz
					.Rst_N(Rst_n_Delay2),
					.In_Hit_Sig(In_Trig_Outb),//Enb
					.Out_Hit_Sig(Sig_Hit_200ns)
    			);
		 		General_ExTrig General_ExTrig_Inst(
    			.Clk(Clk_Out_2_All),
    			.Rst_N(Rst_n_Delay2),
    			.In_Trig_SMA(SMA_ExTrig_Cnt),
    			.Out_Ex_Trig(Sig_Ex_Trig_Only_Exmode)
    );
 Prepare_Hv_Cmd                   Prepare_Hv_Cmd_Inst(
     .Clk_In(Clk_40M),//40MHz
     .Rst_N(Rst_n_Delay2),
     .Start_Cfg(Sig_Start_Cfg_Hv),//Start Cfg Hv
     .Start_Stop_Hv(Sig_Start_Stop_Hv),//Start_Stop_Hv
     .In_Hv_7Byte(Sig_7byte_Hv),//7byte value HBV_ _ _ _ need ASCII
     .In_Flag_Start(Sig_Flag_Start_Stop_Hv),        //Set Start or Stop
     .Out_Cmd(Sig_In_Hv_Control_Word),//to Hv_Control
     .Out_En(Sig_In_Hv_Control_En)
    );

	hv_control	hv_control_Inst (
				//input
     .clk	(Clk_40M),
     .rst_n	(Rst_n_Delay2),
     .soft_rst	(Rst_n_Delay2),
     .tx		(1'b0),
     .din	(Sig_In_Hv_Control_Word),
     .rx_en	(Sig_In_Hv_Control_En),
				//output
     .rx		(Out_Hv_Rx),
     .dout	(),
     .valid	(),
     .idle	()
		);

 Hex_2_ASCII Out_Set_Hv_1(
    .In_Hex(Sig_Set_Hv_1),//4bit Hex
    .Out_ASCII(Sig_7byte_Hv[32:25])//8bit ASCII
    );
 Hex_2_ASCII Out_Set_Hv_2(
    .In_Hex(Sig_Set_Hv_2),//4bit Hex
    .Out_ASCII(Sig_7byte_Hv[24:17])//8bit ASCII
    );
 Hex_2_ASCII Out_Set_Hv_3(
    .In_Hex(Sig_Set_Hv_3),//4bit Hex
    .Out_ASCII(Sig_7byte_Hv[16:9])//8bit ASCII
    );
 Hex_2_ASCII Out_Set_Hv_4(
    .In_Hex(Sig_Set_Hv_4),//4bit Hex
    .Out_ASCII(Sig_7byte_Hv[8:1])//8bit ASCII
    );



				//assign  Data_2_Exfifo                 =       DATA_2_USB;
				//assign  Exfifo_We_In                  =       1'b1 ;


				//<statements>
				/*-----assign default output and input----------*/

				assign Out_Start_Ramp_TDC_Ext  = 1'b0;
				assign Out_Start_Rampb_ADC_Ext = 1'b0;
				assign Out_Sr_Rstb             = 1'b1;
				assign Out_Rstb_Pa             = Out_Resetb;
				assign Out_Pwr_On_D            = Status_Power_On_Control;
				assign Out_Pwr_On_Dac          = 1'b1;
				assign Out_Pwr_On_Adc          = Status_Power_On_Control;
				assign Out_Pwr_On_A            = Status_Power_On_Control;
				assign Sig_Start_SC            = (Sig_Select_Start_SC == 1'b1)? Sig_Set_SC_Auto_Scan: Sig_Start_SC_USB_Cmd;
				assign Sig_In_Dac_Trigger      = (Sig_Select_Start_SC == 1'b1)? Sig_Auto_Dac_Input_Chip1:Sig_TA_Thr_From_USB;
				assign Sig_Mask_Word_From_Auto = Sig_Mask_Word_From_Auto_256bit[256:193];
				assign Sig_Mask_Word           = (Sig_Select_Start_SC == 1'b1) ? (Sig_Mask_Word_From_Auto|Sig_Set_Mask64) :Sig_Set_Mask64;//Auto Mask need to OR the Set
				assign Fifo_Qout               = (Sig_Select_Start_SC == 1) ? Sig_dout_Fifo_AutoTA:  Sig_dout_Fifo_SKIROC2;
				assign Sig_Rd_Fifo_SKRIOC2     = (Sig_Select_Start_SC == 1) ? 1'b0 : Fifo_Rd_En;
				assign Sig_Rd_Fifo_AutoTA      = (Sig_Select_Start_SC == 1) ? Fifo_Rd_En : 1'b0;
				assign Fifo_Empty              = (Sig_Select_Start_SC == 1) ? Sig_Fifo_Empty_AutoTA: Sig_Fifo_Empty_SKIROC2;
				//Select Slow Control or Prob Register
				assign In_To_Ex_Fifo_Wr_En     = (Out_Select == 1'b1) ? Sig_Ex_Fifo_SC_Wr_En : Sig_Ex_Fifo_Wr_En_From_Prob_Register;
				assign In_To_Ex_Fifo_Din       = (Out_Select == 1'b1) ? Sig_Ex_Fifo_SC_Din   : Sig_Ex_Fifo_Din_From_Register;
				assign Start_In_SC_Prob        = (Out_Select == 1'b1) ? Sig_Fifo_Register_Done:End_Flag_From_Prob;
				assign Sig_DAC_Adj             = {Sig_DAC_Adj_Chn64,248'b0,Sig_DAC_Adj_Chn64};
				assign SMA1                    = SMA_ExTrig_Cnt;
				assign Sig_ExTrig_to_ExtPN     = (Sig_Sel_OnlyExTrig == 1'b1) ? Sig_Ex_Trig_Only_Exmode : Out_Force_Trig;

				assign Sig_7byte_Hv[56:33] = 24'h48_42_56;
				assign LED[1] = In_Digital_Prob1_SK1;
				assign LED[2] = Sig_Hit_200ns;
				assign LED[3] = Sig_Sel_OnlyExTrig; //Sig_DAC_Adj[255];
				assign LED[4] = In_Digital_Prob1_SK2;
				assign LED[5] = Out_Resetb;
				// assign LED[6] = Out_Force_Trig;
				// assign LED[7] = Sig_Start_Cfg_Hv;
				// assign LED[8] = Sig_Start_SC_USB_Cmd;


				// (*mark_debug = "true"*) wire	Debug_Sig_Out_SCLK_Cali =	Out_SCLK_Cali;
				// (*mark_debug = "true"*) wire	Debug_Sig_Out_Din_Cali =	Out_Din_Cali;
				// (*mark_debug = "true"*) wire	Debug_Sig_Out_CS_n_Cali	=	Out_CS_n_Cali;


				// (*mark_debug = "true"*) wire  Debug_Sig_Sig_Start_Stop_Hv	=	Sig_Start_Stop_Hv;//Start or Stop Hv
				// (*mark_debug = "true"*) wire	Debug_Sig_Sig_Select_Start_SC	=	Sig_Select_Start_SC;//Sig_Select_Start_SC means token of AutoScan mode
				// (*mark_debug = "true"*) wire  Debug_Sig_Sig_Flag_Start_Stop_Hv	=	Sig_Flag_Start_Stop_Hv;//Flag of Start or stop Hv
				// (*mark_debug = "true"*) wire Debug_Sig_Sig_Start_SC	=	Sig_Start_SC;//Set Sc configuration
				// (*mark_debug = "true"*) wire Debug_Sig_Out_Sr_Ck	=	Out_Sr_Ck;//Slow Control
				// (*mark_debug = "true"*) wire Debug_Sig_Out_Sr_In	=	Out_Sr_In;
				// (*mark_debug = "true"*) wire Debug_Sig_Sig_In_Hv_Control_En	=	Sig_In_Hv_Control_En;
				// (*mark_debug = "true"*) wire Debug_Sig_Out_Hv_Rx	=	Out_Hv_Rx;//Send out signal to Rx Hv module



endmodule


