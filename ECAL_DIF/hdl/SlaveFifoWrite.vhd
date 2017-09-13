
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SlaveFifoWrite is
port(
	rst : in std_logic;--modified by yuangy used for simulation
	EndUsbWr_i:    IN STD_LOGIC;
	UsbWrClk_i:    IN STD_LOGIC;
	SLWR_o:        OUT STD_LOGIC;
	SLOE_i:        IN STD_LOGIC;
	FlagA_i:       IN STD_LOGIC;-----EP6 EMPTY FLAG
	FlagB_i:       IN STD_LOGIC;-----EP6 FULL FLAG
	FlagC_i:       IN STD_LOGIC;-----EP2 EMPTY FLAG
	ExFifoEmpty_i: IN STD_LOGIC;
	ExFifoRdEn_o:  OUT STD_LOGIC;
	PktEnd_o:      OUT STD_LOGIC;
	FifoAddr_o :   OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
end SlaveFifoWrite;

architecture Behavioral of SlaveFifoWrite is

	type state_type is(Idlestate,wr_state,wr_step1, wr_step2, wr_step3, wr_PktEnd);
	signal presentstate :state_type:=Idlestate;
	signal sloe,slwr: std_logic;
	signal ExFifoRdEn_tmp: std_logic;
		
begin

ExFifoRdEn_o <= ExFifoRdEn_tmp;	
SLWR_o <= slwr;		 	

process(UsbWrClk_i)
	variable slwr_cnt : integer range 0 to 511 :=0;
	begin
	if(rst='0') then presentstate <=Idlestate;else--modified by yuangy used for simulation
	if(UsbWrClk_i'event and UsbWrClk_i='1')then
		case presentstate is
			when Idlestate =>
				FifoAddr_o <="10";--EP6
				PktEnd_o <= '1';
				ExFifoRdEn_tmp <= '0';
				slwr <='1';
				slwr_cnt :=0;
				if(EndUsbWr_i ='0' and FlagC_i ='1' and SLOE_i ='1')then-----make sure USB is not in read mode.
					presentstate <= wr_state;
				else
				    presentstate <= Idlestate;
				end if;

			when wr_state=>
				PktEnd_o <= '1';
				slwr_cnt :=0;
				if EndUsbWr_i = '1' then						--Í£Ö¹²ÉÊý,annotated by yuangy
					if ExFifoEmpty_i ='1'  then
						if  FlagB_i ='0' and FlagA_i ='0' then--RdOutFifo Empty and Ep6 is not full and not empty , set PktEnd_o
							presentstate <= wr_PktEnd;            
							ExFifoRdEn_tmp <= '0';  
						elsif( FlagB_i ='1') then              ---RdOutFifo Empty,Ep6 Full return to idle state
								ExFifoRdEn_tmp <= '0';
								presentstate <= wr_state;
							else
								ExFifoRdEn_tmp <= '0';
								presentstate <= Idlestate; 
						end if;	
					else
						if FlagB_i ='0' then		-----RdOutFifo not Empty, Ep6 not Full 
							presentstate <= wr_step1;
							ExFifoRdEn_tmp <= '1';	
						else                   -----RdOutFifo not Empty, Ep6 Full
							ExFifoRdEn_tmp <= '0';
							presentstate <= wr_state;
						end if;
					end if;	
				else                                --EndUsbWr_i ='0',annotated by yuangy
					if ExFifoEmpty_i ='1' then
						ExFifoRdEn_tmp <= '0';
						presentstate <= wr_state;
					else
						if FlagB_i ='0' then		-----RdOutFifo not Empty, Ep6 not Full 
							presentstate <= wr_step1;
						else                   -----RdOutFifo not Empty, Ep6 Full
							ExFifoRdEn_tmp <= '0';
							presentstate <= wr_state;
						end if;
					end if;
				end if;	
						
			when wr_step1 =>
				ExFifoRdEn_tmp <= '1';
				slwr <='0';
				presentstate <= wr_step2;	 
			when wr_step2 =>
			    slwr <='0';
			    ExFifoRdEn_tmp <= '0';
				slwr_cnt :=slwr_cnt+1;
				if(slwr_cnt >1)then
					presentstate <= wr_step3;
				end if;
			
			when wr_step3 =>
			    slwr <='1';
				slwr_cnt :=slwr_cnt+1;
				if(slwr_cnt >5)then
				    presentstate <= wr_state;
				end if;
				 
			when wr_PktEnd =>			    
				slwr_cnt :=slwr_cnt +1;
				if(slwr_cnt <5)then
					PktEnd_o  <= '0';
				else
					PktEnd_o  <= '1';
				end if;
				if(slwr_cnt >10)then
				    presentstate <= Idlestate;
				end if;
             
		    when others =>
			    ExFifoRdEn_tmp <= '0';
				slwr <='1';
				slwr_cnt :=0;
			    presentstate <= Idlestate;			
			end case;				
	end if;
end if;
end process;
				  				  				   		
end Behavioral;

