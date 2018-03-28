-------------------------------------------------------------------------------
-- File       : AppCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-15
-- Last update: 2018-03-28
-------------------------------------------------------------------------------
-- Description:
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

entity AppCore is
   generic (
      TPD_G        : time             := 1 ns;
      BUILD_INFO_G : BuildInfoType;
      XIL_DEVICE_G : string           := "7SERIES";
      APP_TYPE_G   : string           := "ETH";
      AXIS_SIZE_G  : positive         := 1;
      MAC_ADDR_G   : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)
      IP_ADDR_G    : slv(31 downto 0) := x"0A02A8C0";  -- 192.168.2.10 (ETH only)
      DHCP_G       : boolean          := true;
      JUMBO_G      : boolean          := false);
   port (
      -- Clock and Reset
      clk       : in  sl;
      rst       : in  sl;
      -- AXIS interface
      txMasters : out AxiStreamMasterArray(AXIS_SIZE_G-1 downto 0);
      txSlaves  : in  AxiStreamSlaveArray(AXIS_SIZE_G-1 downto 0);
      rxMasters : in  AxiStreamMasterArray(AXIS_SIZE_G-1 downto 0);
      rxSlaves  : out AxiStreamSlaveArray(AXIS_SIZE_G-1 downto 0);
      rxCtrl    : out AxiStreamCtrlArray(AXIS_SIZE_G-1 downto 0);
      -- ADC Ports
      vPIn      : in  sl;
      vNIn      : in  sl);
end AppCore;

architecture mapping of AppCore is

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal commReadMaster  : AxiLiteReadMasterType;
   signal commReadSlave   : AxiLiteReadSlaveType;
   signal commWriteMaster : AxiLiteWriteMasterType;
   signal commWriteSlave  : AxiLiteWriteSlaveType;

   signal pbrsTxMaster : AxiStreamMasterType;
   signal pbrsTxSlave  : AxiStreamSlaveType;
   signal pbrsRxMaster : AxiStreamMasterType;
   signal pbrsRxSlave  : AxiStreamSlaveType;

   signal hlsTxMaster : AxiStreamMasterType;
   signal hlsTxSlave  : AxiStreamSlaveType;
   signal hlsRxMaster : AxiStreamMasterType;
   signal hlsRxSlave  : AxiStreamSlaveType;

   signal mbTxMaster : AxiStreamMasterType;
   signal mbTxSlave  : AxiStreamSlaveType;

begin

   assert ((APP_TYPE_G = "ETH") or (APP_TYPE_G = "PGP") or (APP_TYPE_G = "PGP3"))
      report "APP_TYPE_G must be ETH or PGP or PGP3" severity error;

   --------------------------
   -- UDP Port Mapping Module
   --------------------------
   GEN_ETH : if (APP_TYPE_G = "ETH") generate
      U_EthPortMapping : entity work.EthPortMapping
         generic map (
            TPD_G      => TPD_G,
            MAC_ADDR_G => MAC_ADDR_G,
            IP_ADDR_G  => IP_ADDR_G,
            DHCP_G     => DHCP_G,
            JUMBO_G    => JUMBO_G)
         port map (
            -- Clock and Reset
            clk              => clk,
            rst              => rst,
            -- AXIS interface
            txMaster         => txMasters(0),
            txSlave          => txSlaves(0),
            rxMaster         => rxMasters(0),
            rxSlave          => rxSlaves(0),
            rxCtrl           => rxCtrl(0),
            -- PBRS Interface
            pbrsTxMaster     => pbrsTxMaster,
            pbrsTxSlave      => pbrsTxSlave,
            pbrsRxMaster     => pbrsRxMaster,
            pbrsRxSlave      => pbrsRxSlave,
            -- HLS Interface
            hlsTxMaster      => hlsTxMaster,
            hlsTxSlave       => hlsTxSlave,
            hlsRxMaster      => hlsRxMaster,
            hlsRxSlave       => hlsRxSlave,
            -- Microblaze stream
            mbTxMaster       => mbTxMaster,
            mbTxSlave        => mbTxSlave,
            -- SRPv3 Master AXI-Lite Interface
            mAxilWriteMaster => axilWriteMaster,
            mAxilWriteSlave  => axilWriteSlave,
            mAxilReadMaster  => axilReadMaster,
            mAxilReadSlave   => axilReadSlave,
            -- Communication Slave AXI-Lite Interface
            commWriteMaster  => commWriteMaster,
            commWriteSlave   => commWriteSlave,
            commReadMaster   => commReadMaster,
            commReadSlave    => commReadSlave);
   end generate;

   ---------------------------------
   -- Virtual Channel Mapping Module
   ---------------------------------
   GEN_PGP : if (APP_TYPE_G = "PGP") or (APP_TYPE_G = "PGP3") generate
      U_PgpVcMapping : entity work.PgpVcMapping
         generic map (
            TPD_G      => TPD_G,
            APP_TYPE_G => APP_TYPE_G)
         port map (
            -- Clock and Reset
            clk              => clk,
            rst              => rst,
            -- AXIS interface
            txMasters        => txMasters,
            txSlaves         => txSlaves,
            rxMasters        => rxMasters,
            rxSlaves         => rxSlaves,
            rxCtrl           => rxCtrl,
            -- PBRS Interface
            pbrsTxMaster     => pbrsTxMaster,
            pbrsTxSlave      => pbrsTxSlave,
            pbrsRxMaster     => pbrsRxMaster,
            pbrsRxSlave      => pbrsRxSlave,
            -- HLS Interface
            hlsTxMaster      => hlsTxMaster,
            hlsTxSlave       => hlsTxSlave,
            hlsRxMaster      => hlsRxMaster,
            hlsRxSlave       => hlsRxSlave,
            -- Microblaze stream
            mbTxMaster       => mbTxMaster,
            mbTxSlave        => mbTxSlave,
            -- SRPv3 Master AXI-Lite Interface
            mAxilWriteMaster => axilWriteMaster,
            mAxilWriteSlave  => axilWriteSlave,
            mAxilReadMaster  => axilReadMaster,
            mAxilReadSlave   => axilReadSlave,
            -- Communication Slave AXI-Lite Interface
            commWriteMaster  => commWriteMaster,
            commWriteSlave   => commWriteSlave,
            commReadMaster   => commReadMaster,
            commReadSlave    => commReadSlave);
   end generate;

   -------------------
   -- AXI-Lite Modules
   -------------------
   U_Reg : entity work.AppReg
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         -- Clock and Reset
         clk             => clk,
         rst             => rst,
         -- SRPv3 AXI-Lite interface
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         -- Communication AXI-Lite Interface
         commWriteMaster  => commWriteMaster,
         commWriteSlave   => commWriteSlave,
         commReadMaster   => commReadMaster,
         commReadSlave    => commReadSlave,      
         -- PBRS Interface
         pbrsTxMaster    => pbrsTxMaster,
         pbrsTxSlave     => pbrsTxSlave,
         pbrsRxMaster    => pbrsRxMaster,
         pbrsRxSlave     => pbrsRxSlave,
         -- HLS Interface
         hlsTxMaster     => hlsTxMaster,
         hlsTxSlave      => hlsTxSlave,
         hlsRxMaster     => hlsRxMaster,
         hlsRxSlave      => hlsRxSlave,
         -- Microblaze stream
         mbTxMaster      => mbTxMaster,
         mbTxSlave       => mbTxSlave,
         -- ADC Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

end mapping;
