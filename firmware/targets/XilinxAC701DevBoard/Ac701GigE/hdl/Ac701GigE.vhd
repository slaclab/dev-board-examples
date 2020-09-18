-------------------------------------------------------------------------------
-- File       : Ac701GigE.vhd
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

entity Ac701GigE is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
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
      gtRxP    : in  slv(1 downto 0);
      gtRxN    : in  slv(1 downto 0);
      gtTxP    : out slv(1 downto 0);
      gtTxN    : out slv(1 downto 0));
end Ac701GigE;

architecture top_level of Ac701GigE is

   signal txMasters : AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal txSlaves  : AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal rxMasters : AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves  : AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal bootReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal bootReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal bootWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal bootWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal phyReady : slv(1 downto 0);
   signal dmaClk   : slv(1 downto 0);
   signal dmaRst   : slv(1 downto 0);

begin

   ------------------------
   -- GigE Core for ARTIX-7
   ------------------------
   U_ETH_PHY_MAC : entity surf.GigEthGtp7Wrapper
      generic map (
         TPD_G              => TPD_G,
         NUM_LANE_G         => 2,
         -- Clocking Configurations
         USE_GTREFCLK_G     => false,
         CLKIN_PERIOD_G     => 8.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 8.0,
         CLKOUT0_DIVIDE_F_G => 8.0,
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (0 => EMAC_AXIS_CONFIG_C, 1 => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac     => (others => MAC_ADDR_INIT_C),
         -- Streaming DMA Interface
         dmaClk       => dmaClk,
         dmaRst       => dmaRst,
         dmaIbMasters => rxMasters,
         dmaIbSlaves  => rxSlaves,
         dmaObMasters => txMasters,
         dmaObSlaves  => txSlaves,
         -- Misc. Signals
         extRst       => extRst,
         ethClk125    => clk,
         ethRst125    => rst,
         phyReady     => phyReady,
         -- MGT Ports
         gtClkP       => gtClkP,
         gtClkN       => gtClkN,
         gtTxP        => gtTxP,
         gtTxN        => gtTxN,
         gtRxP        => gtRxP,
         gtRxN        => gtRxN);

   dmaClk <= (others => clk);
   dmaRst <= (others => rst);

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_FREQUENCY_G => 125.0E+6,
         XIL_DEVICE_G    => "7SERIES",
         APP_TYPE_G      => "ETH",
         AXIS_SIZE_G     => 1,
         DHCP_G          => false,
         IP_ADDR_G       => x"0A_02_A8_C0",  -- 192.168.2.10
         MAC_ADDR_G      => MAC_ADDR_INIT_C)
      port map (
         -- Clock and Reset
         clk              => clk,
         rst              => rst,
         -- AXIS interface
         txMasters        => txMasters(0 downto 0),
         txSlaves         => txSlaves(0 downto 0),
         rxMasters        => rxMasters(0 downto 0),
         rxSlaves         => rxSlaves(0 downto 0),
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
   led(3)  <= '1';
   led(2)  <= not(rst);
   led(1)  <= phyReady(1);
   led(0)  <= phyReady(0);

end top_level;
