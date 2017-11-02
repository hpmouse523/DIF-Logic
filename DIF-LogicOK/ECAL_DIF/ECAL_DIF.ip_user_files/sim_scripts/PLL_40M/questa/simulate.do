onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib PLL_40M_opt

do {wave.do}

view wave
view structure
view signals

do {PLL_40M.udo}

run -all

quit -force
