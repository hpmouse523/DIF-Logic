/*This module is used for  Setting Cali and TAs' DAC Value
  modified by siyuan 20160419*/
module Cali_DAC(
  input           Clk,
  input           Clk_20M,
  input           Rst_n,
  input           In_Start_Set_DAC,
  input   [1:0]   In_Sel_Cali_TA,
  input           In_Sel_Chn_A_B,//Select ChnA or B  1for A  0 for B
  input   [11:0]  In_Set_Cali_DAC,
  input   [11:0]  In_Set_TA_Thr_DAC_12,
  input   [11:0]  In_Set_TA_Thr_DAC_34,
//IO of Cali_DAC
  output          Out_SCLK_Cali,
  output          Out_Din_Cali,
  output          Out_CS_n_Cali,
//IO of TA_DAC 12  
  output          Out_SCLK_TA_12,
  output          Out_Din_TA_12,
  output          Out_Cs_n_TA_12,
 //IO of TA_DAC 34  
  output          Out_SCLK_TA_34,
  output          Out_Din_TA_34,
  output          Out_Cs_n_TA_34,
 //IO of TA_DAC_backup
  output          Out_SCLK_TA_Back,
  output          Out_Din_TA_Back,
  output          Out_Cs_n_TA_Back,
  //IO of ADG701
  output          Out_Cali_Start_Control
);

reg               In_Start_Set_DAC_Delay;
reg [4:0]         Cnt_Start_Set_DAC;
reg [1:0]         State_Width;
localparam  [1:0] WIDTH_IDLE        = 2'd0;
localparam  [1:0] WIDTH_CONT        = 2'd1;

wire              Cmd_En_Cali;
wire              Cmd_En_TA_12;
wire              Cmd_En_TA_34;
reg              Cmd_En_Cali_Delay1;
reg              Cmd_En_Cali_Delay2;
reg              Cmd_En_TA_12_Delay1;
reg              Cmd_En_TA_12_Delay2;
reg              Cmd_En_TA_34_Delay1;
reg              Cmd_En_TA_34_Delay2;

always @ (posedge Clk_20M or negedge Rst_n)
begin
  if(~Rst_n)
    begin
      Cmd_En_Cali_Delay1        <=  1'b0;
      Cmd_En_TA_12_Delay1       <=  1'b0;
      Cmd_En_TA_34_Delay1       <=  1'b0;
    end
  else
    begin
      Cmd_En_Cali_Delay1        <=  Cmd_En_Cali;
      Cmd_En_TA_12_Delay1       <=  Cmd_En_TA_12;
      Cmd_En_TA_34_Delay1       <=  Cmd_En_TA_34;
    end

end

always @ (posedge Clk_20M or negedge Rst_n)
begin
  if(~Rst_n)
    begin
      Cmd_En_Cali_Delay2        <=  1'b0;
      Cmd_En_TA_12_Delay2       <=  1'b0;
      Cmd_En_TA_34_Delay2       <=  1'b0;
    end
  else
    begin
      Cmd_En_Cali_Delay2        <=  Cmd_En_Cali_Delay1;
      Cmd_En_TA_12_Delay2       <=  Cmd_En_TA_12_Delay1;
      Cmd_En_TA_34_Delay2       <=  Cmd_En_TA_34_Delay1;
    end

end




