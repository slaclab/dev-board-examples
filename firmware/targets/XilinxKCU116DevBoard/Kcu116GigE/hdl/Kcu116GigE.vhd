-------------------------------------------------------------------------------
-- File       : Kcu116GigE.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using 1000BASE-SX Protocol
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
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu116GigE is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Misc. IOs
      extRst     : in  sl;
      led        : out slv(7 downto 0);
      sfpTxDisL  : out slv(3 downto 0);
      -- XADC Ports
      vPIn       : in  sl;
      vNIn       : in  sl;
      -- System Ports
      emcClk     : in  sl;
      -- Boot Memory Ports
      flashCsL   : out sl;
      flashMosi  : out sl;
      flashMiso  : in  sl;
      flashHoldL : out sl;
      flashWp    : out sl;
      -- ETH GT Pins
      ethClkP    : in  sl;
      ethClkN    : in  sl;
      ethRxP     : in  slv(3 downto 0);
      ethRxN     : in  slv(3 downto 0);
      ethTxP     : out slv(3 downto 0);
      ethTxN     : out slv(3 downto 0));
end Kcu116GigE;

architecture top_level of Kcu116GigE is

   constant AXIS_SIZE_C : positive := 1;

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   ---------------------
   -- 1 GigE XAUI Module
   ---------------------
   U_1GigE : entity surf.GigEthGtyUltraScaleWrapper
      generic map (
         TPD_G              => TPD_G,
         -- DMA/MAC Configurations
         NUM_LANE_G         => 1,
         -- QUAD PLL Configurations
         USE_GTREFCLK_G     => false,
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         DIVCLK_DIVIDE_G    => 5,       -- 31.25 MHz = (156.25 MHz/5)
         CLKFBOUT_MULT_F_G  => 32.0,    -- 1 GHz = (32 x 31.25 MHz)
         CLKOUT0_DIVIDE_F_G => 8.0,     -- 125 MHz = (1.0 GHz/8)
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac     => (others => MAC_ADDR_INIT_C),
         -- Streaming DMA Interface
         dmaClk       => (others => clk),
         dmaRst       => (others => rst),
         dmaIbMasters => rxMasters,
         dmaIbSlaves  => rxSlaves,
         dmaObMasters => txMasters,
         dmaObSlaves  => txSlaves,
         -- Misc. Signals
         extRst       => extRst,
         phyClk       => clk,
         phyRst       => rst,
         phyReady(0)  => phyReady,
         -- MGT Clock Port
         gtClkP       => ethClkP,
         gtClkN       => ethClkN,
         -- MGT Ports
         gtTxP(0)     => ethTxP(0),
         gtTxN(0)     => ethTxN(0),
         gtRxP(0)     => ethRxP(0),
         gtRxN(0)     => ethRxN(0));

   -------------------------
   -- Terminate Unused Lanes
   -------------------------
   U_UnusedGty : entity surf.Gtye4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 3)
      port map (
         refClk => clk,
         gtRxP  => ethRxP(3 downto 1),
         gtRxN  => ethRxN(3 downto 1),
         gtTxP  => ethTxP(3 downto 1),
         gtTxN  => ethTxN(3 downto 1));

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_FREQUENCY_G => 125.0E+6,
         XIL_DEVICE_G    => "ULTRASCALE",
         APP_TYPE_G      => "ETH",
         AXIS_SIZE_G     => AXIS_SIZE_C,
         DHCP_G          => true,
         IP_ADDR_G       => x"0A_02_A8_C0",  -- 192.168.2.10
         MAC_ADDR_G      => MAC_ADDR_INIT_C)
      port map (
         -- Clock and Reset
         clk              => clk,
         rst              => rst,
         -- AXIS interface
         txMasters        => txMasters,
         txSlaves         => txSlaves,
         rxMasters        => rxMasters,
         rxSlaves         => rxSlaves,
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
         flashCsL         => flashCsL,
         flashMosi        => flashMosi,
         flashMiso        => flashMiso,
         flashHoldL       => flashHoldL,
         flashWp          => flashWp);

   ----------------
   -- Misc. Signals
   ----------------
   sfpTxDisL <= x"F";
   led(7)    <= '1';
   led(6)    <= '1';
   led(5)    <= extRst;
   led(4)    <= extRst;
   led(3)    <= not(rst);
   led(2)    <= not(rst);
   led(1)    <= phyReady;
   led(0)    <= phyReady;

end top_level;
