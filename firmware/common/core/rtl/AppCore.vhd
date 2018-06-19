-------------------------------------------------------------------------------
-- File       : AppCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-15
-- Last update: 2018-06-19
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
use work.SsiPkg.all;
use work.AxiLitePkg.all;

entity AppCore is
   generic (
      TPD_G           : time                := 1 ns;
      BUILD_INFO_G    : BuildInfoType;
      CLK_FREQUENCY_G : real                := 156.25E+6;
      XIL_DEVICE_G    : string              := "7SERIES";
      AXIS_CONFIG_G   : AxiStreamConfigType := ssiAxiStreamConfig(4);
      RX_READY_EN_G   : boolean             := true);
   port (
      -- Clock and Reset
      clk                 : in  sl;
      rst                 : in  sl;
      -- AXIS interface from host
      txMasters           : out AxiStreamMasterArray(3 downto 0);
      txSlaves            : in  AxiStreamSlaveArray(3 downto 0);
      rxMasters           : in  AxiStreamMasterArray(3 downto 0);
      rxSlaves            : out AxiStreamSlaveArray(3 downto 0);
      rxCtrl              : out AxiStreamCtrlArray(3 downto 0);
      -- AXIL interface for comm protocol config/status
      commAxilWriteMaster : out AxiLiteWriteMasterType;
      commAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      commAxilReadMaster  : out AxiLiteReadMasterType;
      commAxilReadSlave   : in  AxiLiteReadSlaveType;
      -- ADC Ports
      vPIn                : in  sl;
      vNIn                : in  sl);
end AppCore;

architecture mapping of AppCore is

   signal appAxilReadMaster  : AxiLiteReadMasterType;
   signal appAxilReadSlave   : AxiLiteReadSlaveType;
   signal appAxilWriteMaster : AxiLiteWriteMasterType;
   signal appAxilWriteSlave  : AxiLiteWriteSlaveType;

   signal prbsTxMaster : AxiStreamMasterType;
   signal prbsTxSlave  : AxiStreamSlaveType;
   signal prbsRxMaster : AxiStreamMasterType;
   signal prbsRxSlave  : AxiStreamSlaveType;

   signal hlsTxMaster : AxiStreamMasterType;
   signal hlsTxSlave  : AxiStreamSlaveType;
   signal hlsRxMaster : AxiStreamMasterType;
   signal hlsRxSlave  : AxiStreamSlaveType;

   signal mbTxMaster : AxiStreamMasterType;
   signal mbTxSlave  : AxiStreamSlaveType;

begin

   -------------------------------------------------------------------------------------------------
   -- Stream Mapping
   -------------------------------------------------------------------------------------------------
   U_StreamMapping_1 : entity work.StreamMapping
      generic map (
         TPD_G         => TPD_G,
         RX_READY_EN_G => RX_READY_EN_G,
         AXIS_CONFIG_G => AXIS_CONFIG_G)
      port map (
         clk              => clk,                 -- [in]
         rst              => rst,                 -- [in]
         txMasters        => txMasters,           -- [out]
         txSlaves         => txSlaves,            -- [in]
         rxMasters        => rxMasters,           -- [in]
         rxSlaves         => rxSlaves,            -- [out]
         rxCtrl           => rxCtrl,              -- [out]
         prbsTxMaster     => prbsTxMaster,        -- [in]
         prbsTxSlave      => prbsTxSlave,         -- [out]
         prbsRxMaster     => prbsRxMaster,        -- [out]
         prbsRxSlave      => prbsRxSlave,         -- [in]
         hlsTxMaster      => hlsTxMaster,         -- [in]
         hlsTxSlave       => hlsTxSlave,          -- [out]
         hlsRxMaster      => hlsRxMaster,         -- [out]
         hlsRxSlave       => hlsRxSlave,          -- [in]
         mbTxMaster       => mbTxMaster,          -- [in]
         mbTxSlave        => mbTxSlave,           -- [out]
         mAxilWriteMaster => appAxilWriteMaster,  -- [out]
         mAxilWriteSlave  => appAxilWriteSlave,   -- [in]
         mAxilReadMaster  => appAxilReadMaster,   -- [out]
         mAxilReadSlave   => appAxilReadSlave);   -- [in]


   -------------------
   -- AXI-Lite Modules
   -------------------
   U_Reg : entity work.AppReg
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_FREQUENCY_G => CLK_FREQUENCY_G,
         XIL_DEVICE_G    => XIL_DEVICE_G)
      port map (
         -- Clock and Reset
         clk             => clk,
         rst             => rst,
         -- SRPv3 AXI-Lite interface
         axilWriteMaster => appAxilWriteMaster,
         axilWriteSlave  => appAxilWriteSlave,
         axilReadMaster  => appAxilReadMaster,
         axilReadSlave   => appAxilReadSlave,
         -- Communication AXI-Lite Interface
         commWriteMaster => commAxilWriteMaster,
         commWriteSlave  => commAxilWriteSlave,
         commReadMaster  => commAxilReadMaster,
         commReadSlave   => commAxilReadSlave,
         -- PRBS Interface
         prbsTxMaster    => prbsTxMaster,
         prbsTxSlave     => prbsTxSlave,
         prbsRxMaster    => prbsRxMaster,
         prbsRxSlave     => prbsRxSlave,
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