//Width signal In_Start_Set_DAC to 10*20 = 200ns
always @ (posedge Clk or negedge Rst_n)
begin
  if(~Rst_n)
    begin
      State_Width             <=  WIDTH_IDLE;
      Cnt_Start_Set_DAC       <=  5'd0;
      In_Start_Set_DAC_Delay  <=  1'b0;
    end
  else 
    begin
      case(State_Width)
        WIDTH_IDLE:
          begin
            if(In_Start_Set_DAC)
              begin
                State_Width                 <=  WIDTH_CONT;
              end
            else
              begin
                State_Width                 <=  WIDTH_IDLE;
                In_Start_Set_DAC_Delay      <=  1'b0;
                Cnt_Start_Set_DAC           <=  5'd0;
              end
          end
        WIDTH_CONT:
          begin
            if(Cnt_Start_Set_DAC  ==  5'd10)
              begin
                State_Width                 <=  WIDTH_IDLE;
                Cnt_Start_Set_DAC           <=  5'd0;
                In_Start_Set_DAC_Delay      <=  1'b0;
              end
            else
              begin
                Cnt_Start_Set_DAC           <=  Cnt_Start_Set_DAC + 1'b1;
                State_Width                 <=  WIDTH_CONT;
                In_Start_Set_DAC_Delay      <=  1'b1;
              end
            
          end
        default: State_Width                <=  WIDTH_IDLE;
      endcase
    end

end

assign  Cmd_En_Cali    =  (In_Sel_Cali_TA ==2'b00) ? In_Start_Set_DAC_Delay :  1'b0;
assign  Cmd_En_TA_12   =  (In_Sel_Cali_TA ==2'b10) ? In_Start_Set_DAC_Delay :  1'b0;
assign  Cmd_En_TA_34   =  (In_Sel_Cali_TA ==2'b11) ? In_Start_Set_DAC_Delay :  1'b0;


DAC_TLV5618 Dac_For_Cali(
   .Clk(Clk_20M),
   .Rst_n(Rst_n),
   .Usb_Cmd_En(Cmd_En_Cali_Delay2),
   .In_Sel_A_B(1'b1),
   .In_Set_Chn_DAC_Code(In_Set_Cali_DAC),

//IO of TLV5618
   .Out_SCLK(Out_SCLK_Cali),
   .Out_Din(Out_Din_Cali),
   .Out_CS_n(Out_CS_n_Cali)
);

DAC_TLV5618 Dac_For_TA_12(
   .Clk(Clk_20M),
   .Rst_n(Rst_n),
   .Usb_Cmd_En(Cmd_En_TA_12_Delay2),
   .In_Sel_A_B(In_Sel_Chn_A_B),
   .In_Set_Chn_DAC_Code(In_Set_TA_Thr_DAC_12),

//IO of TLV5618
   .Out_SCLK(Out_SCLK_TA_12),
   .Out_Din(Out_Din_TA_12),
   .Out_CS_n(Out_Cs_n_TA_12)
);

DAC_TLV5618 Dac_For_TA_34(
   .Clk(Clk_20M),
   .Rst_n(Rst_n),
   .Usb_Cmd_En(Cmd_En_TA_34_Delay2),
   .In_Sel_A_B(In_Sel_Chn_A_B),
   .In_Set_Chn_DAC_Code(In_Set_TA_Thr_DAC_34),
   
//IO of TLV5618
   .Out_SCLK(Out_SCLK_TA_34),
   .Out_Din(Out_Din_TA_34),
   .Out_CS_n(Out_Cs_n_TA_34)
);
DAC_TLV5618 Dac_For_TA_backup(
   .Clk(Clk_20M),
   .Rst_n(Rst_n),
   .Usb_Cmd_En(Cmd_En_TA_34_Delay2),
   .In_Sel_A_B(In_Sel_Chn_A_B),
   .In_Set_Chn_DAC_Code(In_Set_TA_Thr_DAC_34),
   
//IO of TLV5618
   .Out_SCLK(),
   .Out_Din(),
   .Out_CS_n()
);
DAC_TLV5618 Dac_For_TA_backup_1(
   .Clk(Clk_20M),
   .Rst_n(Rst_n),
   .Usb_Cmd_En(Cmd_En_TA_34_Delay2),
   .In_Sel_A_B(In_Sel_Chn_A_B),
   .In_Set_Chn_DAC_Code(In_Set_TA_Thr_DAC_34),
   
//IO of TLV5618
   .Out_SCLK(),
   .Out_Din(),
   .Out_CS_n()
);


endmodule
