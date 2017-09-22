vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/oddr_v1_0_0

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap oddr_v1_0_0 riviera/oddr_v1_0_0

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work oddr_v1_0_0  -v2k5 \
"../../../ipstatic/hdl/oddr_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../ECAL_DIF.srcs/sources_1/ip/ODDR_Clk/sim/ODDR_Clk.v" \

vlog -work xil_defaultlib \
"glbl.v"

