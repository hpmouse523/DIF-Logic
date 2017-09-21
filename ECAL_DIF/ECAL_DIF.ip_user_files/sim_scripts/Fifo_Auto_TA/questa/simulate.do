onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Fifo_Auto_TA_opt

do {wave.do}

view wave
view structure
view signals

do {Fifo_Auto_TA.udo}

run -all

quit -force
