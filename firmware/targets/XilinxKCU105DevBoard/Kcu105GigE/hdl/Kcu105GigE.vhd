-------------------------------------------------------------------------------
-- File       : Kcu105GigE.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2017-02-16
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
      SGMII_ETH_G   : boolean := false);
   port (
      -- Misc. IOs
      extRst     : in  sl;
      led        : out slv(7 downto 0);
      gpioDip    : in  slv(3 downto 0);
      -- XADC Ports
      vPIn       : in  sl;
      vNIn       : in  sl;
      -- ETH GT Pins
      ethClkP    : in  sl;
      ethClkN    : in  sl;
      ethRxP     : in  sl;
      ethRxN     : in  sl;
      ethTxP     : out sl;
      ethTxN     : out sl;
      -- SGMII (ext. PHY) ETH
      sgmiiClkP  : in  sl;
      sgmiiClkN  : in  sl;
      sgmiiRxP   : in  sl;
      sgmiiRxN   : in  sl;
      sgmiiTxP   : out sl;
      sgmiiTxN   : out sl;
      -- ETH external PHY pins
      phyMdc     : out sl;
      phyMdio    : inout sl;
      phyRstN    : out sl; -- active low
      phyIrqN    : in  sl; -- active low
      -- 300Mhz System Clock
      sysClk300P : in sl;
      sysClk300N : in sl);
end Kcu105GigE;

architecture top_level of Kcu105GigE is

   constant AXIS_SIZE_C : positive         := 1;
   constant IP_ADDR_C   : slv(31 downto 0) := x"0A02A8C0";  -- 192.168.2.10
   constant MAC_ADDR_C  : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01
   constant RST_DEL_C   : slv(23 downto 0) := X"5FFFFF"; -- 2*10ms @ 300MHz

   signal txMasters     : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves      : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters     : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves      : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal clk           : sl;
   signal rst           : sl;
   signal phyReady      : sl;

   signal phyMdo        : sl := '1';

   signal sysClk300NB   : sl;
   signal sysClk300     : sl;
   signal sysRst300     : sl;

   signal speed10_100   : sl := '0';
   signal speed100      : sl := '0';
   signal linkIsUp      : sl := '0';

   signal extPhyRstN    : sl;
   signal extPhyReady   : sl;

   signal initDone      : sl := '0';


   attribute dont_touch              : string;
   attribute dont_touch of txMasters : signal is "TRUE";
   attribute dont_touch of txSlaves  : signal is "TRUE";
   attribute dont_touch of rxMasters : signal is "TRUE";
   attribute dont_touch of rxSlaves  : signal is "TRUE";

