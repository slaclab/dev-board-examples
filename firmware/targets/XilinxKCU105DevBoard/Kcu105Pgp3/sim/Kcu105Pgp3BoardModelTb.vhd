-------------------------------------------------------------------------------
-- Title      : Testbench for design "Kcu105Pgp3BoardModel"
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of dev-board-examples. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of dev-board-examples, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;

----------------------------------------------------------------------------------------------------

entity Kcu105Pgp3BoardModelTb is

end entity Kcu105Pgp3BoardModelTb;

----------------------------------------------------------------------------------------------------

architecture sim of Kcu105Pgp3BoardModelTb is

   -- component generics
   constant TPD_G             : time := 1 ns;
   constant CLK_START_DELAY_G : time := 1 ns;

   -- component ports
   signal pgp3RxP : sl;                 -- [in]
   signal pgp3RxN : sl;                 -- [in]
   signal pgp3TxP : sl;                 -- [out]
   signal pgp3TxN : sl;                 -- [out]

begin

   -- component instantiation
   U_Kcu105Pgp3BoardModel_0 : entity work.Kcu105Pgp3BoardModel
      generic map (
         TPD_G             => TPD_G,
         CLK_START_DELAY_G => 1 ns,
         RESET_RX_TIME_G => 50 us)
      port map (
         pgp3RxP => pgp3RxP,            -- [in]
         pgp3RxN => pgp3RxN,            -- [in]
         pgp3TxP => pgp3TxP,            -- [out]
         pgp3TxN => pgp3TxN);           -- [out]

   U_Kcu105Pgp3BoardModel_1 : entity work.Kcu105Pgp3BoardModel
      generic map (
         TPD_G             => TPD_G,
         CLK_START_DELAY_G => 1.111 ns,
         RESET_RX_TIME_G => 500 us)
      port map (
         pgp3RxP => pgp3TxP,            -- [in]
         pgp3RxN => pgp3TxN,            -- [in]
         pgp3TxP => pgp3RxP,            -- [out]
         pgp3TxN => pgp3RxN);           -- [out]


end architecture;

----------------------------------------------------------------------------------------------------
