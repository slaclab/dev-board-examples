-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : CntRtl.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-01-13
-- Last update: 2014-01-13
-- Platform   : Vivado2013.3
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: XST will infer DSP resources for this counter
-------------------------------------------------------------------------------
-- Copyright (c) 2014 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;

entity CntRtl is
   port (
      clk : in  sl;
      cnt : out slv(31 downto 0));
end CntRtl;

architecture rtl of CntRtl is

   signal counter                 : slv(31 downto 0) := (others => '0');
   attribute use_dsp48            : string;
   attribute use_dsp48 of counter : signal is "yes";
   --attribute use_dsp48 of counter : signal is "no";
   
begin

   cnt <= counter;

   process(clk)
   begin
      if rising_edge(clk) then
         counter <= counter + 1;
      end if;
   end process;
   
end rtl;
