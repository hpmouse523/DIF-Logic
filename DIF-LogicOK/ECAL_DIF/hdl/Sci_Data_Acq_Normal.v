
//ADC Controller to Generate all four ADCs data then thransfer to USB Ex fifo
//Control VA signals to acquire data of all channel

module Sci_Data_Acq_Normal( 
  input         Clk,
  input         Rst_N,
  input         Acq_Start_Stop_In,

/*IO of Control command*/
  input [11:0]  In_Set_Hold_Delay_Time,
  input         In_Sel_Work_Mode,
  //IO of Trig Module
  input         Trig_In,

  //IO of ADC
  input [4:1]   Sdo,
  output        Pdref,
  output        CNV,
  output        Turb,
  output        Sck,
  output [1:0]  Tp,

  //IO of VATA160
  output reg [4:1]  Out_Shift_In_N_VA,
  
  output reg    Out_Ckb_N_VA,
  output reg    Out_Hold_VA,
  output reg    Out_Dreset_VA,

  //IO for simulation
  output [7:0]  Out_Cnt_of_En_1,

  //IO 2 Exfifo
  output [15:0] Data_Out_2_Exfifo,
  input         Data_Rd_of_Ge_Fifo_En,
  output        Ge_Fifo_Empty

);
/////////////////////////
//for ADC and Fifo module


wire [15:0] Data_Out_2_Fifo_1;
wire [15:0] Data_Out_2_Fifo_2;
wire [15:0] Data_Out_2_Fifo_3;
wire [15:0] Data_Out_2_Fifo_4;
wire        Data_Out_En_2_Fifo_1;
wire        Data_Out_En_2_Fifo_2;
wire        Data_Out_En_2_Fifo_3;
wire        Data_Out_En_2_Fifo_4;
wire        Acq_End_Sig;
reg         Acq_End_Sig_Delay1;
reg         Acq_End_Sig_Delay2;


wire [15:0] Data_Out_2_Ge_Fifo_1;
wire [15:0] Data_Out_2_Ge_Fifo_2;
wire [15:0] Data_Out_2_Ge_Fifo_3;
wire [15:0] Data_Out_2_Ge_Fifo_4;

reg         Adc_Fifo_Rd_1;
reg         Adc_Fifo_Rd_2;
reg         Adc_Fifo_Rd_3;
reg         Adc_Fifo_Rd_4;

wire        Adc_Fifo_Empty_1;
wire        Adc_Fifo_Empty_2;
wire        Adc_Fifo_Empty_3;
wire        Adc_Fifo_Empty_4;
wire        Adc_Fifo_Full_1;
wire        Adc_Fifo_Full_2;
wire        Adc_Fifo_Full_3;
wire        Adc_Fifo_Full_4;

/////////////////////////





/////////////////////////
reg             Start_Converting_Sig;   //for ADC module to start acquisition
//
reg             Data_Wr_of_Ge_Fifo_En;
reg             Data_Wr_of_Ge_Fifo_En_Delay;
reg [15:0]      Data_In_2_Ge_Fifo;
reg [15:0]      Data_Start;

localparam [1:0] STATE_IDLE   = 2'b00;
localparam [1:0] STATE_START  = 2'b01;
localparam [1:0] STATE_PROCESS= 2'b10;
localparam [1:0] STATE_END    = 2'b11;
reg [1:0] State               = STATE_IDLE;

localparam [5:0] TOTAL_LENGTH_START = 6'd2; //length of Start words
localparam [5:0] FIRST_WORD = 6'd0;
localparam [5:0] SECOND_WORD = 6'd1;
reg [5:0]           Cnt_Length_Start;

reg [4:0]           Data_Choose_2_Ge_Fifo;
/////////////////////////
reg [7:0]           Cnt_Data_En_1;
reg                 Data_Out_En_2_Fifo_1_Delay1, 
                    Data_Out_En_2_Fifo_1_Delay2;
