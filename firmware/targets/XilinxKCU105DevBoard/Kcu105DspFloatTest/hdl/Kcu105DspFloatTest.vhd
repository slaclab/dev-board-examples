-------------------------------------------------------------------------------
-- File       : Kcu105DspFloatTest.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-02-15
-- Last update: 2018-02-15
-------------------------------------------------------------------------------
-- Description: Hardware Testbed for checking VHDL-2008 DSP Float
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

--------------------------------------
-- Comment out these for simulation --
--------------------------------------
use ieee.fixed_float_types.all;
use ieee.float_pkg.all;
--------------------------------------

-- synthesis translate_off
library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.float_pkg.all;
-- synthesis translate_on

use work.StdRtlPkg.all;
use work.DspPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105DspFloatTest is
   generic (
      TPD_G         : time    := 1 ns;
      SIM_SPEEDUP_G : boolean := false;
      BUILD_INFO_G  : BuildInfoType);
   port (
      extRst  : in  sl;
      clk125P : in  sl;
      clk125N : in  sl;
      led     : out slv(7 downto 0));
end Kcu105DspFloatTest;

architecture top_level of Kcu105DspFloatTest is

   signal clock     : sl;
   signal clk       : sl;
   signal rst       : sl;
   signal heartBeat : sl;

   signal cnt : float32 := (others => '0');
   signal add : float32 := (others => '0');
   signal sub : float32 := (others => '0');

   attribute dont_touch              : string;
   attribute dont_touch of rst       : signal is "TRUE";
   attribute dont_touch of heartBeat : signal is "TRUE";
   attribute dont_touch of cnt       : signal is "TRUE";
   attribute dont_touch of add       : signal is "TRUE";
   attribute dont_touch of sub       : signal is "TRUE";

begin

   ---------------------- 
   -- Clocking and Resets
   ---------------------- 
   U_IBUFDS0 : IBUFDS
      port map (
         I  => clk125P,
         IB => clk125N,
         O  => clock);

   U_BUFG0 : BUFG
      port map (
         I => clock,
         O => clk);

   U_PwrUpRst0 : entity work.PwrUpRst
      generic map(
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => SIM_SPEEDUP_G)
      port map(
         clk    => clk,
         arst   => extRst,
         rstOut => rst);

   ----------------
   -- LED Signals
   ----------------
   led(7) <= heartBeat;
   led(6) <= heartBeat;
   led(5) <= heartBeat;
   led(4) <= heartBeat;
   led(3) <= not(rst);
   led(2) <= not(rst);
   led(1) <= '1';
   led(0) <= '1';

   U_Heartbeat : entity work.Heartbeat
      generic map(
         TPD_G       => TPD_G,
         PERIOD_IN_G => 8.0E-9)
      port map (
         clk => clk,
         o   => heartBeat);

   ----------------
   -- Testbed Logic
   ----------------         
   process(clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            cnt <= (others => '0') after TPD_G;
         else
            cnt <= cnt + FP32_POS_ONE_C after TPD_G;
         end if;
      end if;
   end process;

   U_Add : entity work.DspFp32AddSub
      generic map (
         TPD_G => TPD_G)
      port map (
         clk  => clk,
         ain  => (others => '0'),
         bin  => cnt,
         add  => '1',
         pOut => add);

   U_Sub : entity work.DspFp32AddSub
      generic map (
         TPD_G => TPD_G)
      port map (
         clk  => clk,
         ain  => (others => '0'),
         bin  => cnt,
         add  => '0',
         pOut => sub);

end top_level;
