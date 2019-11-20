-------------------------------------------------------------------------------
-- File       : Kcu105Pgp.vhd
-- Company    : SLAC National Accelerator Laboratory
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105Pgp is
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
end Kcu105Pgp;

architecture top_level of Kcu105Pgp is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal pgpRefClk     : sl;
   signal pgpRefClkDiv2 : sl;
   signal clk           : sl;
   signal rst           : sl;
   signal reset         : sl;
   signal phyReady      : sl;

begin

   REAL_PGP : if (not SIMULATION_G) generate

      U_IBUFDS_GTE3 : IBUFDS_GTE3
         generic map (
            REFCLK_EN_TX_PATH  => '0',
            REFCLK_HROW_CK_SEL => "00",  -- 2'b00: ODIV2 = O
            REFCLK_ICNTL_RX    => "00")
         port map (
            I     => pgpClkP,
            IB    => pgpClkN,
            CEB   => '0',
            ODIV2 => pgpRefClkDiv2,      -- Divide by 1
            O     => pgpRefClk);

      U_BUFG_GT : BUFG_GT
         port map (
            I       => pgpRefClkDiv2,
            CE      => '1',
            CLR     => '0',
            CEMASK  => '1',
            CLRMASK => '1',
            DIV     => "000",           -- Divide by 1
            O       => clk);

      U_PGP : entity surf.Pgp2bGthUltra
         generic map (
            TPD_G             => TPD_G,
            PAYLOAD_CNT_TOP_G => 7,
            VC_INTERLEAVE_G   => 1,
            NUM_VC_EN_G       => 4)
         port map (
            stableClk       => clk,
            stableRst       => rst,
            gtRefClk        => pgpRefClk,
            pgpGtTxP        => pgpTxP,
            pgpGtTxN        => pgpTxN,
            pgpGtRxP        => pgpRxP,
            pgpGtRxN        => pgpRxN,
            pgpTxReset      => rst,
            pgpTxClk        => clk,
            pgpTxMmcmLocked => '1',
            pgpRxReset      => rst,
            pgpRxClk        => clk,
            pgpRxMmcmLocked => '1',
            pgpTxIn         => PGP2B_TX_IN_INIT_C,
            pgpTxOut        => pgpTxOut,
            pgpRxIn         => PGP2B_RX_IN_INIT_C,
            pgpRxOut        => pgpRxOut,
            pgpTxMasters    => txMasters,
            pgpTxSlaves     => txSlaves,
            pgpRxMasters    => rxMasters,
            pgpRxCtrl       => rxCtrl);
   end generate REAL_PGP;

   SIM_PGP : if (SIMULATION_G) generate
      U_SimModel : entity surf.PgpSimModel
         generic map (
            TPD_G => TPD_G)
         port map (
            pgpTxClk     => clk,
            pgpTxClkRst  => rst,
            pgpRxClk     => clk,
            pgpRxClkRst  => rst,
            pgpTxIn      => PGP2B_TX_IN_INIT_C,
            pgpTxOut     => pgpTxOut,
            pgpRxIn      => PGP2B_RX_IN_INIT_C,
            pgpRxOut     => pgpRxOut,
            pgpTxMasters => txMasters,
            pgpTxSlaves  => txSlaves,
            pgpRxMasters => rxMasters,
            pgpRxCtrl    => rxCtrl);

      clk <= pgpClkP;

      U_PwrUpRst : entity surf.PwrUpRst
         generic map (
            TPD_G          => TPD_G,
            SIM_SPEEDUP_G  => SIM_SPEEDUP_G,
            IN_POLARITY_G  => '1',
            OUT_POLARITY_G => '1')
         port map (
            clk    => clk,
            arst   => extRst,
            rstOut => rst);

   end generate SIM_PGP;

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => "ULTRASCALE",
         APP_TYPE_G   => "PGP",
         AXIS_SIZE_G  => AXIS_SIZE_C)
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
   led(4) <= pgpTxOut.phyTxReady and not(rst);
   led(3) <= pgpRxOut.remLinkReady and not(rst);
   led(2) <= pgpRxOut.linkDown and not(rst);
   led(1) <= pgpRxOut.linkReady and not(rst);
   led(0) <= pgpRxOut.phyRxReady and not(rst);

end top_level;
