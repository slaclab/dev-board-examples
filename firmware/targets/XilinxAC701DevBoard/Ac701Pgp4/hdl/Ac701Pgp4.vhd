-------------------------------------------------------------------------------
-- File       : Ac701Pgp4.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using PGPv4 Protocol
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
use surf.Pgp4Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity Ac701Pgp4 is
   generic (
      TPD_G        : time    := 1 ns;
      BUILD_INFO_G : BuildInfoType;
      SIMULATION_G : boolean := false);
   port (
      -- LEDs and Reset button
      extRst   : in  sl;
      led      : out slv(3 downto 0);
      -- XADC Ports
      vPIn     : in  sl;
      vNIn     : in  sl;
      -- System Ports
      emcClk   : in  sl;
      -- Boot Memory Ports
      bootCsL  : out sl;
      bootMosi : out sl;
      bootMiso : in  sl;
      -- MGT Clock Select
      clkSelA  : out slv(1 downto 0);
      clkSelB  : out slv(1 downto 0);
      -- GT Pins
      gtClkP   : in  sl;
      gtClkN   : in  sl;
      gtRxP    : in  sl;
      gtRxN    : in  sl;
      gtTxP    : out sl;
      gtTxN    : out sl);
end Ac701Pgp4;

architecture top_level of Ac701Pgp4 is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal pgpTxOut : Pgp4TxOutType;
   signal pgpRxOut : Pgp4RxOutType;

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal clk : sl;
   signal rst : sl;

   signal stableClk : sl;
   signal stableRst : sl;


begin

   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => stableClk,
         rstOut => stableRst);

   -----------------------
   -- PGP Core for ARTIX-7
   -----------------------
   U_PGP : entity surf.Pgp4Gtp7Wrapper
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => SIMULATION_G,
         ROGUE_SIM_PORT_NUM_G => 9000,
         NUM_LANES_G          => 1,
         NUM_VC_G             => 4,
         SPEED_GRADE_G        => 2,
         RATE_G               => "6.25Gbps",
         REFCLK_FREQ_G        => 125.0E+6)
      port map (
         -- Stable Clock and Reset
         stableClk         => stableClk,
         stableRst         => stableRst,
         -- Gt Serial IO
         pgpGtTxP(0)       => gtTxP,
         pgpGtTxN(0)       => gtTxN,
         pgpGtRxP(0)       => gtRxP,
         pgpGtRxN(0)       => gtRxN,
         -- GT Clocking
         pgpRefClkP        => gtClkP,
         pgpRefClkN        => gtClkN,
         pgpRefClkDiv2Bufg => stableClk,
         -- Clocking
         pgpClk(0)         => clk,
         pgpClkRst(0)      => rst,
         -- Non VC TX Signals
         pgpTxIn(0)        => PGP4_TX_IN_INIT_C,
         pgpTxOut(0)       => pgpTxOut,
         -- Non VC RX Signals
         pgpRxIn(0)        => PGP4_RX_IN_INIT_C,
         pgpRxOut(0)       => pgpRxOut,
         -- Frame Transmit Interface
         pgpTxMasters      => txMasters,
         pgpTxSlaves       => txSlaves,
         -- Frame Receive Interface
         pgpRxMasters      => rxMasters,
         pgpRxCtrl         => rxCtrl);

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         XIL_DEVICE_G    => "7SERIES",
         APP_TYPE_G      => "PGP4",
         CLK_FREQUENCY_G => (6.25E+9/64.0),
         AXIS_SIZE_G     => AXIS_SIZE_C)
      port map (
         -- Clock and Reset
         clk              => clk,
         rst              => rst,
         -- AXIS interface
         txMasters        => txMasters,
         txSlaves         => txSlaves,
         rxMasters        => rxMasters,
         rxCtrl           => rxCtrl,
         -- BOOT Prom Interface
         bootWriteMasters => bootWriteMasters,
         bootWriteSlaves  => bootWriteSlaves,
         bootReadMasters  => bootReadMasters,
         bootReadSlaves   => bootReadSlaves,
         -- ADC Ports
         vPIn             => vPIn,
         vNIn             => vNIn);

   ------------
   -- BOOT PROM
   ------------
   U_BootProm : entity work.BootProm
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI-Lite Interface
         axilClk          => clk,
         axilRst          => rst,
         axilWriteMasters => bootWriteMasters,
         axilWriteSlaves  => bootWriteSlaves,
         axilReadMasters  => bootReadMasters,
         axilReadSlaves   => bootReadSlaves,
         -- System Ports
         emcClk           => emcClk,
         -- Boot Memory Ports
         bootCsL          => bootCsL,
         bootMosi         => bootMosi,
         bootMiso         => bootMiso);

   ----------------
   -- Misc. Signals
   ----------------
   clkSelA <= "00";
   clkSelB <= "00";

   led(3) <= pgpTxOut.linkReady and not(stableRst);
   led(2) <= pgpRxOut.linkReady and not(stableRst);
   led(1) <= pgpRxOut.remRxLinkReady and not(stableRst);
   led(0) <= pgpRxOut.phyRxActive and not(stableRst);

end top_level;
