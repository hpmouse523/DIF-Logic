# This file is automatically generated.
# It contains project source information necessary for synthesis and implementation.

# XDC: E:/Work_File/CEPC/Logic/DIF-Logic/ECAL_DIF/Constraints/ECAL_DIF.xdc

# IP: ip/Ex_Fifo/Ex_Fifo.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==Ex_Fifo || ORIG_REF_NAME==Ex_Fifo}]

# IP: ip/PLL_40M/PLL_40M.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==PLL_40M || ORIG_REF_NAME==PLL_40M}]

# XDC: ip/Ex_Fifo/Ex_Fifo.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==Ex_Fifo || ORIG_REF_NAME==Ex_Fifo}] {/U0 }]/U0 ]]

# XDC: ip/Ex_Fifo/Ex_Fifo_clocks.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==Ex_Fifo || ORIG_REF_NAME==Ex_Fifo}] {/U0 }]/U0 ]]

# XDC: ip/PLL_40M/PLL_40M_board.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==PLL_40M || ORIG_REF_NAME==PLL_40M}] {/inst }]/inst ]]

# XDC: ip/PLL_40M/PLL_40M.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==PLL_40M || ORIG_REF_NAME==PLL_40M}] {/inst }]/inst ]]

# XDC: ip/PLL_40M/PLL_40M_late.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==PLL_40M || ORIG_REF_NAME==PLL_40M}] {/inst }]/inst ]]

# XDC: ip/PLL_40M/PLL_40M_ooc.xdc
