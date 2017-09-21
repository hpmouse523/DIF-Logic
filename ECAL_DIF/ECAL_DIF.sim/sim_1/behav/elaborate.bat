@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.1\\bin
call %xv_path%/xelab  -wto d5f7fc9a3a2046a0b35530570d8d590d -m64 --debug typical --relax --mt 2 -L fifo_generator_v13_1_4 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot test_Auto_DAC_behav xil_defaultlib.test_Auto_DAC xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
