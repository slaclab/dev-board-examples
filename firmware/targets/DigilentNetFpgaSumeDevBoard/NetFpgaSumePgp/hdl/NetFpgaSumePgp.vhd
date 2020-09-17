-------------------------------------------------------------------------------
-- File       : NetFpgaSumePgp.vhd
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity NetFpgaSumePgp is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- XADC Ports
      vPIn            : in  sl;
      vNIn            : in  sl;
      -- System Ports
      FPGA_SYSCLK_P   : in  sl;
      FPGA_SYSCLK_N   : in  sl;
      -- ETH1 Control Ports
      ETH1_LED        : out slv(1 downto 0);
      ETH1_MOD_DETECT : in  sl;
      ETH1_RS         : in  slv(1 downto 0);
      ETH1_RX_LOS     : in  sl;
      ETH1_TX_DISABLE : out sl;
      ETH1_TX_FAULT   : in  sl;
      -- ETH1 MGT Ports
      ETH1_TX_P       : in  sl;
      ETH1_TX_N       : in  sl;
      ETH1_RX_P       : out sl;
      ETH1_RX_N       : out sl);
end NetFpgaSumePgp;

architecture top_level of NetFpgaSumePgp is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal sysClk : sl;
   signal clk    : sl;
   signal rst    : sl;

begin

   -------------------
   -- Clock Generation
   -------------------
   IBUFDS_Inst : IBUFDS
      port map (
         I  => FPGA_SYSCLK_P,
         IB => FPGA_SYSCLK_N,
         O  => sysClk);

   ClockManager7_0 : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 5.0,     -- 200 MHz
         DIVCLK_DIVIDE_G    => 8,       -- 25 MHz = (200 MHz/8)
         CLKFBOUT_MULT_F_G  => 40.625,  -- 1.01563 GHz = (40.625 x 25 MHz)
         CLKOUT0_DIVIDE_F_G => 6.5)     -- 156.25 MHz = (1.01563 GHz/6.5)
      port map(
         clkIn     => sysClk,
         rstIn     => '0',
         clkOut(0) => clk,
         rstOut(0) => rst,
         locked    => open);

   REAL_PGP : if (not SIMULATION_G) generate
      ------------------------
      -- PGP Core for VIRTEX-7
      ------------------------
      Pgp2bGth7VarLatWrapper_Inst : entity surf.Pgp2bGth7VarLatWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
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
            gtTxP        => ETH1_RX_P,
            gtTxN        => ETH1_RX_N,
            gtRxP        => ETH1_TX_P,
            gtRxN        => ETH1_TX_N);
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

      clk <= FPGA_SYSCLK_P;

      U_PwrUpRst : entity surf.PwrUpRst
         generic map (
            TPD_G          => TPD_G,
            SIM_SPEEDUP_G  => SIM_SPEEDUP_G,
            IN_POLARITY_G  => '1',
            OUT_POLARITY_G => '1')
         port map (
            clk    => clk,
            arst   => '1',
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
   ETH1_TX_DISABLE <= '0';
   ETH1_LED(1)     <= pgpTxOut.linkReady;
   ETH1_LED(0)     <= pgpRxOut.linkReady;

end top_level;