localparam [7:0] TOTAL_DATA_NUM = 8'd32;  //The number of Channel of every VATA160    not used in VA control process
//////////////
reg Trig_In_Delay1, Trig_In_Delay2;
///////////

/*VA Control States*/
localparam [3:0]    VA_IDLE                 = 4'd0;
localparam [3:0]    VA_DELAY_FOR_HOLD       = 4'd1;
localparam [3:0]    VA_SEND_HOLD            = 4'd2;
localparam [3:0]    VA_SEND_SHIFTIN         = 4'd3;
localparam [3:0]    VA_SEND_CKB             = 4'd4;
localparam [3:0]    VA_START_CONVERTING     = 4'd5;
localparam [3:0]    VA_WAIT_FOR_DATA        = 4'd6,
                    VA_SEND_DRESET          = 4'd7;

reg [3:0]           VA_State;
reg [3:0]           VA_State_Next;

reg                 Hold_End_Sig;
reg [11:0]          Cnt_Hold;         //resolution = 20ns(50MHz)  range is 0-1000 which means delay hold time 0- 20us
reg [11:0]          Cnt_Ckb_Delay;    //Used to make Ckb signal last at least 200ns  10 cycles

reg                 VA_Get_End;


////////////////////////////////////////////Cnt 32 num of ADCData_Out////////////
always @ (posedge Clk or negedge Rst_N) // for tell rising edge of Data_En
begin
  if(~Rst_N)
  begin
    Data_Out_En_2_Fifo_1_Delay1 <= 1'b0;
    Data_Out_En_2_Fifo_1_Delay2 <= 1'b0;
    Acq_End_Sig_Delay1          <= 1'b0;
    Acq_End_Sig_Delay2          <= 1'b0;
  end
  else 
  begin
    Acq_End_Sig_Delay1          <= Acq_End_Sig;
    Acq_End_Sig_Delay2          <= Acq_End_Sig_Delay1;
    Data_Out_En_2_Fifo_1_Delay1 <= Data_Out_En_2_Fifo_1;
    Data_Out_En_2_Fifo_1_Delay2 <= Data_Out_En_2_Fifo_1_Delay1;
  end
end

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
    Cnt_Data_En_1 <= 8'd0;
  end
  else if(Data_Out_En_2_Fifo_1_Delay1 && !Data_Out_En_2_Fifo_1_Delay2)
  begin
    Cnt_Data_En_1 <= Cnt_Data_En_1 + 1'b1;
  end
  else if(Cnt_Data_En_1 == TOTAL_DATA_NUM  && VA_Get_End)
  begin
    Cnt_Data_En_1 <= 8'd0;
  end
  else
  begin
    Cnt_Data_En_1 <= Cnt_Data_En_1;
  end
