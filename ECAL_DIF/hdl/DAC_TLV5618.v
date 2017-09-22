//DAC module to control TLV5618
//by Siyuan     20160418
//The Tsu > 10ns, which means cycle >20ns better use 20MHz Clk
/*16bit Control words D15:R1, D12:R0, D14 = D13 = 0; D11-D0: 12Data bits
  1.R1_R0 = 01 Write data to Buffer 
  2.R1_R0 = 10 Write data to OUTPUTA and update DAC B with buffer*/
module DAC_TLV5618(
  input           Clk,//Max Clk is 20MHz Use 10 MHz as Clk
  input           Rst_n,
  input           Usb_Cmd_En,
  input           In_Sel_A_B,   //1 means Channel A  0means Channel B
  input   [11:0]  In_Set_Chn_DAC_Code,

//IO of TLV5618
  output          Out_SCLK,
  output reg      Out_Din,
  output reg      Out_CS_n
);

reg               Sclk_En;
assign Out_SCLK = Sclk_En & Clk; 
reg      [4:0]    Cnt_Set_Buffer;

reg      [4:0]    Cnt_Delay;

wire     [15:0]   Chn_DAC_Code;


assign  Chn_DAC_Code[15:12]     = (In_Sel_A_B == 1'b1) ? 4'b1000  : 4'b0000;
assign  Chn_DAC_Code[11:0]      = In_Set_Chn_DAC_Code;



reg [1:0]         State;
reg [1:0]         Next_State;
localparam        IDLE          = 2'b00;
localparam        SET_BUFFER    = 2'b01;


always @ (posedge Clk or negedge Rst_n)
begin
  if(~Rst_n)
    begin
      State     <=    IDLE;

    end
  else
    State       <=    Next_State;
end

always @ (*)
begin
  if(~Rst_n)
    begin
      Next_State              =    IDLE;
    end
  else
    begin
      Next_State              =    IDLE;
      case(State)
        IDLE:
          begin
            if(Usb_Cmd_En)
              begin
                Next_State    =    SET_BUFFER;    
              end
            else
              begin
                Next_State    =    IDLE;
              end
          end
        SET_BUFFER:
          begin
            if(Cnt_Set_Buffer ==  5'd15)
              begin
                Next_State    =    IDLE;

              end
            else
              begin
                Next_State    =    SET_BUFFER;
              end
          end

        default:
                Next_State    =    IDLE;
      endcase
    end
end

always @ (posedge Clk or negedge Rst_n)
begin
  if(~Rst_n)
    begin
      Cnt_Set_Buffer          <=    5'd0;
      Sclk_En                 <=    1'b0;
      Out_Din                 <=    1'b0;
      Out_CS_n                <=    1'b1;

    end
  else
    begin
      case(State)
        IDLE:
          begin
            Cnt_Set_Buffer          <=    5'd0;
            Sclk_En                 <=    1'b0;
            Out_Din                 <=    1'b0;
            Out_CS_n                <=    1'b1; 
          end
        SET_BUFFER:
          begin
            Out_Din                 <=    Chn_DAC_Code[15 - Cnt_Set_Buffer]; 
            Cnt_Set_Buffer          <=    Cnt_Set_Buffer  + 1'b1;
            Sclk_En                 <=    1'b1;
            Out_CS_n                <=    1'b0;
          end

        default:
          begin
            Cnt_Set_Buffer          <=    5'd0;
            Sclk_En                 <=    1'b0;
            Out_Din                 <=    1'b0;
            Out_CS_n                <=    1'b1; 
          end
      endcase
    end
end
endmodule
