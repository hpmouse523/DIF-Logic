onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ODDR_Clk_opt

do {wave.do}

view wave
view structure
view signals

do {ODDR_Clk.udo}

run -all

quit -force