begin

   -- 300MHz system clock
   U_SysClk300IBUFDS : IBUFDS
      generic map (
         DIFF_TERM    => FALSE,
         IBUF_LOW_PWR => FALSE
      )
      port map (
         I            => sysClk300P,
         IB           => sysClk300N,
         O            => sysClk300NB
      );

   U_SysclkBUFG : BUFG
      port map (
         I            => sysClk300NB,
         O            => sysClk300
      );

   U_SysclkRstSync : entity work.RstSync
      port map (
         clk          => sysClk300,
         asyncRst     => extRst,
         syncRst      => sysRst300
      );


   GEN_GTH : if ( not SGMII_ETH_G ) generate

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
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         DIVCLK_DIVIDE_G    => 5,       -- 31.25 MHz = (156.25 MHz/5)
         CLKFBOUT_MULT_F_G  => 32.0,    -- 1 GHz = (32 x 31.25 MHz)
         CLKOUT0_DIVIDE_F_G => 8.0,     -- 125 MHz = (1.0 GHz/8)
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac     => (others => MAC_ADDR_C),
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
         gtTxP(0)     => ethTxP,
         gtTxN(0)     => ethTxN,
         gtRxP(0)     => ethRxP,
         gtRxN(0)     => ethRxN);

   extPhyRstN <= '0';
   phyMdc     <= '0';

   end generate GEN_GTH;

   GEN_SGMII : if (SGMII_ETH_G) generate

   signal rstCnt      : slv(23 downto 0) := RST_DEL_C;
   signal phyInitRst  : sl;
   signal phyIrq      : sl;
   signal phyMdi      : sl;
   begin

   -- Main clock is derived from the PHY refclock. However,
   -- while it is in reset there is no clock coming in;
   -- thus we use the on-board clock to reset the (external) PHY.
   -- We must hold reset for >10ms and then wait >5ms until we may talk
   -- to it (we actually wait also >10ms) which is indicated by 'extPhyReady'.
   process (sysClk300)
   begin
      if ( rising_edge( sysClk300 ) ) then
         if ( sysRst300 /= '0' ) then
            rstCnt <= RST_DEL_C;
         elsif ( rstCnt(23) = '0' ) then
            rstCnt <= slv( unsigned( rstCnt ) - 1 );
         end if;
      end if;
   end process;

   extPhyReady <= rstCnt(23);

   extPhyRstN  <= ite( ( unsigned(rstCnt(22 downto 20)) > 3 ) and ( extPhyReady = '0' ), '0', '1' );

   -- The MDIO controller which talks to the external PHY must be held
   -- in reset until extPhyReady; it works in a different clock domain...

   U_PhyInitRstSync : entity work.RstSync
      generic map (
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1'
      )
      port map (
         clk            => clk,
         asyncRst       => extPhyReady,
         syncRst        => phyInitRst
      );

   -- The SaltCore does not support autonegotiation on the SGMII link
   -- (mac<->phy) - however, the marvell phy (by default) assumes it does.
   -- We need to disable auto-negotiation in the PHY on the SGMII side
   -- and handle link changes (aneg still enabled on copper) flagged
   -- by the PHY...

   U_PhyCtrl : entity work.PhyControllerCore
      generic map (
         TPD_G    => TPD_G,
         DIV_G    => 100
      )
      port map (
         clk             => clk,
         rst             => phyInitRst,
         initDone        => initDone,

         speed_is_10_100 => speed10_100,
         speed_is_100    => speed100,
         linkIsUp        => linkIsUp,

         mdi             => phyMdi,
         mdc             => phyMdc,
         mdo             => phyMdo,

         linkIrq         => phyIrq
      );

   -- synchronize MDI and IRQ signals into 'clk' domain
   U_SyncMdi : entity work.Synchronizer
      port map (
         clk       => clk,
         dataIn    => phyMdio,
         dataOut   => phyMdi
      );

   U_SyncIrq : entity work.Synchronizer
      generic map (
         OUT_POLARITY_G => '0',
         INIT_G         => "11"
      )
      port map (
         clk       => clk,
         dataIn    => phyIrqN,
         dataOut   => phyIrq
      );

   U_1GigE : entity work.GigEthLvdsUltraScaleWrapper
      generic map (
         TPD_G              => TPD_G,
         -- DMA/MAC Configurations
         NUM_LANE_G         => 1,
         -- MMCM Configuration
         USE_REFCLK_G       => false,
         CLKIN_PERIOD_G     => 1.6,     -- 625.0 MHz
         DIVCLK_DIVIDE_G    => 2,       -- 312.5 MHz
         CLKFBOUT_MULT_F_G  => 2.0,     -- VCO: 625 MHz
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac           => (others => MAC_ADDR_C),
         -- Streaming DMA Interface
         dmaClk             => (others => clk),
         dmaRst             => (others => rst),
         dmaIbMasters       => rxMasters,
         dmaIbSlaves        => rxSlaves,
         dmaObMasters       => txMasters,
         dmaObSlaves        => txSlaves,
         -- Misc. Signals
         extRst             => extRst,
         phyClk             => clk,
         phyRst             => rst,
         phyReady(0)        => phyReady,
         mmcmLocked         => open,
         speed_is_10_100(0) => speed10_100,
         speed_is_100(0)    => speed100,

         -- MGT Clock Port
         sgmiiClkP          => sgmiiClkP,
         sgmiiClkN          => sgmiiClkN,
         -- MGT Ports
         sgmiiTxP(0)        => sgmiiTxP,
         sgmiiTxN(0)        => sgmiiTxN,
         sgmiiRxP(0)        => sgmiiRxP,
         sgmiiRxN(0)        => sgmiiRxN);

   end generate GEN_SGMII;

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => "ULTRASCALE",
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
   led(7) <= linkIsUp;
   led(6) <= not speed10_100;             -- lit when 1Gb
   led(5) <= not speed10_100 or speed100; -- lit when 1Gb or 100Mb
   led(4) <= extPhyRstN;
   led(3) <= phyIrqN;
   led(2) <= initDone;
   led(1) <= phyReady;
   led(0) <= phyReady;

   -- Tri-state driver for phyMdio
   phyMdio <= 'Z' when phyMdo = '1' else '0';
   -- Reset line of the external phy
   phyRstN <= extPhyRstN;

end top_level;
