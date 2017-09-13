


`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: FEL of USTC
// Author: Steve Feng
// 
// Create Date:    15:07:56 12/10/2009 
// Design Name: 
// Module Name:    VAandADCControl 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 2010-08-23
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module VA_Readout(
       clk_sys,rstn,
		 WorkMode,
		 CaliChnID,
       nTrig,
		 TrigEna,
		 TrigDelayValue,
		 VA_Hold,VA_Shiftb,VA_CKb,ShiftOutFrmVA,VA_TestOn,
		 VA_DReset,
       ADC_CSn,ADC_nRC,ADC_nBUSY,
		 ADC_Data,Data2RdoFifo, 
       FIFO_WE,  //FIFO write enable (to store ADC data)
		 VAConvt_nBusy,
		 TrigAfterSync,
		 nLED_Trig
);

input  clk_sys,rstn;
input  WorkMode;// 0:normal mode; 1:cali mode

output VA_Hold,VA_Shiftb,VA_CKb,VA_TestOn; //VA32 Control
output VA_DReset;

//assign VA_TestOn=1'b1;     //in test mode
assign VA_TestOn=WorkMode;     // 1'b1: in test mode ; 1'b0: in normal mode

reg VA_Hold_Reg,VA_Shiftb,VA_CKb;

input ShiftOutFrmVA;

input TrigEna;//  高电平有效
input nTrig; //   负脉冲有效
input [7:0] TrigDelayValue;

output ADC_CSn,ADC_nRC;
assign ADC_CSn=1'b0;

output FIFO_WE;
reg ADC_nRC_tmp;
reg ADC_nRC;

input ADC_nBUSY;
input[15:0] ADC_Data;
output reg[15:0] Data2RdoFifo;
reg[6:0]  ChnIDCnt;   //一共7 bit 
reg[6:0]  TrigID;  //一共7 bit

input[6:0]  CaliChnID; //??要刻度的通道??号(1~96)

output TrigAfterSync;
//wire TrigAfterSync;

output VAConvt_nBusy;
output nLED_Trig; // 触发LED指示

reg[2:0] clkCnt;
wire clk=clkCnt[1]; //4分频,由50M 变为12.5M Hz

always@(posedge clk_sys)
begin
  if(!rstn)
    clkCnt<=3'b0;
  else
    clkCnt<=clkCnt+3'b001;
end

reg VaShiftOutReg; //将外部异步输入经本地时钟同步,希望能消除亚稳态风险
reg nAdcBusyReg;
always@(posedge clk)
begin
  if(!rstn) begin
    VaShiftOutReg<=1'b0;
	 nAdcBusyReg<=1'b1;
	 end
  else begin
    VaShiftOutReg<=ShiftOutFrmVA;
	 nAdcBusyReg<=ADC_nBUSY;
	 end
end

SynchExt2Clk SynchExtTrig2Clk(.Clk(clk), .nReset(rstn),.TrigEna(TrigEna),.nAsyIn(nTrig),.SynchOut(TrigAfterSync));

LED_Flicker TrigLEDFlicker(.clk(clk),.rstn(rstn),.SigIn(TrigAfterSync),.nLED_Out(nLED_Trig)); 


reg[17:0]  VACtrlState,VACtrlState_Next;


parameter
          IDLE                	= 18'b00_0000_0000_0000_0001, 
          NORMAL_HOLD_ASSERT 		= 18'b00_0000_0000_0000_0010,
          CALI_HOLD_ASSERT       = 18'b00_0000_0000_0000_0100,
          NORMAL_SHIFTB_ASSERT	= 18'b00_0000_0000_0000_1000,
          CALI_SHIFTB_ASSERT     = 18'b00_0000_0000_0001_0000,
          NORMAL_CKB_ASSERT	   = 18'b00_0000_0000_0010_0000,
          CALI_CKB_ASSERT        = 18'b00_0000_0000_0100_0000,
          CALI_WAIT_TRIG         = 18'b00_0000_0000_1000_0000,
          NORMAL_CHK_END			= 18'b00_0000_0001_0000_0000,
          DELAY_FOR_CNVT			= 18'b00_0000_0010_0000_0000,
          ADC_CNVT					= 18'b00_0000_0100_0000_0000,
          WAIT_DATA              = 18'b00_0000_1000_0000_0000,
			 LATCH_PACK_HEADER      = 18'b00_0001_0000_0000_0000,
			 LATCH_PACK_INFOR       = 18'b01_0010_0000_0000_0000,
          LATCH_DATA             = 18'b00_0100_0000_0000_0000,
			 LATCH_DATA_INFOR       = 18'b00_1000_0000_0000_0000,
			 LATCH_PACK_TRAILER     = 18'b01_0000_0000_0000_0000,
			 LATCH_STATUS           = 18'b10_0000_0000_0000_0000;
			 


reg[4:0] ADCDelayCnt;

always@(posedge clk or negedge rstn)
begin
	if(!rstn)begin
		ADCDelayCnt<=5'b0;
		end
	else if(VACtrlState==DELAY_FOR_CNVT)
	   begin
		 ADCDelayCnt<=ADCDelayCnt+5'b1;
		end
   else
	    ADCDelayCnt<=5'b0;
end

reg[7:0] TrigDelayCnt;

always@(posedge clk or posedge TrigAfterSync or negedge rstn)
begin
	if(!rstn)
	  TrigDelayCnt<=8'b1111_1111;
	else if(TrigAfterSync)
	  TrigDelayCnt<=8'b0; 
	else if(TrigDelayCnt==8'b1111_1111)
	  TrigDelayCnt<=TrigDelayCnt;
	else
	  TrigDelayCnt<=TrigDelayCnt+1;
end

//wire  TrigDelayEndFlag=(TrigDelayCnt==8'b0000_1010)?1'b1:1'b0; //hold delay~=500ns+16*80ns
wire  TrigDelayEndFlag=(TrigDelayCnt==TrigDelayValue)?1'b1:1'b0; //hold delay~=500ns+16*80ns
			 
always@(posedge clk or negedge rstn)
begin
	if(!rstn)
		VACtrlState<=IDLE;
	else
		VACtrlState<=VACtrlState_Next;
end

wire[5:0] FIFO_WE_tmp;
reg [5:0]   FIFO_WE_delay;

assign  FIFO_WE_tmp[0]  =(VACtrlState==LATCH_DATA)			   ? 1'b1:1'b0; 
assign  FIFO_WE_tmp[1]  =(VACtrlState==LATCH_DATA_INFOR)		? 1'b1:1'b0; 
assign  FIFO_WE_tmp[2]  =(VACtrlState==LATCH_PACK_HEADER)	? 1'b1:1'b0; 
assign  FIFO_WE_tmp[3]  =(VACtrlState==LATCH_PACK_INFOR)		? 1'b1:1'b0; 
assign  FIFO_WE_tmp[4]	=(VACtrlState==LATCH_PACK_TRAILER)	? 1'b1:1'b0; 
assign  FIFO_WE_tmp[5]	=(VACtrlState==LATCH_STATUS)			? 1'b1:1'b0;          


always@(posedge clk_sys or negedge rstn)
begin
	if(!rstn)begin
		FIFO_WE_delay<=6'b0;
		end
	else begin
		FIFO_WE_delay<=FIFO_WE_tmp;
		end
end

assign FIFO_WE= (~FIFO_WE_delay[0] & FIFO_WE_tmp[0])
               |(~FIFO_WE_delay[1] & FIFO_WE_tmp[1])
					|(~FIFO_WE_delay[2] & FIFO_WE_tmp[2])
					|(~FIFO_WE_delay[3] & FIFO_WE_tmp[3])
					|(~FIFO_WE_delay[4] & FIFO_WE_tmp[4])
					|(~FIFO_WE_delay[5] & FIFO_WE_tmp[5]); // to get a single clock pulse (system clock, not divided clock for VA)
					

always@(posedge clk or negedge rstn)
begin
	if(!rstn)
	  ADC_nRC<=1'b1;
	else if(VACtrlState==ADC_CNVT)
	  ADC_nRC<=1'b0;
	else
	  ADC_nRC<=1'b1;
end

//assign  Data2RdoFifo=(VACtrlState==LATCH_DATA)?ADC_Data:((VACtrlState==LATCH_DATA_INFOR)?{2'b10,TrigID[5:0],1'b1,ChnIDCnt[6:0]}:16'b0);
always@(VACtrlState)
begin
  case(VACtrlState) /*synthesis parallel_case*/
	   //--------数据包头 共4字节    （2字节包头标识+2字节的触发号?刃畔???
 		 LATCH_PACK_HEADER      : Data2RdoFifo=16'b1010_1010_1010_1010;
		 LATCH_PACK_INFOR       : Data2RdoFifo={^TrigID[6:0],TrigID[6:0],8'b0000_0000};
		//--------数据包  每单元为4字节(2字节ADC数据 + 2字节信息)  
		 LATCH_DATA_INFOR       : Data2RdoFifo={^ChnIDCnt[6:0],ChnIDCnt[6:0],8'b0000_0000};
		 LATCH_DATA             : Data2RdoFifo={^ADC_Data[14:0],ADC_Data[14:0]};
		//--------数据包尾  共4字节    （1字?????识+1字节保??信??+2字节状态信息）
		 LATCH_PACK_TRAILER     : Data2RdoFifo=16'b1011_1011_1011_1011;
		 LATCH_STATUS           : Data2RdoFifo=16'b0000_0000_0000_0000; //??态??息，暂设为16'b0
       default                : Data2RdoFifo=16'b0000_0000_0000_0000;
   endcase
end

assign  VA_DReset=~rstn |(VACtrlState==IDLE); //在IDLE状态里，将芯片复位 （尤其是VA芯片内部的移位寄存器复位到初始状态）

assign  VA_Hold=VA_Hold_Reg; 
//assign  VA_Hold=1'b0;//临时测试用,某些情况下可用来观察shaper直接输出波形

assign  VAConvt_nBusy=(VACtrlState==IDLE)?1'b1:1'b0;

always@(*)
begin
	if(!rstn)
				 VACtrlState_Next=IDLE;
	else
		case(VACtrlState)  //state machine of VA-Ctrl
		  IDLE:  
		   begin
			    // if(!TrigEna)
				 //      VACtrlState_Next=IDLE;	
				 // else 
				  if(WorkMode==1'b1)   // cali-test   mode
				   	 VACtrlState_Next=CALI_SHIFTB_ASSERT;
				  else if(TrigDelayEndFlag)
				       VACtrlState_Next=NORMAL_HOLD_ASSERT;
				  else  							
				   	 VACtrlState_Next=IDLE;	
			 end  	  	
		      		
		  NORMAL_HOLD_ASSERT:   //0x
			   		 VACtrlState_Next=LATCH_PACK_HEADER;
		   
		  LATCH_PACK_HEADER:   // 将数据包头标志写入FIFO
		            VACtrlState_Next=LATCH_PACK_INFOR; 
		  
		  LATCH_PACK_INFOR:    // 将触发号信息写入FIFO
		            if(WorkMode==1'b1)
						   VACtrlState_Next=DELAY_FOR_CNVT;
		            else
						   VACtrlState_Next=NORMAL_SHIFTB_ASSERT;   
						   
		  NORMAL_SHIFTB_ASSERT: //0x
			   		 VACtrlState_Next=NORMAL_CKB_ASSERT;
	
		  NORMAL_CKB_ASSERT:    //0x
			   		 VACtrlState_Next=NORMAL_CHK_END;
	
		  NORMAL_CHK_END: 
		     begin  
					if(!VaShiftOutReg) //inverted after VA32, so this signal is high active
					    VACtrlState_Next=DELAY_FOR_CNVT;
					else
			   	    VACtrlState_Next=LATCH_PACK_TRAILER;  
			   end	
				
		  DELAY_FOR_CNVT:   //0x
			      if(ADCDelayCnt>=5'b1_0100)  //delay 1600ns for ADC conversion, to avoid noise and unsteablity
			   	      VACtrlState_Next=ADC_CNVT;
					  else
			   	    	VACtrlState_Next=DELAY_FOR_CNVT;
	    ADC_CNVT:        //0x
	       			if(!ADC_nBUSY)
	       				VACtrlState_Next=WAIT_DATA;
	       			else
	              VACtrlState_Next=ADC_CNVT;
	    WAIT_DATA:      //0x20
	       	    if(!nAdcBusyReg)
	       	      VACtrlState_Next=WAIT_DATA;
	       	    else
	               VACtrlState_Next=LATCH_DATA_INFOR;
		 LATCH_DATA_INFOR:
           		      VACtrlState_Next=LATCH_DATA;
	    LATCH_DATA:	 
	         begin
		          if(WorkMode==1'b1)
		       		   VACtrlState_Next=LATCH_PACK_TRAILER;
		       	  else
		       	      VACtrlState_Next=NORMAL_CKB_ASSERT;
	       	 end	  

       LATCH_PACK_TRAILER: 		 // 将??据包尾标志写??FIFO
		               VACtrlState_Next=LATCH_STATUS;
       LATCH_STATUS:		          // 将状态信息写入FIFO
		        if(WorkMode==1'b1)
		       		   VACtrlState_Next=CALI_WAIT_TRIG;
		        else
		       	      VACtrlState_Next=IDLE;	
		 
    //Calibration states:	       	 
	   CALI_SHIFTB_ASSERT:
	        VACtrlState_Next=CALI_CKB_ASSERT;
	         
	   CALI_CKB_ASSERT:
	        VACtrlState_Next=CALI_WAIT_TRIG;
	       
	   CALI_WAIT_TRIG:
	       if(ChnIDCnt!=CaliChnID)
	          VACtrlState_Next=CALI_CKB_ASSERT;
	       else if(TrigDelayEndFlag)
	          VACtrlState_Next=CALI_HOLD_ASSERT;
	       else if(WorkMode==1'b0)
			    VACtrlState_Next=IDLE;	  
			 else
	          VACtrlState_Next=CALI_WAIT_TRIG;
				 
	   CALI_HOLD_ASSERT:
		     VACtrlState_Next=LATCH_PACK_HEADER;
	        
       default: VACtrlState_Next=IDLE;	          
   	endcase
end

always@(posedge clk or negedge rstn)
begin 
    if(!rstn)
        TrigID<=7'b0;
	 else if(TrigAfterSync)
	     TrigID<=TrigID+7'b1;
end


always@(posedge clk or negedge rstn)
begin
	if(!rstn)begin
		VA_Hold_Reg<=1'b0;
		VA_Shiftb<=1'b1;
		VA_CKb<=1'b1;
		ChnIDCnt<=7'b0;
	 end
	else 
	 case(VACtrlState) /*synthesis parallel_case*/
	  IDLE: begin
	      VA_Hold_Reg<=1'b0;
		   VA_Shiftb<=1'b1;
		   VA_CKb<=1'b1;
			ChnIDCnt<=7'b0;
		  end
	  NORMAL_HOLD_ASSERT:
	     VA_Hold_Reg<=1'b1;
	   CALI_HOLD_ASSERT:
	     VA_Hold_Reg<=1'b1;
	 
	  NORMAL_SHIFTB_ASSERT:
	     VA_Shiftb<=1'b0;
		  
	  CALI_SHIFTB_ASSERT:
	     VA_Shiftb<=1'b0;
	  
	  CALI_CKB_ASSERT:
	     begin
		   ChnIDCnt<=ChnIDCnt+7'b1;
	      VA_CKb<=1'b0;
		  end
	  NORMAL_CKB_ASSERT:
	     begin
		    ChnIDCnt<=ChnIDCnt+7'b1;
	       VA_CKb<=1'b0;
		  end
		  
	  CALI_WAIT_TRIG:
	     begin
			VA_Hold_Reg<=1'b0;
			VA_CKb<=1'b1;
			VA_Shiftb<=1'b1;
	     end
	 
	  ADC_CNVT:
	    begin
	      VA_Shiftb<=1'b1;
	    end
		 
    WAIT_DATA:
	    begin
			VA_CKb<=1'b1;
		 end 
	  endcase  	
end
 
endmodule