-------------------------------------------------------------------------------
-- File       : Kc705Xaui.vhd
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

entity Kc705Xaui is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- Misc. Ports
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
      -- ETH Ports
      ethClkP         : in  sl;
      ethClkN         : in  sl;
      ethRxP          : in  slv(3 downto 0);
      ethRxN          : in  slv(3 downto 0);
      ethTxP          : out slv(3 downto 0);
      ethTxN          : out slv(3 downto 0));       
end Kc705Xaui;

architecture top_level of Kc705Xaui is

   constant AXIS_SIZE_C : positive         := 1;
   constant IP_ADDR_C   : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10  
   constant MAC_ADDR_C  : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

   signal txMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);
   signal rxMasters : AxiStreamMasterArray(AXIS_SIZE_C-1 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(AXIS_SIZE_C-1 downto 0);

   signal clk      : sl;
   signal rst      : sl;
   signal reset    : sl;
   signal phyReady : sl;

begin

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => clk,
         rstOut => reset);

   ----------------------
   -- 10 GigE XAUI Module
   ----------------------
   U_XAUI : entity surf.XauiGtx7Wrapper
      generic map (
         TPD_G          => TPD_G,
         -- QUAD PLL Configurations
         USE_GTREFCLK_G => false,       -- FALSE: gtClkP/N
         REFCLK_DIV2_G  => true,        -- TRUE: gtClkP/N = 312.5 MHz
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
