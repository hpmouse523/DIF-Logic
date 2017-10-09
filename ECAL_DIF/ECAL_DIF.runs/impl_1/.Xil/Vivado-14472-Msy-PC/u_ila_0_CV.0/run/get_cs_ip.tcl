#
#Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
set_param chipscope.flow 0
set part xc7a100tfgg484-2
set ip_vlnv xilinx.com:ip:ila:6.2
set ip_module_name u_ila_0_CV
set params {{{PARAM_VALUE.ALL_PROBE_SAME_MU} {true} {PARAM_VALUE.ALL_PROBE_SAME_MU_CNT} {1} {PARAM_VALUE.C_ADV_TRIGGER} {false} {PARAM_VALUE.C_DATA_DEPTH} {1024} {PARAM_VALUE.C_EN_STRG_QUAL} {false} {PARAM_VALUE.C_INPUT_PIPE_STAGES} {0} {PARAM_VALUE.C_NUM_OF_PROBES} {4} {PARAM_VALUE.C_PROBE0_TYPE} {0} {PARAM_VALUE.C_PROBE0_WIDTH} {64} {PARAM_VALUE.C_PROBE1_TYPE} {0} {PARAM_VALUE.C_PROBE1_WIDTH} {1} {PARAM_VALUE.C_PROBE2_TYPE} {0} {PARAM_VALUE.C_PROBE2_WIDTH} {1} {PARAM_VALUE.C_PROBE3_TYPE} {0} {PARAM_VALUE.C_PROBE3_WIDTH} {1} {PARAM_VALUE.C_TRIGIN_EN} {0} {PARAM_VALUE.C_TRIGOUT_EN} {0}}}
set output_xci e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.runs/impl_1/.Xil/Vivado-14472-Msy-PC/u_ila_0_CV.0/out/result.xci
set output_dcp e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.runs/impl_1/.Xil/Vivado-14472-Msy-PC/u_ila_0_CV.0/out/result.dcp
set output_dir e:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.runs/impl_1/.Xil/Vivado-14472-Msy-PC/u_ila_0_CV.0/out
set ip_repo_paths {}
set ip_output_repo E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/ip
set ip_cache_permissions {read write}

set oopbus_ip_repo_paths [get_param chipscope.oopbus_ip_repo_paths]

set synth_opts {}
set xdc_files {}
source {C:/Xilinx/Vivado/2017.1/scripts/ip/ipxchipscope.tcl}

set failed [catch {ipx::chipscope::gen_and_synth_ip $part $ip_vlnv $ip_module_name $params $output_xci $output_dcp $output_dir $ip_repo_paths $ip_output_repo $ip_cache_permissions $oopbus_ip_repo_paths $synth_opts $xdc_files} errMessage]

if { $failed } {
send_msg_id {IP_Flow-19-3805} ERROR "Failed to generate and synthesize debug IP $ip_vlnv. \n $errMessage"
  exit 1
}
