@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.1\\bin
call %xv_path%/xsim Test_Cmd_Set_N_Bits_Value_behav -key {Behavioral:sim_1:Functional:Test_Cmd_Set_N_Bits_Value} -tclbatch Test_Cmd_Set_N_Bits_Value.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
