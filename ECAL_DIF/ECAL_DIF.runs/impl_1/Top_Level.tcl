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

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_param xicom.use_bs_reader 1
  open_checkpoint Top_Level_routed.dcp
  set_property webtalk.parent_dir E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/ECAL_DIF.cache/wt [current_project]
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

