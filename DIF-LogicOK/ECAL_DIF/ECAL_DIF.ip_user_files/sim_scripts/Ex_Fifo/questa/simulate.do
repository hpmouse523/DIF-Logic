onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Ex_Fifo_opt

do {wave.do}

view wave
view structure
view signals

do {Ex_Fifo.udo}

run -all

quit -force
