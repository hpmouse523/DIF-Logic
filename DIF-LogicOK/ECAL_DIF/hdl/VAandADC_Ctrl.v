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
`define	CaliChnID	 8'b0010_0000   //from 0 to 31

module VAandADControl(
       clk_sys,rstn,
		 WorkMode,
       Trig,
		 VA_Hold,VA_Shiftb,VA_CKb,ShiftOutFrmVA,VA_TestOn,
		 VA_CaliStart,VA_DReset,
       ADC_CSn,ADC_nRC,ADC_nBUSY,
		 ADC_Data,Data2RdoFifo, 
       FIFO_WE,  //FIFO write enable (to store ADC data)
		 CaliShifttoVA,CaliCkb,
		 VAConvt_nBusy
);

input  clk_sys,rstn;
input  WorkMode;// 0:normal mode; 1:cali mode

output VA_Hold,VA_Shiftb,VA_CKb,VA_TestOn; //VA32 Control
output VA_CaliStart,VA_DReset;
//assign VA_TestOn=1'b1;     //in test mode
assign VA_TestOn=1'b0;     // not in test mode
assign VA_CaliStart=1'b0;  //not in test mode, so the cali signal is not needed;
reg VA_Hold_Normal,VA_Shiftb,VA_CKb;

input ShiftOutFrmVA;
input Trig; // 高电平有效

output ADC_CSn,ADC_nRC;
assign ADC_CSn=1'b0;

output FIFO_WE;
reg ADC_nRC_tmp;
reg ADC_nRC;

input ADC_nBUSY;
input[15:0] ADC_Data;
output[15:0] Data2RdoFifo;
reg[7:0]  ChnID; 
reg[7:0]  TrigID;

output  CaliShifttoVA,CaliCkb;
reg CaliShifttoVA,CaliCkb,CaliHold;

wire TrigAfterSync;

output VAConvt_nBusy;


reg[2:0] clkCnt;
wire clk=clkCnt[1]; //4分频,由50M 变为12.5M Hz
always@(posedge clk_sys)
begin
  if(!rstn)
    clkCnt<=3'b0;
  else
    clkCnt<=clkCnt+3'b001;
end

SynchExt2Clk SynchExtTrig2Clk(.Clk(clk), .nReset(rstn), .AsyIn(Trig), .SynchOut(TrigAfterSync));

reg[12:0]  VACtrlSate,VACtrlSate_Next;


parameter
          IDLE           = 13'b1_0000_0000_0000, 
          DelayforHold =   13'b0000_0000_0001,
          VAHold_Assert =  13'b0000_0000_0010,
          VAShiftb_Assert= 13'b0000_0000_0100,
          VACkb_Assert=    13'b0000_0000_1000,
          ADCCnvt_Assert=  13'b0000_0001_0000,
          WaitforDATA=     13'b0000_0010_0000,
          LatchData=       13'b0000_0100_0000,
			 LatchDataInfo=   13'b0000_1000_0000,
          CheckEnd=        13'b0001_0000_0000,
          CKb_Dissert=     13'b0010_0000_0000,
			 Tmp_TestWait=    13'b0100_0000_0000, //tmo test,to observe singal from shaper, should be  later 
			 DelayforCnvt=    13'b1000_0000_0000;
			 
reg[23:0] ADCDelayEndReg;

always@(posedge clk or negedge rstn)
begin
	if(!rstn)begin
		ADCDelayEndReg<=24'b0;
		end
	else begin
		ADCDelayEndReg<={ADCDelayEndReg[22:0],~VA_CKb};
		end
end

reg[7:0] TrigDelayReg;
wire dffrst_tmp=!rstn|TrigAfterSync;
always@(posedge clk or posedge dffrst_tmp)
begin
	if(dffrst_tmp)
	  TrigDelayReg<=8'b0;
	else 
	if(TrigDelayReg==8'b1111_1111)
	  TrigDelayReg<=TrigDelayReg;
	else
	  TrigDelayReg<=TrigDelayReg+1;
end

wire  DelayEndFlag=(TrigDelayReg==8'b0001_0000); //hold delay~=500ns+16*80ns
			 
always@(posedge clk or negedge rstn)
begin
	if(!rstn)
		VACtrlSate<=IDLE;
	else
		VACtrlSate<=VACtrlSate_Next;
end

wire  Infor_WE_tmp=(VACtrlSate==LatchDataInfo)?1:0;
wire  Data_WE_tmp=(VACtrlSate==LatchData)?1:0;

reg   Infor_WE_delay,Data_WE_delay;
always@(posedge clk_sys or negedge rstn)
begin
	if(!rstn)begin
		Infor_WE_delay<=1'b0;
		Data_WE_delay<=1'b0;
		end
	else begin
		Infor_WE_delay<=Infor_WE_tmp;
		Data_WE_delay<=Data_WE_tmp;
		end
end
assign FIFO_WE=((~Infor_WE_delay)&Infor_WE_tmp)|((~Data_WE_delay)&Data_WE_tmp); // to get a single clock pulse

assign  VA_DReset=~rstn |(VACtrlSate==IDLE);
assign  Data2RdoFifo=(VACtrlSate==LatchData)?ADC_Data:((VACtrlSate==LatchDataInfo)?{2'b10,TrigID[5:0],1'b1,ChnID[6:0]}:16'b0);
assign  VA_Hold=VA_Hold_Normal; //normal use
//assign  VA_Hold=1'b0;//for test 临时测试用,用?垂鄄?shaper output
assign  VAConvt_nBusy=(VACtrlSate==IDLE)?1'b1:1'b0;
always@(rstn or DelayEndFlag or ShiftOutFrmVA or TrigAfterSync or ADC_nBUSY or VACtrlSate)
begin
	if(!rstn)
					VACtrlSate_Next=IDLE;
	else
		case(VACtrlSate)  //state machine of normal-mode
		  IDLE:    //00 
				if(TrigAfterSync)   //normal test   
			   	  	VACtrlSate_Next=DelayforHold;
			   else
			   	   VACtrlSate_Next=IDLE;	
			   	  	
		  DelayforHold: //delay 1.8us  //01  
			    
			   if(DelayEndFlag)
			   	  	VACtrlSate_Next=VAHold_Assert;
			   else
			      	VACtrlSate_Next=DelayforHold;	
		      		
		  VAHold_Assert:  //0x02  
			   			VACtrlSate_Next=VAShiftb_Assert;
		
		  VAShiftb_Assert: //0x04
			   			VACtrlSate_Next=VACkb_Assert;
	
		  VACkb_Assert://0x08
			   			VACtrlSate_Next=CheckEnd;
	
		  CheckEnd:   //0x80	 
              //   if(ChnID==8'b0101_0000)
				  //           VACtrlSate_Next<=Tmp_TestWait;  // test mode, stop ckb in a certain channel, to observe signal from its shaper,    	
			     //	  else
					if(!ShiftOutFrmVA) //由于VA输出的ShiftOut信号已经过反相,因???眯藕盼叩???????VA的?ǖ酪莆灰呀崾?低电平,则??明仍在变换??			         	VACtrlSate_Next=DelayforCnvt;
					     VACtrlSate_Next=DelayforCnvt;
					else
			   	    VACtrlSate_Next=CKb_Dissert;
		  DelayforCnvt:   //0x800
			        if(ADCDelayEndReg[20])  //delay 1600ns for ADC conversion 在信号稳定后进行?浠?			   	    	VACtrlSate_Next=ADCCnvt_Assert;
			   	      VACtrlSate_Next=ADCCnvt_Assert;
					  else
			   	    	VACtrlSate_Next=DelayforCnvt;
	     ADCCnvt_Assert:   //0x10
	       			if(!ADC_nBUSY)
	       				VACtrlSate_Next=WaitforDATA;
	       			else
	              VACtrlSate_Next=ADCCnvt_Assert;
	
	     WaitforDATA:   //0x20
	       	    if(!ADC_nBUSY)
	       	      VACtrlSate_Next=WaitforDATA;
	       	    else
	               VACtrlSate_Next=LatchDataInfo;
		  LatchDataInfo:
           		      VACtrlSate_Next=LatchData;
	     LatchData:	 //0x40
	       				VACtrlSate_Next=VACkb_Assert;
	     CKb_Dissert:  VACtrlSate_Next=IDLE;
        default: VACtrlSate_Next=IDLE;	          
   	endcase
end

always@(posedge clk or negedge rstn)
begin 
    if(!rstn)
        TrigID<=8'b0;
	 else if(TrigAfterSync)
	     TrigID<=TrigID+1;
end

always@(posedge clk or negedge rstn)
begin
	if(!rstn)begin
		VA_Hold_Normal<=1'b0;
		VA_Shiftb<=1'b1;
		VA_CKb<=1'b1;
		ChnID<=8'b0;
	 end
	else 
	 case(VACtrlSate)
	  IDLE: begin
		   VA_Hold_Normal<=1'b0;
		   VA_Shiftb<=1'b1;
		   VA_CKb<=1'b1;
			ChnID<=8'b0;
		  end
	  VAHold_Assert:
	     VA_Hold_Normal<=1'b1;
	  VAShiftb_Assert:
	     VA_Shiftb<=1'b0;
	  VACkb_Assert:
	     VA_CKb<=1'b0;
	  ADCCnvt_Assert:begin
	     VA_CKb<=1'b1;
	     VA_Shiftb<=1'b1;
	    end
	  CKb_Dissert:
       VA_CKb<=1'b1;
	  LatchDataInfo: 
		 ChnID<=ChnID+1;
	  endcase  	
end

//delay ADC_Cvt for 160ns (2 clock)
always@(posedge clk or negedge rstn)
begin
	if(!rstn)
	  ADC_nRC_tmp<=1'b1;
	else 
	if(VACtrlSate==ADCCnvt_Assert)
	  ADC_nRC_tmp<=1'b0;
	else
	  ADC_nRC_tmp<=1'b1;
end

always@(posedge clk or negedge rstn)
begin
	if(!rstn)
	  ADC_nRC<=1'b1;
	else 
	  ADC_nRC<=ADC_nRC_tmp;
end

//**************************state machine of calibration control
reg[4:0]  VACaliSate,VACaliSate_Next;
parameter CALI_IDLE       =5'b0_0000,
          CALI_ShiftAssert=5'b0_0001,
			 CALI_CKBAssert  =5'b0_0010,
			 CALI_CKBWait    =5'b0_0100,
			 CALI_CKBDissert =5'b0_1000,
			 CALI_ForHold    =5'b1_0000;  			 
reg[7:0] CaliChnNumCnt;

always@(posedge clk or negedge rstn)
begin
	if(!rstn)
		VACaliSate<=CALI_IDLE;
	else
		VACaliSate<=VACaliSate_Next;
end

always@(rstn or VACaliSate)
begin
	if(!rstn)
	  VACaliSate_Next<=CALI_IDLE;
	else
	 case(VACaliSate)
	 CALI_IDLE:
	  //  VACaliSate_Next<=CALI_ShiftAssert; //刻度工作模式
	      VACaliSate_Next<=CALI_IDLE; //正常工作模??
	 CALI_ShiftAssert:
	    VACaliSate_Next<=CALI_CKBAssert;
	 CALI_CKBAssert:
	 	 if(CaliChnNumCnt==`CaliChnID)
		   VACaliSate_Next<=CALI_ForHold;
	    else
	      VACaliSate_Next<=CALI_CKBWait;
    CALI_CKBWait:
	    VACaliSate_Next<=CALI_CKBDissert;
	 CALI_CKBDissert:
	     VACaliSate_Next<=CALI_CKBAssert;
	 CALI_ForHold:
	     VACaliSate_Next<=CALI_ForHold;
	  endcase
end

always@(posedge clk or negedge rstn)
begin
	if(!rstn)
		CaliChnNumCnt<=8'b0;
	else if(VACaliSate==CALI_CKBWait)
		CaliChnNumCnt<=CaliChnNumCnt+1;
end

always@(posedge clk or negedge rstn)
begin
	if(!rstn)begin
	  CaliShifttoVA<=1'b1;
	  CaliCkb<=1'b1;
	//CaliHold<=1'b0; //刻度工作模式
	  CaliHold<=1'b1;   //正常工作模式
	  end
	else
	  case(VACaliSate)
	  CALI_ShiftAssert:
	     CaliShifttoVA<=1'b0;
	  CALI_CKBAssert:
	     CaliCkb<=1'b0;
	  CALI_CKBDissert:begin
	     CaliCkb<=1'b1;
		  CaliShifttoVA<=1'b1;
		  end	
     CALI_ForHold:begin
	     	if(TrigDelayReg==8'b0001_0010)
		     CaliHold<=1'b1;
			else if(TrigDelayReg==8'b1111_1100)
			  CaliHold<=1'b0;
        CaliCkb<=1'b1;
         end		  
	  endcase	  
end

			    
endmodule 