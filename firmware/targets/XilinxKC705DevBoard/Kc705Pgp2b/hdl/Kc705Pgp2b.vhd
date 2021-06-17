-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using PGP2B Protocol
-------------------------------------------------------------------------------
-- https://www.xilinx.com/products/boards-and-kits/kc705.html
--
-- Note: Using the QSPI (not BPI) for booting from PROM.
--       J3 needs to have the jumper installed
--       SW13 needs to be in the "00001" position to set FPGA.M[2:0] = "001"
--
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kc705Pgp2b is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- LEDs and Reset button
      extRst   : in  sl;
      led      : out slv(7 downto 0);
      -- XADC Ports
      vPIn     : in  sl;
      vNIn     : in  sl;
      -- System Ports
      emcClk   : in  sl;
      -- Boot Memory Ports
      bootCsL  : out sl;
      bootMosi : out sl;
      bootMiso : in  sl;
      -- GT Pins
      gtClkP   : in  sl;
      gtClkN   : in  sl;
      gtRxP    : in  sl;
      gtRxN    : in  sl;
      gtTxP    : out sl;
      gtTxN    : out sl);
end Kc705Pgp2b;

architecture top_level of Kc705Pgp2b is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal clk : sl;
   signal rst : sl;

begin

   REAL_PGP : if (not SIMULATION_G) generate
      ------------------------
      -- PGP Core for KINTEX-7
      ------------------------
      U_PGP : entity surf.Pgp2bGtx7VarLatWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            -- External Reset
            extRst       => extRst,
            -- Clock and Reset
            pgpClk       => clk,
            pgpRst       => rst,
            -- Non VC TX Signals
            pgpTxIn      => PGP2B_TX_IN_INIT_C,
            pgpTxOut     => pgpTxOut,
            -- Non VC RX Signals
            pgpRxIn      => PGP2B_RX_IN_INIT_C,
            pgpRxOut     => pgpRxOut,
            -- Frame TX Interface
            pgpTxMasters => txMasters,
            pgpTxSlaves  => txSlaves,
            -- Frame RX Interface
            pgpRxMasters => rxMasters,
            pgpRxCtrl    => rxCtrl,
            -- GT Pins
            gtClkP       => gtClkP,
            gtClkN       => gtClkN,
            gtTxP        => gtTxP,
            gtTxN        => gtTxN,
            gtRxP        => gtRxP,
            gtRxN        => gtRxN);
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

      clk <= gtClkP;

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
         XIL_DEVICE_G => "7SERIES",
         APP_TYPE_G   => "PGP",
         AXIS_SIZE_G  => AXIS_SIZE_C)
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
   led(7) <= '0';
   led(6) <= '0';
   led(5) <= '0';
   led(4) <= '0';
   led(3) <= '1';
   led(2) <= '0';
   led(1) <= pgpTxOut.linkReady and not(rst);
   led(0) <= pgpRxOut.linkReady and not(rst);

end top_level;
