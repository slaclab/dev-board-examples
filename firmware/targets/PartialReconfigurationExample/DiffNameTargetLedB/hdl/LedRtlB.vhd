-------------------------------------------------------------------------------
-- File       : LedRtlB.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-01-13
-- Last update: 2014-01-13
-------------------------------------------------------------------------------
-- Description: Blinks the LED @ 5 Hz (instead of static design's 1 Hz rate)
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

entity LedRtlB is
   port (
      clk : in  sl;
      cnt : in  slv(31 downto 0);
      led : out sl);
end LedRtlB;

architecture rtl of LedRtlB is
   
   constant TOGGLE_PERIOD_C : real             := (100.0E-3);  -- 100 ms (5 Hz) toggle rate
   constant CLK_PERIOD_C    : real             := 5.0E-9;  -- 5 ns (200 MHz)
   constant MAX_CNT_C       : slv(31 downto 0) := toSlv(getTimeRatio(TOGGLE_PERIOD_C, CLK_PERIOD_C), 32);

   signal counter : slv(31 downto 0) := (others => '0');
   signal toggle  : sl               := '0';
   
begin

   led <= toggle;

   process(clk)
   begin
      if rising_edge(clk) then
         counter <= counter + 1;
         if counter = MAX_CNT_C then
            counter <= (others => '0');
            if toggle = '1' then
               toggle <= '0';
            else
               toggle <= '1';
            end if;
         end if;
      end if;
   end process;
   
end rtl;
