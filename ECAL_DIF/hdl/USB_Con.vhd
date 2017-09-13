--Designed by Skywalker, Fast Electronics Lab
--Modified by Aceh, 2010-9-24
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity USB_Con is
port(
	----connect with CY68013
	USBCLK_i:      IN STD_LOGIC;-----IFCLK
	SLRD_o:        OUT STD_LOGIC;
	SLOE_o:        OUT STD_LOGIC;
	SLWR_o:        OUT STD_LOGIC;
	FlagA_i:       IN STD_LOGIC;-----EP6 EMPTY FLAG 写fifo
	FlagB_i:       IN STD_LOGIC;-----EP6 FULL FLAG
	FlagC_i:       IN STD_LOGIC;-----EP2 EMPTY FLAG 读fifo
	FlagD_i:       IN STD_LOGIC;-----EP2 FULL FLAG
	PktEnd_o:      OUT STD_LOGIC;
	WAKEUP :        OUT STD_LOGIC;  -- modified by Junbin 2014/1/20
	FifoAddr_o :   OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	USBData :      INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	----connect with ExFifo
	ExFifoData_i:  IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	ExFifoEmpty_i: IN STD_LOGIC;
	ExFifoRdEn_o:  OUT STD_LOGIC;
	----connect with CtrReg
	rst:in std_logic;--modified by yuangy used for simulation
	EndUsbWr_i:    IN STD_LOGIC;
	CtrData_o:     OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	CtrDataEn_o:   OUT STD_LOGIC
	);
end USB_Con;

architecture Behavioral of USB_Con is
	------------------Slave Fifo Read   由fpga通过USB从电脑read
	component SlaveFifoRead is 
    port(
		rst : in std_logic;--modified by yuangy used for simulation
		UsbRdClk_i:   IN STD_LOGIC;
	    SLRD_o:       OUT STD_LOGIC;
	    SLOE_o:       OUT STD_LOGIC;
	    FlagC_i:      IN STD_LOGIC;-----EP2 EMPTY FLAG
	    FlagD_i:      IN STD_LOGIC;-----EP2 FULL FLAG
	    UsbRdData_i:  IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
		CtrData_o:    OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		CtrDataEn_o:  OUT STD_LOGIC;
	    FifoAddr_o:   OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	    );
    end component;
	------------------Slave Fifo Write   由FPGA向电脑write
	component SlaveFifoWrite is 
	port(
		rst : in std_logic;--modified by yuangy used for simulation
	    EndUsbWr_i:    IN STD_LOGIC;
        UsbWrClk_i:    IN STD_LOGIC;
	    SLWR_o:        OUT STD_LOGIC;
	    SLOE_i:        IN STD_LOGIC;
	    FlagA_i:       IN STD_LOGIC;-----EP6 EMPTY FLAG
	    FlagB_i:       IN STD_LOGIC;-----EP6 FULL FLAG
		FlagC_i:       IN STD_LOGIC;
		ExFifoEmpty_i: IN STD_LOGIC;
		PktEnd_o:      OUT STD_LOGIC;
		ExFifoRdEn_o:  OUT STD_LOGIC;
	    FifoAddr_o:    OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	    );
    end component;
	
	signal UsbWrAddr_o,UsbRdAddr_o:          STD_LOGIC_VECTOR(1 DOWNTO 0);
	signal SLOE_UsbRd_o,SLOE_UsbWr_i:        STD_LOGIC;
	signal UsbRdData_i:                      STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal SysClear_tmp:                     STD_LOGIC;
		
begin
      
    SlaveFifoRead_inst: SlaveFifoRead	
	port map(
		rst=>rst,--modified by yuangy used for simulation
	    UsbRdClk_i     => USBCLK_i,
	    SLRD_o         => SLRD_o,
	    SLOE_o         => SLOE_UsbRd_o, 
	    FlagC_i        => FlagC_i,
	    FlagD_i        => FlagD_i,
	    UsbRdData_i    => UsbRdData_i,
		CtrData_o      => CtrData_o,
		CtrDataEn_o    => CtrDataEn_o,
	    FifoAddr_o     => UsbRdAddr_o
	    );
			 
	 SlaveFifoWrite_inst : SlaveFifoWrite
	 port map(
		rst=>rst,--modified by yuangy used for simulation
	    EndUsbWr_i     => EndUsbWr_i,
	    UsbWrClk_i     => USBCLK_i,
	    SLWR_o         => SLWR_o,
	    SLOE_i         => SLOE_UsbWr_i,
	    FlagA_i        => FlagA_i,
	    FlagB_i        => FlagB_i,
		FlagC_i        => FlagC_i,
		ExFifoEmpty_i  => ExFifoEmpty_i,
		PktEnd_o       => PktEnd_o,
		ExFifoRdEn_o   => ExFifoRdEn_o,
	    FifoAddr_o     => UsbWrAddr_o
	    );
			 
	 UsbRdData_i <= USBData when FlagC_i ='0' or SLOE_UsbRd_o='0' else
	             (others => 'Z');
	 
	 USBData <= ExFifoData_i when FlagC_i ='1' and SLOE_UsbRd_o ='1' else
	            (others => 'Z');
	 
	 FifoAddr_o <= UsbRdAddr_o when FlagC_i ='0' or SLOE_UsbRd_o='0'  else
	            UsbWrAddr_o; 
	 
	 WAKEUP <= '1'; --modified by Junbin 2014/1/20
	 SLOE_o <= SLOE_UsbRd_o;
     SLOE_UsbWr_i <= SLOE_UsbRd_o;
	 
end Behavioral;

