-------------------------------------------------------------------------------
-- File       : Kcu105Xaui.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2018-06-19
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

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105Xaui is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- Misc. IOs
      fmcLed          : out slv(3 downto 0);
      fmcSfpLossL     : in  slv(3 downto 0);
      fmcTxFault      : in  slv(3 downto 0);
      fmcSfpTxDisable : out slv(3 downto 0);
      fmcSfpRateSel   : out slv(3 downto 0);
      fmcSfpModDef0   : out slv(3 downto 0);
      extRst          : in  sl;
      led             : out slv(7 downto 0);
      -- XADC Ports
      vPIn            : in  sl;
      vNIn            : in  sl;
      -- ETH GT Pins
      ethClkP         : in  sl;
      ethClkN         : in  sl;
      ethRxP          : in  slv(3 downto 0);
      ethRxN          : in  slv(3 downto 0);
      ethTxP          : out slv(3 downto 0);
      ethTxN          : out slv(3 downto 0));
end Kcu105Xaui;

architecture top_level of Kcu105Xaui is

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
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => clk,
         rstOut => reset);

   ----------------------
   -- 10 GigE XAUI Module
   ----------------------
   U_XAUI : entity work.XauiGthUltraScaleWrapper
      generic map (
         TPD_G         => TPD_G,
         -- AXI Streaming Configurations
         AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map (
         -- Streaming DMA Interface 
         dmaClk      => clk,
         dmaRst      => rst,
         dmaIbMaster => ethRxMaster,
         dmaIbSlave  => ethRxSlave,
         dmaObMaster => ethTxMaster,
         dmaObSlave  => ethTxSlave,
         -- Misc. Signals
         extRst      => reset,
         phyClk      => clk,
         phyRst      => rst,
         phyReady    => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP      => ethClkP,
         gtClkN      => ethClkN,
         -- MGT Ports
         gtTxP       => ethTxP,
         gtTxN       => ethTxN,
         gtRxP       => ethRxP,
         gtRxN       => ethRxN);

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
   led(7) <= phyReady;
   led(6) <= phyReady;
   led(5) <= phyReady;
   led(4) <= phyReady;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;

   fmcLed          <= not(fmcSfpLossL);
   fmcSfpTxDisable <= (others => '0');
   fmcSfpRateSel   <= (others => '1');
   fmcSfpModDef0   <= (others => '0');

end top_level;
