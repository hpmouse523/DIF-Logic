onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ODDR_Clk -L xil_defaultlib -L xpm -L oddr_v1_0_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ODDR_Clk xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ODDR_Clk.udo}

run -all

endsim

quit -force
