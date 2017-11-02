onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L oddr_v1_0_0 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.ODDR_Clk xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ODDR_Clk.udo}

run -all

quit -force
