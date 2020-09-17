-------------------------------------------------------------------------------
-- File       : StaticDesign.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simple Partial Reconfiguration Example
--              with LedRtlA & LedRtlB blinking at 1 Hz rate
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

library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity StaticDesign is
   port (
      clkP : in  sl;
      clkN : in  sl;
      led  : out slv(7 downto 0));
end StaticDesign;

architecture top_level of StaticDesign is

   -- Declare the Reconfigurable RTL as a black box
   -- and don't include its RTL file (.vhd or .v)
   -- during the initial synthesis process
   component LedRtlA
      port (
         clk : in  sl;
         cnt : in  slv(31 downto 0);
         led : out sl);
   end component;
   component LedRtlB
      port (
         clk : in  sl;
         cnt : in  slv(31 downto 0);
         led : out sl);
   end component;
   attribute BLACK_BOX                : string;
   attribute BLACK_BOX of LedRtlA : component is "TRUE";
   attribute BLACK_BOX of LedRtlB : component is "TRUE";

   -- Signals
   signal clk : sl;
   signal testPointA : sl;
   signal testPointB : sl;
   signal cnt : slv(31 downto 0) := (others => '0');

begin

   -- Reference Clock
   U_IBUFGDS : IBUFGDS
      port map (
         I  => clkP,
         IB => clkN,
         O  => clk);

   -- Static RTL Core
   U_CntRtl : entity work.CntRtl
      port map (
         clk => clk,
         cnt => cnt);

   -- Reconfigurable RTL Core
   U_LedRtlA : LedRtlA
      port map (
         clk => clk,
         cnt => cnt,
         led => testPointA);

   -- Reconfigurable RTL Core
   U_LedRtlB : LedRtlB
      port map (
         clk => clk,
         cnt => cnt,
         led => testPointB);

   -- Misc.
   led <= x"8" & "00" & testPointB & testPointA;

end top_level;
