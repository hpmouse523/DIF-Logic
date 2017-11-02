-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/oddr_v1_0_0 \
  "../../../ipstatic/hdl/oddr_v1_0_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../ECAL_DIF.srcs/sources_1/ip/ODDR_Clk/sim/ODDR_Clk.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

