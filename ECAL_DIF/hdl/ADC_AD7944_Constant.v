//This module is designed by Siyuan Ma on 2016-4-15 
//Used to Constantly achieve Input data of ADC1
//to test whether ADC is working right.
module ADC_AD7944_Constant (
  input         Clk, //50MHz
  input         Rst_N,
  input         Start_In, //Start ADC
  input [13:0]  In_Set_Constant_Interval_Time_us,

  //Test Signal
  output        Tp,
  //IO 2 ADC 
  input         Sdo,

  output        Turb,
  output reg    CNV,
  output        Pdref,
  output        Sck,
  output reg [15:0] Data_Out,
  output reg    Data_Out_En
//for testing, can be canceled after testing
 // output [1:0] State_Now
  

);



assign            Pdref = 1'b1; // External Ref
assign            Turb  = 1'b0; //Normal mode
reg [5:0]   Cnt_Conv;
localparam [5:0]  Tconv = 6'd40; //>420 ns 80MHz=12.5ns  Cnt = 33.6
reg [5:0]   Cnt_Acq;
reg [13:0]  Cnt_Comp;
reg [5:0]   Cnt_Sdo; //change bit for DataOut to assignment
reg         Time_1us;
reg [7:0]   Cnt_2_1us;

localparam [7:0]  TIME_1US     = 8'd50; 

reg Sck_En;

//define States
localparam [1:0 ] STATE_CONV   = 2'b00,
                  STATE_ACQ    = 2'b01,
                  STATE_COMP   = 2'b10;
reg [1:0] State;
//define Data_Width
localparam [4:0] DATA_WIDTH = 5'd14;
localparam [7:0] TCOMP = 8'd10;


//assign State_Now = State;
always @ (posedge Clk , negedge Rst_N) 
begin
  if(~Rst_N)
  begin
    Data_Out <= 16'd0;
    Data_Out_En <= 1'd0;
    CNV <= 1'b1;
    Cnt_Sdo <= 6'd0;
    Sck_En <= 1'b0;
    Cnt_Conv <= 6'd0;
    Cnt_Acq <= 6'd0;
    Cnt_Comp <= 8'd0;
    State <= STATE_CONV;
  end
  else 
  begin           //40+1+13+1+10+1 = 66 66*20 = 1320ns 
    case(State)
      STATE_CONV:  // 40
       begin
          if(~Start_In )
            State <= STATE_CONV;
          else if(Cnt_Conv < Tconv )
          begin
           State <= STATE_CONV;
           Cnt_Conv <= Cnt_Conv + 1'b1;
          end
         else 
         begin
           Cnt_Conv <= 6'd0;
            CNV <= 1'b0;
           Sck_En <= 1'b1;
           State <= STATE_ACQ; //1
          end
      end
      STATE_ACQ:
      begin
        Data_Out[DATA_WIDTH - 1 - Cnt_Sdo] <= Sdo; //13
        if(Cnt_Sdo < DATA_WIDTH - 1)
        begin
          Cnt_Sdo <=  Cnt_Sdo + 1'b1;
          State <= STATE_ACQ;
        end
        else
        begin
          Cnt_Sdo <= 6'd0;   //1
          Data_Out_En <= 1'b1;
          Sck_En <= 1'b0;
          State <= STATE_COMP;
        end
      end
      STATE_COMP:    //10
      begin
        Data_Out_En <= 1'b0;
        if(Cnt_Comp < In_Set_Constant_Interval_Time_us)   
        begin
          if(Time_1us)
            begin
              Cnt_Comp <= Cnt_Comp + 1'b1;
            end
          else
            begin
              Cnt_Comp <= Cnt_Comp;
            end


              State    <= STATE_COMP;
        end
        else
        begin     //1
          Cnt_Comp <= 8'd0;
          CNV <= 1'b1;
          State <= STATE_CONV;
        end
      end
        default:State <= STATE_CONV;
    endcase
  end
end
//Set 1 us 
always @ (posedge Clk or negedge Rst_N)
begin
  if(~Rst_N)
    begin
      Cnt_2_1us <= 8'd0;
      Time_1us  <= 1'b0;
    end
  else
    begin
      if(Cnt_2_1us == TIME_1US - 1'b1)
        begin
          Cnt_2_1us   <= 8'd0;
          Time_1us    <= 1'b1;
        end
      else
        begin
          Cnt_2_1us   <= Cnt_2_1us + 1'b1;
          Time_1us    <= 1'b0;
        end
    end
end
  
  
  
  
assign Sck = ~Clk & Sck_En; //define Sck. Enabled when En = 1 and reverse to Clk SCK is valid of negedge
assign Tp = Data_Out_En;

endmodule
