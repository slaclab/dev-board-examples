-------------------------------------------------------------------------------
-- File       : NetFpgaSumeXaui.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using 10 GbE XAUI Protocol
--              https://en.wikipedia.org/wiki/XAUI
-- Note: To use this firmware build, you will need the FMC below:
-- http://www.fastertechnology.com/products/fmc/fm-s14.html
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

entity NetFpgaSumeXaui is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- 200 MHz System Ports
      sysClkP      : in  sl;
      sysClkN      : in  sl;
      -- SFP+ Control Ports
      sfpLed1      : out slv(3 downto 0);
      sfpLed0      : out slv(3 downto 0);
      sfpTxDisable : out slv(3 downto 0);
      -- XADC Ports
      vPIn         : in  sl;
      vNIn         : in  sl;
      -- ETH GT Pins (ETH1_TX_P/N)
      ethRxP       : in  slv(3 downto 0);
      ethRxN       : in  slv(3 downto 0);
      ethTxP       : out slv(3 downto 0);
      ethTxN       : out slv(3 downto 0));
end NetFpgaSumeXaui;

architecture top_level of NetFpgaSumeXaui is

   constant AXIS_SIZE_C : positive         := 1;
   constant IP_ADDR_C   : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10
   constant MAC_ADDR_C  : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal sysClock : sl;
   signal sysClk   : sl;
   signal sysRst   : sl;

   signal clk      : sl;
   signal rst      : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   -------------------
   -- Clock Generation
   -------------------
   IBUFDS_Inst : IBUFDS
      port map (
         I  => sysClkP,
         IB => sysClkN,
         O  => sysClock);

   BUFG_Inst : BUFG
      port map (
         I => sysClock,
         O => sysClk);

   PwrUpRst_Inst : entity surf.PwrUpRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => 200000000)
      port map (
         clk    => sysClk,
         rstOut => sysRst);

   ClockManager7_0 : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => false,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 5.0,     -- 200 MHz
         DIVCLK_DIVIDE_G    => 8,       -- 25 MHz = (200 MHz/8)
         CLKFBOUT_MULT_F_G  => 40.625,  -- 1.01563 GHz = (40.625 x 25 MHz)
         CLKOUT0_DIVIDE_F_G => 6.500)   -- 156.25 MHz = (1.01563 GHz/6.5)
      port map(
         clkIn     => sysClk,
         rstIn     => sysRst,
         clkOut(0) => clk,
         rstOut(0) => rst,
         locked    => open);

   ----------------------
   -- 10 GigE XAUI Module
   ----------------------
   U_XAUI : entity surf.XauiGth7Wrapper
      generic map (
         TPD_G          => TPD_G,
         -- QUAD PLL Configurations
         USE_GTREFCLK_G => true,        -- FALSE: gtRefClk
         -- AXI Streaming Configurations
         AXIS_CONFIG_G  => EMAC_AXIS_CONFIG_C)
      port map (
         -- Streaming DMA Interface
         dmaClk      => clk,
         dmaRst      => rst,
         dmaIbMaster => rxMasters(0),
         dmaIbSlave  => rxSlaves(0),
         dmaObMaster => txMasters(0),
         dmaObSlave  => txSlaves(0),
         -- Misc. Signals
         phyReady    => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtRefClk    => clk,
         -- MGT Ports
         gtTxP       => ethTxP,
         gtTxN       => ethTxN,
         gtRxP       => ethRxP,
         gtRxN       => ethRxN);

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => "7SERIES",
         APP_TYPE_G   => "ETH",
         AXIS_SIZE_G  => AXIS_SIZE_C,
         MAC_ADDR_G   => MAC_ADDR_C,
         IP_ADDR_G    => IP_ADDR_C)
      port map (
         -- Clock and Reset
         clk       => clk,
         rst       => rst,
         -- AXIS interface
         txMasters => txMasters,
         txSlaves  => txSlaves,
         rxMasters => rxMasters,
         rxSlaves  => rxSlaves,
         -- ADC Ports
         vPIn      => vPIn,
         vNIn      => vNIn);

   ----------------
   -- Misc. Signals
   ----------------
   sfpLed1(3) <= '0';
   sfpLed1(2) <= '0';
   sfpLed1(1) <= '0';
   sfpLed1(0) <= '0';

   sfpLed0(3) <= phyReady;
   sfpLed0(2) <= '0';
   sfpLed0(1) <= '0';
   sfpLed0(0) <= not(rst);

   sfpTxDisable <= (others => '0');

end top_level;
