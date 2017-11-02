//Module of AD7944 acquicision controller
//Actel FPGA Smartfusion2 M2S050 FG484
//University of Science and Technology of China
//By Siyuanma 2016.3.8  
//PS: the first ADC controller I write
//Description:
//The ADC is working in the mode of /CS 3-Wire Without Busy Indicator
//3 State during one circulation: 1.Conversion 2. Acquisition 3. Compensation
//Time of Conversion (Tconv) min is 420ns 
//Time of ACQ (Tacq) min is 80ns
//Time of compasition is no limited
module ADC_AD7944 (
  input               Clk, //50MHz
  input               Rst_N,
  input               Start_In, //Start ADC
  //Test Signal
  output              Tp,
  //IO 2 ADC 
  input               Sdo,
  output              Turb,
  output reg          CNV,
  output              Pdref,
  output              Sck,
  output  [15:0]      Data_Out,
  output reg          Data_Out_En,
  output reg          Out_Acq_End
//for testing, can be canceled after testing
 // output [1:0] State_Now
  

);
reg [15:0] Data_Out_Of_ADC;
//for testing
assign                Pdref = 1'b1; // External Ref
assign                Turb = 1'b0; //Normal mode
reg [5:0]             Cnt_Conv;             //CNV 's rising edge start the convertion. so need a delay State to wait for VA Output to be stable.
reg [7:0]             Cnt_Delay; 
localparam [5:0]      Tconv = 6'd30; //>420 ns is demanded by ADC mannul.(if clk = 20ns = 21Cyc)But total time of Acq one time is demanded by VA. If Want to Change speed Just modify  TCOMP
localparam [7:0]      Tdelay= 8'd70; //Wait 70*20 = 1.4us
localparam [7:0]      TCOMP = 8'd10;
reg [5:0]             Cnt_Acq;
reg [7:0]             Cnt_Comp;
reg [5:0]             Cnt_Sdo; //change bit for DataOut to assignment

reg Sck_En;

//define States
localparam [2:0 ] STATE_IDLE = 3'd0,
                  STATE_DELAY= 3'd1,
                  STATE_CONV = 3'd2,
                  STATE_ACQ  = 3'd3,
                  STATE_COMP = 3'd4;
reg [2:0] State;
//define Data_Width
localparam [4:0] DATA_WIDTH = 5'd14;


//assign State_Now = State;
always @ (posedge Clk , negedge Rst_N) 
begin
  if(~Rst_N)
  begin
    Data_Out_Of_ADC                 <= 16'd0;
    Data_Out_En                     <= 1'd0;
    CNV                             <= 1'b0;
    Cnt_Sdo                         <= 6'd0;
    Sck_En                          <= 1'b0;
    Cnt_Conv                        <= 6'd0;
    Cnt_Acq                         <= 6'd0;
    Cnt_Comp                        <= 8'd0;
    State                           <= STATE_IDLE;
    Out_Acq_End                     <= 1'b0;
  end
  else 
  begin           //40+1+13+1+80+1 =  136*20 = 2720ns 
    case(State)
      STATE_IDLE:
        begin
           Data_Out_Of_ADC          <= 16'd0;
           Data_Out_En              <= 1'd0;
           CNV                      <= 1'b0;
           Cnt_Sdo                  <= 6'd0;
           Sck_En                   <= 1'b0;
           Cnt_Conv                 <= 6'd0;
           Cnt_Acq                  <= 6'd0;
           Cnt_Comp                 <= 8'd0;
           Out_Acq_End              <= 1'b0;
           Cnt_Delay                <= 8'd0;
           if(Start_In)
             begin
               State                  <=  STATE_DELAY;
             end  
           else
             begin
               State                  <=  STATE_IDLE;
             end  
        end  
      STATE_DELAY:
        begin
          if(Cnt_Delay        ==      Tdelay - 1'b1)
            begin
              State                 <=  STATE_CONV;
              Cnt_Delay             <=  8'd0;
              CNV                   <=  1'b1;
            end
          else
            begin
              State                 <=  STATE_DELAY;
              Cnt_Delay             <=  Cnt_Delay   +   1'b1;
              CNV                   <=  1'b0;
            end  
        end   
      STATE_CONV:  // 40
       begin
          
          if(Cnt_Conv < Tconv )
            begin
              State                     <= STATE_CONV;
              Cnt_Conv                  <= Cnt_Conv + 1'b1;
            end
          else 
             begin
              Cnt_Conv                  <= 6'd0;
              CNV                       <= 1'b0;
              Sck_En                    <= 1'b1;
              State                     <= STATE_ACQ; //1
             end
      end
      STATE_ACQ:
      begin
        Data_Out_Of_ADC[DATA_WIDTH - 1 - Cnt_Sdo] <= Sdo; //13
        if(Cnt_Sdo < DATA_WIDTH - 1)
        begin
          Cnt_Sdo                        <=  Cnt_Sdo + 1'b1;
          State                          <= STATE_ACQ;
        end
        else
        begin
          Cnt_Sdo                        <= 6'd0;   //1
          Data_Out_En                    <= 1'b1;
          Sck_En                         <= 1'b0;
          State                          <= STATE_COMP;
        end
      end
      STATE_COMP:    //10
      begin
        Data_Out_En                      <= 1'b0;
        if(Cnt_Comp < TCOMP)   
        begin
          Cnt_Comp                       <= Cnt_Comp + 1'b1;
          State                          <= STATE_COMP;
        end
        else
        begin     //1
          Cnt_Comp                       <= 8'd0;
          CNV                            <= 1'b0;
          Out_Acq_End                    <= 1'b1;
          State                          <= STATE_IDLE;
        end
      end
        default:State                    <= STATE_IDLE;
    endcase
  end
end
assign Sck = ~Clk & Sck_En; //define Sck. Enabled when En = 1 and reverse to Clk SCK is valid of negedge
assign Tp = Data_Out_En;
assign Data_Out[7:0] = Data_Out_Of_ADC[15:8];//Change the order of SCI data, because USB will change the order
assign Data_Out[15:8]= Data_Out_Of_ADC[7:0];
endmodule
