-------------------------------------------------------------------------------
-- Title      : Testbench for design "Kcu105Pgp3"
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of Dev Board Examples. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of Dev Board Examples, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------------------------

entity Kcu105Pgp3BoardModel is

end entity Kcu105Pgp3BoardModel;

----------------------------------------------------------------------------------------------------

architecture sim of Kcu105Pgp3BoardModel is

   -- component generics
   constant TPD_G         : time    := 1 ns;
--   constant BUILD_INFO_G  : BuildInfoType;
   constant SIM_SPEEDUP_G : boolean := true;
   constant SIMULATION_G  : boolean := true;

   -- component ports
   signal extRst  : sl;                 -- [in]
   signal led     : slv(7 downto 0);    -- [out]
   signal vPIn    : sl := '0';          -- [in]
   signal vNIn    : sl := '0';          -- [in]
   signal pgpClkP : sl;                 -- [in]
   signal pgpClkN : sl;                 -- [in]
   signal pgpRxP  : sl;                 -- [in]
   signal pgpRxN  : sl;                 -- [in]
   signal pgpTxP  : sl;                 -- [out]
   signal pgpTxN  : sl;                 -- [out]
   signal pgp3RxP : sl;                 -- [in]
   signal pgp3RxN : sl;                 -- [in]
   signal pgp3TxP : sl;                 -- [out]
   signal pgp3TxN : sl;                 -- [out]

begin

   -- component instantiation
   U_Kcu105Pgp3 : entity work.Kcu105Pgp3
      generic map (
         TPD_G         => TPD_G,
--         BUILD_INFO_G  => BUILD_INFO_G,
         SIM_SPEEDUP_G => SIM_SPEEDUP_G,
         SIMULATION_G  => SIMULATION_G)
      port map (
         extRst  => extRst,             -- [in]
         led     => led,                -- [out]
         vPIn    => vPIn,               -- [in]
         vNIn    => vNIn,               -- [in]
         pgpClkP => pgpClkP,            -- [in]
         pgpClkN => pgpClkN,            -- [in]
         pgpRxP  => pgpTxP,             -- [in]
         pgpRxN  => pgpTxN,             -- [in]
         pgpTxP  => pgpTxP,             -- [out]
         pgpTxN  => pgpTxN,             -- [out]
         pgp3RxP => pgp3RxP,            -- [in]
         pgp3RxN => pgp3RxN,            -- [in]
         pgp3TxP => pgp3TxP,            -- [out]
         pgp3TxN => pgp3TxN);           -- [out]


   U_ClkRst_1 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,
         CLK_DELAY_G       => 1 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 5 us,
         SYNC_RESET_G      => true)
      port map (
         clkP => pgpClkP,
         clkN => pgpClkN,
         rst  => extRst,
         rstL => open);


end architecture sim;

----------------------------------------------------------------------------------------------------
