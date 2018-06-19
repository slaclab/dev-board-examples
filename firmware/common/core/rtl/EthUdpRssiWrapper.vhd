-------------------------------------------------------------------------------
-- Title      : Ethernet UDP and RSSI wrapper
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Combine UDP and RSSI blocks into common module
-------------------------------------------------------------------------------
-- This file is part of dev-board-examples. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of dev-board-examples, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;

entity EthUdpRssiWrapper is
   generic (
      TPD_G           : time             := 1 ns;
      CLK_FREQUENCY_G : real             := 156.25E+6;
      MAC_ADDR_G      : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)   
      IP_ADDR_G       : slv(31 downto 0) := x"0A02A8C0";      -- 192.168.2.10 (ETH only)
      APP_ILEAVE_EN_G : boolean          := true;  -- true = AxiStreamPacketizer2, false = AxiStreamPacketizer1
      DHCP_G          : boolean          := true;
      JUMBO_G         : boolean          := false);
   port (
      -- Clock and Reset
      clk                 : in  sl;
      rst                 : in  sl;
      -- Raw ETH interface
      ethTxMaster         : out AxiStreamMasterType;
      ethTxSlave          : in  AxiStreamSlaveType;
      ethRxMaster         : in  AxiStreamMasterType;
      ethRxSlave          : out AxiStreamSlaveType;
      -- UDP RSSI channels
      txMasters           : in  AxiStreamMasterArray(3 downto 0);
      txSlaves            : out AxiStreamSlaveArray(3 downto 0);
      rxMasters           : out AxiStreamMasterArray(3 downto 0);
      rxSlaves            : in  AxiStreamSlaveArray(3 downto 0);
      -- Communication Slave AXI-Lite Interface
      rssiAxilWriteMaster : in  AxiLiteWriteMasterType;
      rssiAxilWriteSlave  : out AxiLiteWriteSlaveType;
      rssiAxilReadMaster  : in  AxiLiteReadMasterType;
      rssiAxilReadSlave   : out AxiLiteReadSlaveType);
end EthUdpRssiWrapper;

architecture rtl of EthUdpRssiWrapper is

   constant NUM_SERVERS_C  : integer                                 := 1;
   constant SERVER_PORTS_C : PositiveArray(NUM_SERVERS_C-1 downto 0) := (0 => 8192);

   constant RSSI_SIZE_C : positive := 4;

   constant MB_STREAM_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 4,
      TID_BITS_C    => 4,
      TKEEP_MODE_C  => TKEEP_NORMAL_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_LAST_C);

   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (
      0 => EMAC_AXIS_CONFIG_C,
      1 => EMAC_AXIS_CONFIG_C,
      2 => EMAC_AXIS_CONFIG_C,
      3 => MB_STREAM_CONFIG_C);

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

Begin

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
         obMacMaster     => ethRxMaster,
         obMacSlave      => ethRxSlave,
         ibMacMaster     => ethTxMaster,
         ibMacSlave      => ethTxSlave,
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
         APP_ILEAVE_EN_G     => APP_ILEAVE_EN_G,
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
         sAppAxisMasters_i => txMasters,
         sAppAxisSlaves_o  => txSlaves,
         mAppAxisMasters_o => rxMasters,
         mAppAxisSlaves_i  => rxSlaves,
         -- Transport Layer Interface
         sTspAxisMaster_i  => obServerMasters(0),
         sTspAxisSlave_o   => obServerSlaves(0),
         mTspAxisMaster_o  => ibServerMasters(0),
         mTspAxisSlave_i   => ibServerSlaves(0),
         -- AXI-Lite Interface
         axiClk_i          => clk,
         axiRst_i          => rst,
         axilReadMaster    => rssiAxilReadMaster,
         axilReadSlave     => rssiAxilReadSlave,
         axilWriteMaster   => rssiAxilWriteMaster,
         axilWriteSlave    => rssiAxilWriteSlave);

end architecture rtl;
