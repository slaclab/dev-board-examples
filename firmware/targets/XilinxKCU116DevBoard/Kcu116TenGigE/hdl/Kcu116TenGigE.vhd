-------------------------------------------------------------------------------
-- File       : Kcu116TenGigE.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2018-04-05
-------------------------------------------------------------------------------
-- Description: Example using 10G-BASER Protocol
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

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu116TenGigE is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Misc. IOs
      extRst    : in  sl;
      led       : out slv(7 downto 0);
      sfpTxDisL : out slv(3 downto 0);
      -- XADC Ports
      vPIn      : in  sl;
      vNIn      : in  sl;
      -- ETH GT Pins
      ethClkP   : in  sl;
      ethClkN   : in  sl;
      ethRxP    : in  slv(3 downto 0);
      ethRxN    : in  slv(3 downto 0);
      ethTxP    : out slv(3 downto 0);
      ethTxN    : out slv(3 downto 0));
end Kcu116TenGigE;

architecture top_level of Kcu116TenGigE is

   constant CLK_FREQUENCY_C : real             := 125.0E+6;
   constant IP_ADDR_C       : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10  
   constant MAC_ADDR_C      : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

   signal ethTxMaster : AxiStreamMasterType;
   signal ethTxSlave  : AxiStreamSlaveType;
   signal ethRxMaster : AxiStreamMasterType;
   signal ethRxSlave  : AxiStreamSlaveType;

   signal txMasters : AxiStreamMasterArray(3 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(3 downto 0);
   signal rxMasters : AxiStreamMasterArray(3 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal commAxilWriteMaster : AxiLiteWriteMasterType;
   signal commAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal commAxilReadMaster  : AxiLiteReadMasterType;
   signal commAxilReadSlave   : AxiLiteReadSlaveType;

   signal clk      : sl;
   signal rst      : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   -----------------
   -- 10 GigE Module
   -----------------
   U_10GigE : entity work.TenGigEthGtyUltraScaleWrapper
      generic map (
         TPD_G             => TPD_G,
         NUM_LANE_G        => 1,
         -- QUAD PLL Configurations
         QPLL_REFCLK_SEL_G => "001",
         -- AXI Streaming Configurations
         AXIS_CONFIG_G     => (0 => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac        => (others => MAC_ADDR_C),
         -- Streaming DMA Interface 
         dmaClk(0)       => clk,
         dmaRst(0)       => rst,
         dmaIbMasters(0) => ethRxMaster,
         dmaIbSlaves(0)  => ethRxSlave,
         dmaObMasters(0) => ethTxMaster,
         dmaObSlaves(0)  => ethTxSlave,
         -- Misc. Signals
         extRst       => extRst,
         coreClk      => clk,
         coreRst      => rst,
         phyReady(0)  => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
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
   U_UnusedGty : entity work.Gtye4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 3)
      port map (
         refClk => clk,
         gtRxP  => ethRxP(3 downto 1),
         gtRxN  => ethRxN(3 downto 1),
         gtTxP  => ethTxP(3 downto 1),
         gtTxN  => ethTxN(3 downto 1));

   -------------------------------------------------------------------------------------------------
   -- UDP and RSSI
   -------------------------------------------------------------------------------------------------
   U_EthUdpRssiWrapper_1 : entity work.EthUdpRssiWrapper
      generic map (
         TPD_G           => TPD_G,
         CLK_FREQUENCY_G => CLK_FREQUENCY_C,
         IP_ADDR_G       => IP_ADDR_C,
         MAC_ADDR_G      => MAC_ADDR_C,
         APP_ILEAVE_EN_G => true,
         DHCP_G          => false,
         JUMBO_G         => false)
      port map (
         clk                 => clk,                  -- [in]
         rst                 => rst,                  -- [in]
         ethTxMaster         => ethTxMaster,          -- [out]
         ethTxSlave          => ethTxSlave,           -- [in]
         ethRxMaster         => ethRxMaster,          -- [in]
         ethRxSlave          => ethRxSlave,           -- [out]
         txMasters           => txMasters,            -- [in]
         txSlaves            => txSlaves,             -- [out]
         rxMasters           => rxMasters,            -- [out]
         rxSlaves            => rxSlaves,             -- [in]
         rssiAxilWriteMaster => commAxilWriteMaster,  -- [in]
         rssiAxilWriteSlave  => commAxilWriteSlave,   -- [out]
         rssiAxilReadMaster  => commAxilReadMaster,   -- [in]
         rssiAxilReadSlave   => commAxilReadSlave);   -- [out]

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G         => TPD_G,
         BUILD_INFO_G  => BUILD_INFO_G,
         XIL_DEVICE_G  => "ULTRASCALE",
         RX_READY_EN_G => true,
         AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map (
         -- Clock and Reset
         clk                 => clk,
         rst                 => rst,
         -- AXIS interface
         txMasters           => txMasters,
         txSlaves            => txSlaves,
         rxMasters           => rxMasters,
         rxSlaves            => rxSlaves,
         -- AXIL interface for comm protocol
         commAxilWriteMaster => commAxilWriteMaster,
         commAxilWriteSlave  => commAxilWriteSlave,
         commAxilReadMaster  => commAxilReadMaster,
         commAxilReadSlave   => commAxilReadSlave,
         -- ADC Ports
         vPIn                => vPIn,
         vNIn                => vNIn);

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
