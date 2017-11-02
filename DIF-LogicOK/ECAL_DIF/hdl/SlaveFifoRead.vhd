library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SlaveFifoRead is
port(
	rst : in std_logic;--modified by yuangy used for simulation
    UsbRdClk_i:   IN STD_LOGIC;
	SLRD_o:       OUT STD_LOGIC;
	SLOE_o:       OUT STD_LOGIC;
	FlagC_i:      IN STD_LOGIC;-----EP2 EMPTY FLAG changed by Junbin
	FlagD_i:      IN STD_LOGIC;-----EP2 FULL FLAG changed by Junbin
	UsbRdData_i:  IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    CtrData_o:    OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    CtrDataEn_o:  OUT STD_LOGIC;
	FifoAddr_o:   OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
end SlaveFifoRead;

architecture Behavioral of SlaveFifoRead is
 
    type   state_type is(Idlestate, state0, state1, state2, delay1, delay2);
	signal presentstate,nextstate :state_type:=Idlestate;
	signal configdata1,configdata2,configdata3:STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal sloe,slrd: STD_LOGIC;
	signal data :STD_LOGIC_VECTOR(15 DOWNTO 0);
	type   Config_reg is array(0 to 2) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal DRS_Eval_Config_Reg: Config_reg;

	signal wrendata : STD_LOGIC;
	 
begin
    process(UsbRdClk_i)
	variable i: integer range 0 to 15:=0;
	variable j: integer range 0 to 7:=0;
	begin
		if(rst='0') then presentstate <=Idlestate;else--modified by yuangy used for simulation
		if(UsbRdClk_i'event and UsbRdClk_i='1')then
			case presentstate is
			when Idlestate =>
				slrd <='1';
				sloe <='1';
				i:=0;
				j:=0;--j:=0;20150507 yuanyg ·ÂÕæÓÃ
				wrendata <= '0';
				if(FlagC_i ='0')then-----if Ep2 not empty
					presentstate <= state0;
				end if;
				
			when state0 => 
			    i:=0;
				slrd <='1';
				sloe <='0';
        wrendata <= '0';
				presentstate <= state1;
			
			when state1 =>
				slrd <='0';
        wrendata <='0';
            i:=i+1;
				if(i>4)then
				presentstate <= delay1;
				end if;
				
			when delay1 =>
			    slrd <='1';  --data read (rising edge active) 
				presentstate <= state2;
        wrendata <= '0';
				
			
			when state2 =>
				slrd <='1';
				j:=j+1;
				if(j<2)then
				DRS_Eval_Config_Reg(j-1) <= UsbRdData_i;
				data <=UsbRdData_i;
				end if;
				
				wrendata <= '1';			
				presentstate <= delay2;
			
			when delay2 =>
			   wrendata <= '0'; 
				i:=i+1;
				if(i>8)then
				  if(FlagC_i ='1')then
					presentstate <= Idlestate;
				  else
					presentstate <= state0;
				  end if;
				end if;
				
			when others =>
				presentstate <= Idlestate;
				
			end case;				
	  end if;
	end if;--modified by yuangy used for simulation
	end process;
	 
	CtrData_o(7 downto 0) <= data(15 downto 8);
	CtrData_o(15 downto 8) <= data(7 downto 0);

	FifoAddr_o <="00";  --modified by Junbin EP4 Change to EP2
	SLOE_o <= sloe;
	SLRD_o <= slrd;
	CtrDataEn_o <= wrendata;			  				  				   		
end Behavioral;

