-------------------------------------------------------------------------------
-- File       : PgpVcMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-01-30
-- Last update: 2017-08-08
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
use work.Pgp2bPkg.all;

entity PgpVcMapping is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- AXIS interface
      txMasters       : out AxiStreamMasterArray(3 downto 0);
      txSlaves        : in  AxiStreamSlaveArray(3 downto 0);
      rxMasters       : in  AxiStreamMasterArray(3 downto 0);
      rxSlaves        : out AxiStreamSlaveArray(3 downto 0);
      rxCtrl          : out AxiStreamCtrlArray(3 downto 0);
      -- PBRS Interface
      pbrsTxMaster    : in  AxiStreamMasterType;
      pbrsTxSlave     : out AxiStreamSlaveType;
      pbrsRxMaster    : out AxiStreamMasterType;
      pbrsRxSlave     : in  AxiStreamSlaveType;
      -- HLS Interface
      hlsTxMaster     : in  AxiStreamMasterType;
      hlsTxSlave      : out AxiStreamSlaveType;
      hlsRxMaster     : out AxiStreamMasterType;
      hlsRxSlave      : in  AxiStreamSlaveType;
      -- MB Interface
      mbTxMaster      : in  AxiStreamMasterType;
      mbTxSlave       : out AxiStreamSlaveType;
      -- AXI-Lite Interface
      axilWriteMaster : out AxiLiteWriteMasterType;
      axilWriteSlave  : in  AxiLiteWriteSlaveType;
      axilReadMaster  : out AxiLiteReadMasterType;
      axilReadSlave   : in  AxiLiteReadSlaveType);
end PgpVcMapping;

architecture mapping of PgpVcMapping is

   constant MB_STREAM_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 4,
      TID_BITS_C    => 4,
      TKEEP_MODE_C  => TKEEP_NORMAL_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_LAST_C);

begin

   -- VC0 RX/TX, SRPv3 Register Module    
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => SIMULATION_G,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => rxMasters(0),
         sAxisSlave       => rxSlaves(0),
         sAxisCtrl        => rxCtrl(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => txMasters(0),
         mAxisSlave       => txSlaves(0),
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => clk,
         axilRst          => rst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave);

   -- VC1 TX, PBRS
   VCTX1 : entity work.AxiStreamFifo
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 128,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => pbrsTxMaster,
         sAxisSlave  => pbrsTxSlave,
         -- Master Port
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => txMasters(1),
         mAxisSlave  => txSlaves(1));

   -- VC1 RX, PBRS
   VCRX1 : entity work.AxiStreamFifo
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => SIMULATION_G,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 128,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         -- Slave Port
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => rxMasters(1),
         sAxisSlave  => rxSlaves(1),
         sAxisCtrl   => rxCtrl(1),
         -- Master Port
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => pbrsRxMaster,
         mAxisSlave  => pbrsRxSlave);

   -- VC2 TX, HLS
   VCTX2 : entity work.AxiStreamFifo
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 128,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => hlsTxMaster,
         sAxisSlave  => hlsTxSlave,
         -- Master Port
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => txMasters(2),
         mAxisSlave  => txSlaves(2));

   -- VC2 RX, HLS
   VCRX2 : entity work.AxiStreamFifo
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => SIMULATION_G,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 128,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         -- Slave Port
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => rxMasters(2),
         sAxisSlave  => rxSlaves(2),
         sAxisCtrl   => rxCtrl(2),
         -- Master Port
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => hlsRxMaster,
         mAxisSlave  => hlsRxSlave);

   -- Terminate Unused slave AXIS
--   rxSlaves <= (others => AXI_STREAM_SLAVE_INIT_C);

   -- VC3 Microblaze
   MBTX_FIFO : entity work.AxiStreamFifo
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 128,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => MB_STREAM_CONFIG_C,
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => mbTxMaster,
         sAxisSlave  => mbTxSlave,
         -- Master Port
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => txMasters(3),
         mAxisSlave  => txSlaves(3));

   rxCtrl(3) <= AXI_STREAM_CTRL_UNUSED_C;

end mapping;
