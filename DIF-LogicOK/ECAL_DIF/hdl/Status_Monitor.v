///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: Status_Monitor.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S050> <Package::484 FBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module Status_Monitor( 
  input clk,
  input reset_n,
  
  input Status_En, //for Controlling this module
  
  output reg [5:0] LED,
  output reg SMD_J7,
  output reg SMD_J13
);

reg [29:0] Cnt_Clk;
parameter T1S = 40000000;

always @ (posedge clk , negedge reset_n) begin
  if(~reset_n || !Status_En)
    LED <= 6'b000000;
  else if(Cnt_Clk == T1S)
    LED <= ~LED;
  else
    LED <= LED;

end

always @ (posedge clk ,negedge reset_n)begin
    if(~reset_n)
      Cnt_Clk <= 30'h0;
    else if(Cnt_Clk == T1S)
      Cnt_Clk <= 30'h0;
    else 
      Cnt_Clk <= Cnt_Clk + 1'b1;

end
//<statements>

endmodule

