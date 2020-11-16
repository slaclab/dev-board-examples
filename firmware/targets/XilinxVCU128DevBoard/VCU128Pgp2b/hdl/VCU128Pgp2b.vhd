-------------------------------------------------------------------------------
-- File       : VCU128Pgp2b.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using PGP2b Protocol
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

entity VCU128Pgp2b is
   generic (
      TPD_G        : time    := 1 ns;
      BUILD_INFO_G : BuildInfoType;
      SIMULATION_G : boolean := false);
   port (
      -- Misc. IOs
      extRst      : in  sl;
      led         : out slv(7 downto 0);
      -- XADC Ports
      vPIn        : in  sl;
      vNIn        : in  sl;
      -- QSFP[3:0] Ports
      qsfpRstL    : out slv(3 downto 0);
      qsfpLpMode  : out slv(3 downto 0);
      qsfpModSelL : out slv(3 downto 0);
      qsfpModPrsL : in  slv(3 downto 0);
      qsfpRefClkP : in  slv(3 downto 0);
      qsfpRefClkN : in  slv(3 downto 0);
      qsfpRxP     : in  slv(15 downto 0);
      qsfpRxN     : in  slv(15 downto 0);
      qsfpTxP     : out slv(15 downto 0);
      qsfpTxN     : out slv(15 downto 0));
end VCU128Pgp2b;

architecture top_level of VCU128Pgp2b is

   constant AXIS_SIZE_C : positive := 4;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxCtrl    : AxiStreamCtrlArray(AXIS_SIZE_C-1 downto 0);

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal pgpTxOut : Pgp2bTxOutType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal pgpRefClk     : sl;
   signal pgpRefClkDiv2 : sl;
   signal clk           : sl;
   signal rst           : sl;
   signal rstL          : sl;
   signal ledInt        : slv(7 downto 0);

   attribute dont_touch             : string;
   attribute dont_touch of clk : signal is "TRUE";
   attribute dont_touch of rst : signal is "TRUE";
   attribute dont_touch of rstL : signal is "TRUE";
   attribute dont_touch of ledInt   : signal is "TRUE";
   attribute dont_touch of pgpTxOut : signal is "TRUE";
   attribute dont_touch of pgpRxOut : signal is "TRUE";

begin

   REAL_PGP : if (not SIMULATION_G) generate

      U_IBUFDS : IBUFDS_GTE4
         generic map (
            REFCLK_EN_TX_PATH  => '0',
            REFCLK_HROW_CK_SEL => "00",  -- 2'b00: ODIV2 = O
            REFCLK_ICNTL_RX    => "00")
         port map (
            I     => qsfpRefClkP(0),
            IB    => qsfpRefClkN(0),
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

      U_PGP : entity surf.Pgp2bGtyUltra
         generic map (
            TPD_G             => TPD_G,
            PAYLOAD_CNT_TOP_G => 7,
            VC_INTERLEAVE_G   => 1,
            NUM_VC_EN_G       => 4)
         port map (
            stableClk       => clk,
            stableRst       => rst,
            gtRefClk        => pgpRefClk,
            pgpGtTxP        => qsfpTxP(0),
            pgpGtTxN        => qsfpTxN(0),
            pgpGtRxP        => qsfpRxP(0),
            pgpGtRxN        => qsfpRxN(0),
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

      -------------------------
      -- Terminate Unused Lanes
      -------------------------
      U_UnusedGty : entity surf.Gtye4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 15)
         port map (
            refClk => clk,
            gtRxP  => qsfpRxP(15 downto 1),
            gtRxN  => qsfpRxN(15 downto 1),
            gtTxP  => qsfpTxP(15 downto 1),
            gtTxN  => qsfpTxN(15 downto 1));

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

      clk <= qsfpRefClkP(0);

   end generate SIM_PGP;

   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G          => TPD_G,
         SIM_SPEEDUP_G  => SIMULATION_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map (
         clk    => clk,
         arst   => extRst,
         rstOut => rst);

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
         axilReadSlaves   => bootReadSlaves);

   ----------------
   -- Misc. Signals
   ----------------
   led       <= ledInt;
   ledInt(7) <= extRst;
   ledInt(6) <= rst;
   ledInt(5) <= pgpTxOut.linkReady and not(rst);
   ledInt(4) <= pgpTxOut.phyTxReady and not(rst);
   ledInt(3) <= pgpRxOut.remLinkReady and not(rst);
   ledInt(2) <= pgpRxOut.linkDown and not(rst);
   ledInt(1) <= pgpRxOut.linkReady and not(rst);
   ledInt(0) <= pgpRxOut.phyRxReady and not(rst);

   rstL        <= not(rst);
   qsfpRstL    <= (others => rstL);
   qsfpLpMode  <= (others => '0');
   qsfpModSelL <= (others => '1');

end top_level;
