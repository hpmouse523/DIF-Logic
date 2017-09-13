onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+PLL_40M -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.PLL_40M xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {PLL_40M.udo}

run -all

endsim

quit -force
