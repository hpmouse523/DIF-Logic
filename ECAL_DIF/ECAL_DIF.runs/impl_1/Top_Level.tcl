proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config  -ruleid {1}  -id {Synth 8-3352}  -string {{CRITICAL WARNING: [Synth 8-3352] multi-driven net Q with 1st driver pin 'Auto_TA_Scan_Inst/SKIROC_Auto_TA_Inst_Chip2/Out_Fifo_Din_reg[1]/Q' [E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/SKIROC2_S_Para_Scan.v:495]}}  -suppress 
set_msg_config  -ruleid {2}  -id {Synth 8-3352}  -string {{CRITICAL WARNING: [Synth 8-3352] multi-driven net Q with 2nd driver pin 'GND' [E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/hdl/SKIROC2_S_Para_Scan.v:495]}}  -suppress 
set_msg_config  -ruleid {3}  -id {Synth 8-5559}  -new_severity {ERROR} 

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7a100tfgg484-2
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/wt [current_project]
  set_property parent.project_path E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.xpr [current_project]
  set_property ip_output_repo E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.runs/synth_1/Top_Level.dcp
  read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo.xci
  set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Ex_Fifo/Ex_Fifo.xci]
  read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Fifo_Register/Fifo_Register.xci
  set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/Fifo_Register/Fifo_Register.xci]
  read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M.xci
  set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/PLL_40M/PLL_40M.xci]
  read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/ODDR_Clk/ODDR_Clk.xci
  set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/ODDR_Clk/ODDR_Clk.xci]
  read_ip -quiet E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0.xci
  set_property is_locked true [get_files E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0.xci]
  read_xdc E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/Constraints/ECAL_DIF.xdc
  link_design -top Top_Level -part xc7a100tfgg484-2
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force Top_Level_opt.dcp
  catch { report_drc -file Top_Level_drc_opted.rpt }
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force Top_Level_placed.dcp
  catch { report_io -file Top_Level_io_placed.rpt }
  catch { report_utilization -file Top_Level_utilization_placed.rpt -pb Top_Level_utilization_placed.pb }
  catch { report_control_sets -verbose -file Top_Level_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force Top_Level_routed.dcp
  catch { report_drc -file Top_Level_drc_routed.rpt -pb Top_Level_drc_routed.pb -rpx Top_Level_drc_routed.rpx }
  catch { report_methodology -file Top_Level_methodology_drc_routed.rpt -rpx Top_Level_methodology_drc_routed.rpx }
  catch { report_power -file Top_Level_power_routed.rpt -pb Top_Level_power_summary_routed.pb -rpx Top_Level_power_routed.rpx }
  catch { report_route_status -file Top_Level_route_status.rpt -pb Top_Level_route_status.pb }
  catch { report_clock_utilization -file Top_Level_clock_utilization_routed.rpt }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file Top_Level_timing_summary_routed.rpt -rpx Top_Level_timing_summary_routed.rpx }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force Top_Level_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  catch { write_mem_info -force Top_Level.mmi }
  write_bitstream -force Top_Level.bit 
  catch {write_debug_probes -no_partial_ltxfile -quiet -force debug_nets}
  catch {file copy -force debug_nets.ltx Top_Level.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

