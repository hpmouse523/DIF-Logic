onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+Ex_Fifo -L xil_defaultlib -L xpm -L fifo_generator_v13_1_4 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.Ex_Fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {Ex_Fifo.udo}

run -all

endsim

quit -force