end
/////////////////////////////////////////////////
/*Cnt Hold delay signal*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Cnt_Hold              <=  12'd0;
    end
  else if(Cnt_Hold    ==  In_Set_Hold_Delay_Time)
    begin
      Cnt_Hold              <=  12'd0;
    end
  else if(VA_State_Next    ==  VA_DELAY_FOR_HOLD)
    begin
      Cnt_Hold              <=  Cnt_Hold    + 1'b1;
    end
  else
    begin
      Cnt_Hold              <=  12'd0;
    end
    
    

end
//
always @ (posedge Clk or negedge Rst_N) //Trig_Delay is used for starting VA shift process
begin
  if(~Rst_N)
  begin
    Trig_In_Delay1 <= 1'b0;
    Trig_In_Delay2 <= 1'b0;
  end
  else 
  begin
    Trig_In_Delay1 <= Trig_In;
    Trig_In_Delay2 <= Trig_In_Delay1;
  end
end



/*Put fifo 2 Ge Fifo and change the order, cause USB auto change the order
* again*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
   Data_In_2_Ge_Fifo <= 16'b0;
  end
  else
  begin
    case(Data_Choose_2_Ge_Fifo)
    5'b1_0000:
    begin
      Data_In_2_Ge_Fifo[15:8] <= Data_Start[7:0];
      Data_In_2_Ge_Fifo[7:0]  <= Data_Start[15:8];
    end
    5'b0_0001:
    begin
      Data_In_2_Ge_Fifo[15:8] <= Data_Out_2_Ge_Fifo_1[15:8];//SCI data has already been changed the order
      Data_In_2_Ge_Fifo[7:0]  <= Data_Out_2_Ge_Fifo_1[7:0];
    end
    5'b0_0010:
    begin
      Data_In_2_Ge_Fifo[15:8] <= Data_Out_2_Ge_Fifo_2[15:8];
      Data_In_2_Ge_Fifo[7:0]  <= Data_Out_2_Ge_Fifo_2[7:0];
    end

    5'b0_0100:
    begin
      Data_In_2_Ge_Fifo[15:8] <= Data_Out_2_Ge_Fifo_3[15:8];
      Data_In_2_Ge_Fifo[7:0]  <= Data_Out_2_Ge_Fifo_3[7:0];
    end

    5'b0_1000:
    begin
      Data_In_2_Ge_Fifo[15:8] <= Data_Out_2_Ge_Fifo_4[15:8];
      Data_In_2_Ge_Fifo[7:0]  <= Data_Out_2_Ge_Fifo_4[7:0];
    end

    5'b0_0000:
      Data_In_2_Ge_Fifo <= 16'h0000;
    default:
      Data_In_2_Ge_Fifo <= 16'h0000;

    endcase
  end
end
/*Wr need a delay, cause Data_In_2_Ge_Fifo has been delayed*/
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
   Data_Wr_of_Ge_Fifo_En_Delay <= 1'b0; 
  end
  else 
    Data_Wr_of_Ge_Fifo_En_Delay<= Data_Wr_of_Ge_Fifo_En;
end

