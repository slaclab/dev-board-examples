-------------------------------------------------------------------------------
-- File       : Kc705GigE.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Example using 1000BASE-SX Protocol
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
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kc705GigE is
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
end Kc705GigE;

architecture top_level of Kc705GigE is

   constant AXIS_SIZE_C : positive         := 1;
   constant IP_ADDR_C   : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10
   constant MAC_ADDR_C  : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

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
   signal phyReady : sl;

begin

   -------------------------
   -- GigE Core for KINTEX-7
   -------------------------
   U_ETH_PHY_MAC : entity surf.GigEthGtx7Wrapper
      generic map (
         TPD_G              => TPD_G,
         NUM_LANE_G         => 1,
         -- Clocking Configurations
         USE_GTREFCLK_G     => false,
         CLKIN_PERIOD_G     => 8.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 8.0,
         CLKOUT0_DIVIDE_F_G => 8.0,
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
      port map (
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
         -- MGT Ports
         gtClkP       => gtClkP,
         gtClkN       => gtClkN,
         gtTxP(0)     => gtTxP,
         gtTxN(0)     => gtTxN,
         gtRxP(0)     => gtRxP,
         gtRxN(0)     => gtRxN);

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
         AXIS_SIZE_G     => AXIS_SIZE_C,
         APP_ILEAVE_EN_G => true,
         JUMBO_G         => false,
         DHCP_G          => false,
         MAC_ADDR_G      => MAC_ADDR_C,
         IP_ADDR_G       => IP_ADDR_C)
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
   led(1) <= not(rst);
   led(0) <= phyReady;

end top_level;
