-------------------------------------------------------------------------------
-- File       : EthPortMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-01-30
-- Last update: 2018-01-31
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
use work.EthMacPkg.all;

entity EthPortMapping is
   generic (
      TPD_G           : time             := 1 ns;
      CLK_FREQUENCY_G : real             := 125.0E+6;
      MAC_ADDR_G      : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)   
      IP_ADDR_G       : slv(31 downto 0) := x"0A02A8C0";  -- 192.168.2.10 (ETH only)
      DHCP_G          : boolean          := true;
      JUMBO_G         : boolean          := false);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- ETH interface
      txMaster        : out AxiStreamMasterType;
      txSlave         : in  AxiStreamSlaveType;
      rxMaster        : in  AxiStreamMasterType;
      rxSlave         : out AxiStreamSlaveType;
      rxCtrl          : out AxiStreamCtrlType;
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
end EthPortMapping;

architecture mapping of EthPortMapping is

   constant MB_STREAM_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 4,
      TID_BITS_C    => 4,
      TKEEP_MODE_C  => TKEEP_NORMAL_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_LAST_C);

   constant NUM_SERVERS_C  : integer                                 := 1;
   constant SERVER_PORTS_C : PositiveArray(NUM_SERVERS_C-1 downto 0) := (0 => 8192);

   constant RSSI_SIZE_C : positive := 4;
   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (
      0 => ssiAxiStreamConfig(4),
      1 => ssiAxiStreamConfig(4),
      2 => ssiAxiStreamConfig(4),
      3 => MB_STREAM_CONFIG_C);

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

   signal rssiIbMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiIbSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);

begin

   ----------------------
   -- IPv4/ARP/UDP Engine
   ----------------------
   U_UDP : entity work.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => NUM_SERVERS_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false,
         -- General IPv4/ARP/DHCP Generics
         DHCP_G         => DHCP_G,
         CLK_FREQ_G     => CLK_FREQUENCY_G,
         COMM_TIMEOUT_G => 30)
      port map (
         -- Local Configurations
         localMac        => MAC_ADDR_G,
         localIp         => IP_ADDR_G,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => rxMaster,
         obMacSlave      => rxSlave,
         ibMacMaster     => txMaster,
         ibMacSlave      => txSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => clk,
         rst             => rst);

   ------------------------------------------
   -- Software's RSSI Server Interface @ 8192
   ------------------------------------------
   U_RssiServer : entity work.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         APP_ILEAVE_EN_G     => true,       -- true = AxiStreamPacketizer2
         -- APP_ILEAVE_EN_G     => false,   -- false = AxiStreamPacketizer1
         MAX_SEG_SIZE_G      => 1024,
         SEGMENT_ADDR_SIZE_G => 7,
         APP_STREAMS_G       => RSSI_SIZE_C,
         APP_STREAM_ROUTES_G => (
            0                => X"00",
            1                => X"01",
            2                => X"02",
            3                => X"03"),
         CLK_FREQUENCY_G     => CLK_FREQUENCY_G,
         TIMEOUT_UNIT_G      => 1.0E-3,  -- In units of seconds
         SERVER_G            => true,
         RETRANSMIT_ENABLE_G => true,
         BYPASS_CHUNKER_G    => false,
         WINDOW_ADDR_SIZE_G  => 3,
         PIPE_STAGES_G       => 1,
         APP_AXIS_CONFIG_G   => AXIS_CONFIG_C,
         TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
         INIT_SEQ_N_G        => 16#80#)
      port map (
         clk_i             => clk,
         rst_i             => rst,
         openRq_i          => '1',
         -- Application Layer Interface
         sAppAxisMasters_i => rssiIbMasters,
         sAppAxisSlaves_o  => rssiIbSlaves,
         mAppAxisMasters_o => rssiObMasters,
         mAppAxisSlaves_i  => rssiObSlaves,
         -- Transport Layer Interface
         sTspAxisMaster_i  => obServerMasters(0),
         sTspAxisSlave_o   => obServerSlaves(0),
         mTspAxisMaster_o  => ibServerMasters(0),
         mTspAxisSlave_i   => ibServerSlaves(0));

   ---------------------------------------
   -- TDEST = 0x0: Register access control   
   ---------------------------------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C(0))
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => rssiObMasters(0),
         sAxisSlave       => rssiObSlaves(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => rssiIbMasters(0),
         mAxisSlave       => rssiIbSlaves(0),
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => clk,
         axilRst          => rst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave);

   --------------------------
   -- TDEST = 0x1: TX/RX PBRS   
   --------------------------
   rssiIbMasters(1) <= pbrsTxMaster;
   pbrsTxSlave      <= rssiIbSlaves(1);
   pbrsRxMaster     <= rssiObMasters(1);
   rssiObSlaves(1)  <= pbrsRxSlave;

   ------------------------
   -- TDEST = 0x2: HLS AXIS
   ------------------------
   rssiIbMasters(2) <= hlsTxMaster;
   hlsTxSlave       <= rssiIbSlaves(2);
   hlsRxMaster      <= rssiObMasters(2);
   rssiObSlaves(2)  <= hlsRxSlave;

   --------------------------
   -- TDEST = 0x3: TX/RX PBRS   
   --------------------------
   rssiIbMasters(3) <= mbTxMaster;
   mbTxSlave        <= rssiIbSlaves(3);

   ------------------------------
   -- Terminate Unused interfaces  
   ------------------------------
   rssiObSlaves(3) <= AXI_STREAM_SLAVE_FORCE_C;
   rxCtrl          <= AXI_STREAM_CTRL_UNUSED_C;

end mapping;
