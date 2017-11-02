-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.1 (win64) Build 1846317 Fri Apr 14 18:55:03 MDT 2017
-- Date        : Thu Sep 21 15:02:25 2017
-- Host        : Msy-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode funcsim -rename_top ODDR_Clk -prefix
--               ODDR_Clk_ ODDR_Clk_sim_netlist.vhdl
-- Design      : ODDR_Clk
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a100tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ODDR_Clk_oddr_v1_0_0_oddr is
  port (
    clk_out : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );
end ODDR_Clk_oddr_v1_0_0_oddr;

architecture STRUCTURE of ODDR_Clk_oddr_v1_0_0_oddr is
  signal NLW_ODDR_inst_R_UNCONNECTED : STD_LOGIC;
  signal NLW_ODDR_inst_S_UNCONNECTED : STD_LOGIC;
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of ODDR_inst : label is "PRIMITIVE";
  attribute \__SRVAL\ : string;
  attribute \__SRVAL\ of ODDR_inst : label is "TRUE";
begin
ODDR_inst: unisim.vcomponents.ODDR
    generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",
      INIT => '0',
      IS_C_INVERTED => '0',
      IS_D1_INVERTED => '0',
      IS_D2_INVERTED => '0',
      SRTYPE => "SYNC"
    )
        port map (
      C => clk_in,
      CE => '1',
      D1 => '1',
      D2 => '0',
      Q => clk_out,
      R => NLW_ODDR_inst_R_UNCONNECTED,
      S => NLW_ODDR_inst_S_UNCONNECTED
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ODDR_Clk is
  port (
    clk_in : in STD_LOGIC;
    clk_out : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of ODDR_Clk : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of ODDR_Clk : entity is "ODDR_Clk,oddr_v1_0_0_oddr,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of ODDR_Clk : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of ODDR_Clk : entity is "oddr_v1_0_0_oddr,Vivado 2017.1";
end ODDR_Clk;

architecture STRUCTURE of ODDR_Clk is
begin
inst: entity work.ODDR_Clk_oddr_v1_0_0_oddr
     port map (
      clk_in => clk_in,
      clk_out => clk_out
    );
end STRUCTURE;
