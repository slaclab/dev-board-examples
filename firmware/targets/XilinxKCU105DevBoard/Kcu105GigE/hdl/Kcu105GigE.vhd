-------------------------------------------------------------------------------
-- File       : Kcu105GigE.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2019-04-02
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
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105GigE is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false;
      SGMII_ETH_G   : integer := 0);
   port (
      -- Misc. IOs
      extRst     : in    sl;
      led        : out   slv(7 downto 0);
      gpioDip    : in    slv(3 downto 0);
      -- XADC Ports
      vPIn       : in    sl;
      vNIn       : in    sl;
      -- ETH GT Pins
      ethClkP    : in    sl;
      ethClkN    : in    sl;
      ethRxP     : in    sl;
      ethRxN     : in    sl;
      ethTxP     : out   sl;
      ethTxN     : out   sl;
      -- ETH external PHY pins
      phyMdc     : out   sl;
      phyMdio    : inout sl;
      phyRstN    : out   sl;            -- active low
      phyIrqN    : in    sl;            -- active low
      -- 300Mhz System Clock
      sysClk300P : in    sl;
      sysClk300N : in    sl);
end Kcu105GigE;

architecture top_level of Kcu105GigE is

   constant AXIS_SIZE_C       : positive                         := 1;
   constant ETH_AXIS_CONFIG_C : AxiStreamConfigArray(3 downto 0) := (others => EMAC_AXIS_CONFIG_C);

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal phyReady : sl;

   signal sysClk300NB : sl;
   signal sysClk300   : sl;
   signal sysRst300   : sl;

   signal speed1000 : sl := '0';
   signal speed100  : sl := '0';
   signal speed10   : sl := '0';
   signal linkUp    : sl := '0';

   attribute dont_touch              : string;
   attribute dont_touch of txMasters : signal is "TRUE";
   attribute dont_touch of txSlaves  : signal is "TRUE";
   attribute dont_touch of rxMasters : signal is "TRUE";
   attribute dont_touch of rxSlaves  : signal is "TRUE";

begin

   -- 300MHz system clock
   U_SysClk300IBUFDS : IBUFDS
      generic map (
         DIFF_TERM    => false,
         IBUF_LOW_PWR => false)
      port map (
         I  => sysClk300P,
         IB => sysClk300N,
         O  => sysClk300NB);

   U_SysclkBUFG : BUFG
      port map (
         I => sysClk300NB,
         O => sysClk300);

   U_SysclkRstSync : entity work.RstSync
      port map (
         clk      => sysClk300,
         asyncRst => extRst,
         syncRst  => sysRst300);

   GEN_GTH : if (SGMII_ETH_G = 0) generate

      ---------------------
      -- 1 GigE XAUI Module
      ---------------------
      U_1GigE : entity work.GigEthGthUltraScaleWrapper
         generic map (
            TPD_G              => TPD_G,
            -- DMA/MAC Configurations
            NUM_LANE_G         => 1,
            -- QUAD PLL Configurations
            USE_GTREFCLK_G     => false,
            CLKIN_PERIOD_G     => 6.4,   -- 156.25 MHz
            DIVCLK_DIVIDE_G    => 5,     -- 31.25 MHz = (156.25 MHz/5)
            CLKFBOUT_MULT_F_G  => 32.0,  -- 1 GHz = (32 x 31.25 MHz)
            CLKOUT0_DIVIDE_F_G => 8.0,   -- 125 MHz = (1.0 GHz/8)
            -- AXI Streaming Configurations
            AXIS_CONFIG_G      => ETH_AXIS_CONFIG_C)
         port map (
            -- Local Configurations
            localMac(0)  => MAC_ADDR_INIT_C,
            -- Streaming DMA Interface
            dmaClk(0)    => clk,
            dmaRst(0)    => rst,
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
            gtTxP(0)     => ethTxP,
            gtTxN(0)     => ethTxN,
            gtRxP(0)     => ethRxP,
            gtRxN(0)     => ethRxN);

   end generate GEN_GTH;

   GEN_SGMII : if (SGMII_ETH_G /= 0) generate
      U_MarvelWrap : entity work.Sgmii88E1111LvdsUltraScale
         generic map (
            TPD_G             => TPD_G,
            STABLE_CLK_FREQ_G => 300.0E+6,
            AXIS_CONFIG_G     => ETH_AXIS_CONFIG_C(0))
         port map (
            -- clock and reset
            extRst      => extRst,
            stableClk   => sysClk300,
            phyClk      => clk,
            phyRst      => rst,
            -- Local Configurations/status
            localMac    => MAC_ADDR_INIT_C,
            phyReady    => phyReady,
            linkUp      => linkUp,
            speed10     => speed10,
            speed100    => speed100,
            speed1000   => speed1000,
            -- Interface to Ethernet Media Access Controller (MAC)
            macClk      => clk,
            macRst      => rst,
            obMacMaster => rxMasters(0),
            obMacSlave  => rxSlaves(0),
            ibMacMaster => txMasters(0),
            ibMacSlave  => txSlaves(0),
            -- ETH external PHY Ports
            phyClkP     => ethClkP,
            phyClkN     => ethClkN,
            phyMdc      => phyMdc,
            phyMdio     => phyMdio,
            phyRstN     => phyRstN,
            phyIrqN     => phyIrqN,
            -- LVDS SGMII Ports
            sgmiiTxP    => ethTxP,
            sgmiiTxN    => ethTxN,
            sgmiiRxP    => ethRxP,
            sgmiiRxN    => ethRxN);
   end generate GEN_SGMII;

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
         DHCP_G          => false,
         IP_ADDR_G       => x"0A_02_A8_C0",  -- 192.168.2.10
         MAC_ADDR_G      => MAC_ADDR_INIT_C)
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
   led(7) <= linkUp;
   led(6) <= speed1000;
   led(5) <= speed100;
   led(4) <= speed100;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;

end top_level;
