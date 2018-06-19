-------------------------------------------------------------------------------
-- File       : Kcu105Pgp3.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-03-13
-- Last update: 2018-06-19
-------------------------------------------------------------------------------
-- Description: Example using PGP2B Protocol
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

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.Pgp3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105Pgp3 is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- Misc. IOs
      extRst  : in  sl;
      led     : out slv(7 downto 0);
      -- XADC Ports
      vPIn    : in  sl;
      vNIn    : in  sl;
      -- ETH GT Pins
      pgpClkP : in  sl;
      pgpClkN : in  sl;
      pgpRxP  : in  sl;
      pgpRxN  : in  sl;
      pgpTxP  : out sl;
      pgpTxN  : out sl);
end Kcu105Pgp3;

architecture top_level of Kcu105Pgp3 is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal pgpTxOut : Pgp3TxOutType;
   signal pgpRxOut : Pgp3RxOutType;

   signal clk : sl;
   signal rst : sl;

begin

   U_Pgp : entity work.Pgp3GthUsWrapper
      generic map (
         TPD_G       => TPD_G,
         NUM_LANES_G => 1,
         NUM_VC_G    => 4)
      port map (
         -- Stable Clock and Reset
         stableClk    => clk,
         stableRst    => rst,
         -- Gt Serial IO
         pgpGtTxP(0)  => pgpTxP,
         pgpGtTxN(0)  => pgpTxN,
         pgpGtRxP(0)  => pgpRxP,
         pgpGtRxN(0)  => pgpRxN,
         -- GT Clocking
         pgpRefClkP   => pgpClkP,
         pgpRefClkN   => pgpClkN,
         -- Clocking
         pgpClk(0)    => clk,
         pgpClkRst(0) => rst,
         -- Non VC Rx Signals
         pgpRxIn(0)   => PGP3_RX_IN_INIT_C,
         pgpRxOut(0)  => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn(0)   => PGP3_TX_IN_INIT_C,
         pgpTxOut(0)  => pgpTxOut,
         -- Frame Transmit Interface
         pgpTxMasters => txMasters,
         pgpTxSlaves  => txSlaves,
         -- Frame Receive Interface
         pgpRxMasters => rxMasters,
         pgpRxCtrl    => rxCtrl);

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => "ULTRASCALE",
         AXIS_CONFIG_G => PGP3_AXIS_CONFIG_C,
         RX_READY_EN_G => false)
      port map (
         -- Clock and Reset
         clk       => clk,
         rst       => rst,
         -- AXIS interface
         txMasters => txMasters,
         txSlaves  => txSlaves,
         rxMasters => rxMasters,
         rxCtrl    => rxCtrl,
         -- ADC Ports
         vPIn      => vPIn,
         vNIn      => vNIn);

   ----------------
   -- Misc. Signals
   ----------------
   led(7) <= extRst;
   led(6) <= rst;
   led(5) <= pgpTxOut.linkReady and not(rst);
   led(4) <= pgpTxOut.phyTxActive and not(rst);
   led(3) <= pgpRxOut.remRxLinkReady and not(rst);
   led(2) <= pgpRxOut.linkDown and not(rst);
   led(1) <= pgpRxOut.linkReady and not(rst);
   led(0) <= pgpRxOut.phyRxActive and not(rst);

end top_level;
