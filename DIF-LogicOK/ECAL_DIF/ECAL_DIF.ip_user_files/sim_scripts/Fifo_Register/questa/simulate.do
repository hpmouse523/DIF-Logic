onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Fifo_Register_opt

do {wave.do}

view wave
view structure
view signals

do {Fifo_Register.udo}

run -all

quit -force
