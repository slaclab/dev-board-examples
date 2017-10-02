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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Pgp3Pkg.all;


----------------------------------------------------------------------------------------------------

entity Kcu105Pgp3BoardModel is
   generic(
      TPD_G             : time := 1 ns;
      RESET_RX_TIME_G : time := 50 us;
      CLK_START_DELAY_G : time := 1 ns);
   port (
      pgp3RxP : in  sl;                 -- 
      pgp3RxN : in  sl;                 -- 
      pgp3TxP : out sl;                 -- 
      pgp3TxN : out sl);                -- 
end entity Kcu105Pgp3BoardModel;

----------------------------------------------------------------------------------------------------

architecture sim of Kcu105Pgp3BoardModel is

   signal extRst  : sl := '0';          -- 
   signal led     : slv(7 downto 0);    -- 
   signal vPIn    : sl := '0';          -- 
   signal vNIn    : sl := '0';          -- 
   signal pgpClkP : sl;                 -- 
   signal pgpClkN : sl;                 -- 
   signal pgpRxP  : sl := '0';          -- 
   signal pgpRxN  : sl := '0';          -- 
   signal pgpTxP  : sl := '0';  -- 
   signal pgpTxN  : sl := '0';          -- 


   -- component generics

   constant BUILD_INFO_G  : BuildInfoType := BUILD_INFO_DEFAULT_SLV_C;
   constant SIM_SPEEDUP_G : boolean       := true;
   constant SIMULATION_G  : boolean       := true;


begin

   -- component instantiation
   U_Kcu105Pgp3 : entity work.Kcu105Pgp3
      generic map (
         TPD_G         => TPD_G,
         RESET_RX_TIME_G => RESET_RX_TIME_G,
         BUILD_INFO_G  => BUILD_INFO_G,
         SIM_SPEEDUP_G => SIM_SPEEDUP_G,
         SIMULATION_G  => SIMULATION_G)
      port map (
--         extRst  => extRst,             -- [in]
         led     => led,                -- [out]
--          vPIn    => vPIn,               -- [in]
--          vNIn    => vNIn,               -- [in]
         pgpClkP => pgpClkP,            -- [in]
         pgpClkN => pgpClkN,            -- [in]
         pgpRxP  => pgpRxP,             -- [in]
         pgpRxN  => pgpRxN,             -- [in]
         pgpTxP  => pgpTxP,             -- [out]
         pgpTxN  => pgpTxN,             -- [out]
         pgp3RxP => pgp3RxP,            -- [in]
         pgp3RxN => pgp3RxN,            -- [in]
         pgp3TxP => pgp3TxP,            -- [out]
         pgp3TxN => pgp3TxN);           -- [out]


   U_ClkRst_1 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,
         CLK_DELAY_G       => CLK_START_DELAY_G,
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
