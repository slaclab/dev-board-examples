-------------------------------------------------------------------------------
-- File       : CntRtl.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: XST will infer DSP resources for this counter
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Example Project Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
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
