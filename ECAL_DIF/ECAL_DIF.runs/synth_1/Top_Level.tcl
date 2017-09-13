# 
# Synthesis run script generated by Vivado
# 

create_project -in_memory -part xc7a100tfgg484-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/wt [current_project]
set_property parent.project_path E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/usb_command_interpreter.v
  E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/Top_Level.v
}
read_vhdl -library xil_defaultlib {
  E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/SlaveFifoRead.vhd
  E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/SlaveFifoWrite.vhd
  E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/USB_Con.vhd
}
read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo.xci
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo.xdc]
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo_clocks.xdc]
set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo.xci]

read_ip -quiet e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M.xci
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M_board.xdc]
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M.xdc]
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M_late.xdc]
set_property used_in_implementation false [get_files -all e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M_ooc.xdc]
set_property is_locked true [get_files e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M.xci]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/Constraints/ECAL_DIF.xdc
set_property used_in_implementation false [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/Constraints/ECAL_DIF.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top Top_Level -part xc7a100tfgg484-2


write_checkpoint -force -noxdef Top_Level.dcp

catch { report_utilization -file Top_Level_utilization_synth.rpt -pb Top_Level_utilization_synth.pb }