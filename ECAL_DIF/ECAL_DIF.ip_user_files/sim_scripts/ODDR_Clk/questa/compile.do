vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm
vlib msim/oddr_v1_0_0

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm
vmap oddr_v1_0_0 msim/oddr_v1_0_0

vlog -work xil_defaultlib -64 -sv \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work oddr_v1_0_0 -64 \
"../../../ipstatic/hdl/oddr_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib -64 \
"../../../../ECAL_DIF.srcs/sources_1/ip/ODDR_Clk/sim/ODDR_Clk.v" \

vlog -work xil_defaultlib \
"glbl.v"