/*Write Adc fifo to Ge fifo*/

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
  begin
    State                 <= STATE_IDLE;
    Cnt_Length_Start      <= 6'd0;
    Data_Wr_of_Ge_Fifo_En <= 1'b0;
    Adc_Fifo_Rd_1         <= 1'b0;
    Adc_Fifo_Rd_2         <= 1'b0;
    Adc_Fifo_Rd_3         <= 1'b0;
    Adc_Fifo_Rd_4         <= 1'b0;
    Data_Choose_2_Ge_Fifo <= 5'd0;
    Data_Start            <= 16'h0000;
  end
  else
  begin
    case(State)
      STATE_IDLE:                           //all control signals : State ;  Data_Choose_2_Ge_Fifo ; Data_Wr_of_Ge_Fifo_En ; Adc_Fifo_Rd_1 ; Cnt_Length_Start ; Data_Start ; Every signal must be Controlled at least twice in a State Cycle;
      begin
        if( Cnt_Data_En_1 == TOTAL_DATA_NUM && VA_Get_End )
        begin
          State                 <= STATE_START;
          Data_Choose_2_Ge_Fifo <= 5'b1_0000;
        end
        else 
        begin
          State <= STATE_IDLE;
          Data_Choose_2_Ge_Fifo <= 5'd0;
          Data_Wr_of_Ge_Fifo_En <= 1'b0;
          Adc_Fifo_Rd_1         <= 1'b0;
          Adc_Fifo_Rd_2         <= 1'b0;
          Adc_Fifo_Rd_3         <= 1'b0;
          Adc_Fifo_Rd_4         <= 1'b0;
          Data_Start            <= 16'h0000;
        end
      end

      STATE_START:   /*to pack the data, I need a start as "55aa eb90"*/
      begin
        if(Cnt_Length_Start == TOTAL_LENGTH_START)
        begin
          State                 <= STATE_PROCESS;
          Data_Choose_2_Ge_Fifo <= 5'b0_0001;
          Data_Wr_of_Ge_Fifo_En <= 1'b1;
          Adc_Fifo_Rd_1         <= 1'b1;
          Cnt_Length_Start      <= 1'b0;
        end
        else
        begin
          State                 <= STATE_START;

          case(Cnt_Length_Start)       //Length of Data_Wr_of_Ge_Fifo_En = 1 + 1 + 1 + Datalength-1 + 1 + 1 =  9  * 20 = 180ns  actual = 140 ns  if first, then 160ns
            FIRST_WORD:
            begin
              Data_Start            <= 16'h55aa;
              Data_Wr_of_Ge_Fifo_En <= 1'b1;
              Cnt_Length_Start      <= Cnt_Length_Start + 1'b1;
            end
            SECOND_WORD:
            begin
              Data_Start            <= 16'heb90;
              Data_Wr_of_Ge_Fifo_En <= 1'b1;
              Cnt_Length_Start      <= Cnt_Length_Start + 1'b1;
              
            end
          endcase
        end
      end
      STATE_PROCESS:
      begin
        if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && Adc_Fifo_Empty_3 && Adc_Fifo_Empty_4 )
        begin
          State                 <= STATE_END;
          Data_Wr_of_Ge_Fifo_En <= 1'b1; /*shows the end of the data as "5aa5"*/
          Data_Start            <= 16'h5aa5;
          Adc_Fifo_Rd_1         <= 1'b0;
          Adc_Fifo_Rd_2         <= 1'b0;
          Adc_Fifo_Rd_3         <= 1'b0;
          Adc_Fifo_Rd_4         <= 1'b0;
          Data_Choose_2_Ge_Fifo <= 5'b1_0000;
        end
        else
        begin
          if(Adc_Fifo_Empty_1 && ~Adc_Fifo_Empty_2 && ~Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_2           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0010;
            end
          else if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && ~Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_3           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0100;
            end
          else if(Adc_Fifo_Empty_1 && Adc_Fifo_Empty_2 && Adc_Fifo_Empty_3 && ~Adc_Fifo_Empty_4)
            begin
              Adc_Fifo_Rd_4           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_1000;
            end
          else
            begin
              Adc_Fifo_Rd_1           <= 1'b1;
              Data_Choose_2_Ge_Fifo   <= 5'b0_0001;
            end
        end
      end
      STATE_END:
      begin
        Data_Wr_of_Ge_Fifo_En <= 1'b1;
        State                 <= STATE_IDLE;
      end
      default:State           <= STATE_IDLE;
    endcase 
  
  end

end


/*Control VA to acquire Data*/

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      VA_State              <=  VA_IDLE;
    end
  else
    begin
      VA_State              <=  VA_State_Next;
    end
end

always @ (*)
begin
  if(~Rst_N)
    begin
      VA_State_Next                     =   VA_IDLE;

      
    end
  else
    begin
      VA_State_Next                     =   VA_IDLE;
      case(VA_State)
        VA_IDLE:
          begin
            if(In_Sel_Work_Mode)
              begin
                VA_State_Next           =   VA_IDLE;
              end  
            else if(!Trig_In_Delay2 &&  Trig_In_Delay1)
              begin
                VA_State_Next           =   VA_DELAY_FOR_HOLD;
              end
            else
              begin
                VA_State_Next           =   VA_IDLE;
              end
          end
        VA_DELAY_FOR_HOLD:
          begin
            if(Cnt_Hold == In_Set_Hold_Delay_Time)
              begin
                VA_State_Next           =   VA_SEND_HOLD;
              end
            else
              begin
                VA_State_Next           =   VA_DELAY_FOR_HOLD;
              end
          end
        VA_SEND_HOLD:
          begin
                VA_State_Next           =   VA_SEND_SHIFTIN;
          end
        VA_SEND_SHIFTIN:
          begin
                VA_State_Next           =   VA_SEND_CKB;
          end
        VA_SEND_CKB:
          begin
            if(Cnt_Ckb_Delay    < 12'd9)
              begin
                VA_State_Next           =   VA_SEND_CKB;
              end
            else
              begin
                  if(Cnt_Data_En_1 == TOTAL_DATA_NUM)
                    begin
                      VA_State_Next     =   VA_SEND_DRESET;
                    end
                  else
                    begin
                      VA_State_Next     =   VA_START_CONVERTING;

                
                    end
              end
          end
        VA_SEND_DRESET:
          begin
            VA_State_Next               =   VA_IDLE;
          end   
        VA_START_CONVERTING:
          begin
                VA_State_Next           =   VA_WAIT_FOR_DATA;
          end   
        VA_WAIT_FOR_DATA:
          begin
            if(Acq_End_Sig_Delay1 && !Acq_End_Sig_Delay2) 
              begin
                VA_State_Next           =   VA_SEND_CKB;
              end
            else
              begin
                VA_State_Next           =   VA_WAIT_FOR_DATA;
              end
          end
            default: VA_State_Next      =   VA_IDLE;
      endcase

    end
end

always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Out_Shift_In_N_VA                 <=  4'hf;
      Out_Ckb_N_VA                      <=  1'b1;
      Out_Hold_VA                       <=  1'b0;
      Out_Dreset_VA                     <=  1'b1;
      Start_Converting_Sig              <=  1'b0;
            VA_Get_End                  <=  1'b1;
      Cnt_Ckb_Delay                     <=  12'd0;
      
    end
  else
    begin
      case(VA_State)
        VA_IDLE:
          begin
            Out_Shift_In_N_VA                 <=  4'hf;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Hold_VA                     <=  1'b0;
            Out_Dreset_VA                     <=  1'b0;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b1;
            Cnt_Ckb_Delay                     <=  12'd0;
          end
        VA_SEND_DRESET:
          begin
            Out_Shift_In_N_VA                 <=  4'hf;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Hold_VA                       <=  1'b0;
            Out_Dreset_VA                     <=  1'b1;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b1;
            Cnt_Ckb_Delay                     <=  12'd0;
          end   
        VA_DELAY_FOR_HOLD:
          begin
            Out_Shift_In_N_VA                 <=  4'hf;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Hold_VA                     <=  1'b0;
            Out_Dreset_VA                     <=  1'b0;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
         
          end
        VA_SEND_HOLD:
          begin
            Out_Hold_VA                     <=  1'b1;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Shift_In_N_VA                 <=  4'hf;
            Out_Dreset_VA                     <=  1'b0;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
          end
        VA_SEND_SHIFTIN:
          begin
            Out_Hold_VA                     <=  1'b1;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Shift_In_N_VA                 <=  4'h0;
            Out_Dreset_VA                     <=  1'b0;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
          end
        VA_SEND_CKB:
          begin
            Out_Hold_VA                     <=  1'b1;
            Out_Ckb_N_VA                      <=  1'b0;
            Out_Shift_In_N_VA                 <=  Out_Shift_In_N_VA;
            Out_Dreset_VA                     <=  1'b0;
            Start_Converting_Sig              <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Cnt_Ckb_Delay                     <=  Cnt_Ckb_Delay + 1'b1;
          end  
        VA_START_CONVERTING://Output rate < 500kHz which means the reading time >2us. Since cyc = 20 ns  so one channel's converting and acquisition > 100 cyc
          begin
            Start_Converting_Sig              <=  1'b1;
            Out_Hold_VA                     <=  1'b1;
            Out_Ckb_N_VA                      <=  1'b0;
            Out_Shift_In_N_VA                 <=  Out_Shift_In_N_VA;
            Out_Dreset_VA                     <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
          end
        VA_WAIT_FOR_DATA:
          begin
            Start_Converting_Sig              <=  1'b0;
            Out_Hold_VA                     <=  1'b1;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Shift_In_N_VA                 <=  4'hf;
            VA_Get_End                        <=  1'b0;
            Out_Dreset_VA                     <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
          end  
        default:
          begin
            Out_Shift_In_N_VA                 <=  4'hf;
            Out_Ckb_N_VA                      <=  1'b1;
            Out_Hold_VA                     <=  1'b0;
            VA_Get_End                        <=  1'b0;
            Out_Dreset_VA                     <=  1'b1;
            Start_Converting_Sig              <=  1'b0;
            Cnt_Ckb_Delay                     <=  12'd0;
          end
      endcase
    end
end



/*General Fifo to generate 4 ADC Fifos' data*/

Adc_Ge_Fifo Adc_Ge_Fifo_Inst(
    // Inputs
    .DATA(Data_In_2_Ge_Fifo),
    .RCLOCK(Clk),
    .RE(Data_Rd_of_Ge_Fifo_En),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Wr_of_Ge_Fifo_En_Delay),
    // Outputs
    .EMPTY(Ge_Fifo_Empty),
    .FULL(),
    .Q(Data_Out_2_Exfifo)
);

/*ADC Fifo to accept ADC's Data*/
Adc_Fifo Adc_Fifo_1(
    // Inputs
    .DATA(Data_Out_2_Fifo_1),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_1),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_1),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_1),
    .FULL(Adc_Fifo_Full_1),
    .Q(Data_Out_2_Ge_Fifo_1)
);
Adc_Fifo Adc_Fifo_2(
    // Inputs
    .DATA(Data_Out_2_Fifo_2),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_2),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_2),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_2),
    .FULL(Adc_Fifo_Full_2),
    .Q(Data_Out_2_Ge_Fifo_2)
);
Adc_Fifo Adc_Fifo_3(
    // Inputs
    .DATA(Data_Out_2_Fifo_3),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_3),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_3),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_3),
    .FULL(Adc_Fifo_Full_3),
    .Q(Data_Out_2_Ge_Fifo_3)
);
Adc_Fifo Adc_Fifo_4(
    // Inputs
    .DATA(Data_Out_2_Fifo_4),
    .RCLOCK(Clk),
    .RE(Adc_Fifo_Rd_4),
    .RESET(Rst_N),
    .WCLOCK(Clk),
    .WE(Data_Out_En_2_Fifo_4),
    // Outputs
    .EMPTY(Adc_Fifo_Empty_4),
    .FULL(Adc_Fifo_Full_4),
    .Q(Data_Out_2_Ge_Fifo_4)
);
/* ADC module, each one is used for one ADC  */
ADC_AD7944 ADC_AD7944_1(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(Sdo[1]),
   .Turb(Turb),
   .CNV(CNV),
   .Pdref(Pdref),
   .Sck(Sck),
   .Data_Out(Data_Out_2_Fifo_1),
   .Tp(Tp[0]),
   .Data_Out_En(Data_Out_En_2_Fifo_1),
   .Out_Acq_End(Acq_End_Sig)
);
ADC_AD7944 ADC_AD7944_2(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(Sdo[2]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_2),
   .Data_Out_En(Data_Out_En_2_Fifo_2),
   .Out_Acq_End()
);
ADC_AD7944 ADC_AD7944_3(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(Sdo[3]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_3),
   .Data_Out_En(Data_Out_En_2_Fifo_3),
   .Out_Acq_End()
);
ADC_AD7944 ADC_AD7944_4(
   .Clk(Clk), 
   .Rst_N(Rst_N),
   .Start_In(Start_Converting_Sig), 
   .Sdo(Sdo[4]),
   .Turb(),
   .CNV(),
   .Pdref(),
   .Tp(),
   .Sck(),
   .Data_Out(Data_Out_2_Fifo_4),
   .Data_Out_En(Data_Out_En_2_Fifo_4),
   .Out_Acq_End()
);
 
assign Tp[1] = VA_Get_End;
assign Out_Cnt_of_En_1  =   Cnt_Data_En_1;

endmodule
