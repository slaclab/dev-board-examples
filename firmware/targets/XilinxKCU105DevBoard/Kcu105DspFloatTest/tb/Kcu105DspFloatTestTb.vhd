-------------------------------------------------------------------------------
-- File       : Kcu105DspFloatTestTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-02-15
-- Last update: 2018-02-15
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for the Kcu105DspFloatTest
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;

entity Kcu105DspFloatTestTb is end Kcu105DspFloatTestTb;

architecture testbed of Kcu105DspFloatTestTb is

   constant TPD_G : time := 2 ns;

   signal clkP : sl := '0';
   signal clkN : sl := '1';
   signal rst  : sl := '0';

begin

   U_ClkRst : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 8 ns,     -- 125 MHz
         RST_START_DELAY_G => 1 ns,
         RST_HOLD_TIME_G   => 1 us)
      port map (
         clkP => clkP,
         clkN => clkN,
         rst  => rst,
         rstL => open);

   U_Top : entity work.Kcu105DspFloatTest
      generic map (
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => true,
         BUILD_INFO_G  => BUILD_INFO_DEFAULT_SLV_C)
      port map (
         extRst  => rst,
         clk125P => clkP,
         clk125N => clkN,
         led     => open);

end testbed;
