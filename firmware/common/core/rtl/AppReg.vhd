-------------------------------------------------------------------------------
-- File       : AppReg.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-15
-- Last update: 2018-02-12
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

entity AppReg is
   generic (
      TPD_G            : time            := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      XIL_DEVICE_G     : string          := "7SERIES");
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- AXI-Lite interface
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      -- PBRS Interface
      pbrsTxMaster    : out AxiStreamMasterType;
      pbrsTxSlave     : in  AxiStreamSlaveType;
      pbrsRxMaster    : in  AxiStreamMasterType;
      pbrsRxSlave     : out AxiStreamSlaveType;
      -- HLS Interface
      hlsTxMaster     : out AxiStreamMasterType;
      hlsTxSlave      : in  AxiStreamSlaveType;
      hlsRxMaster     : in  AxiStreamMasterType;
      hlsRxSlave      : out AxiStreamSlaveType;
      -- MB Interface
      mbTxMaster      : out AxiStreamMasterType;
      mbTxSlave       : in  AxiStreamSlaveType;
      -- ADC Ports
      vPIn            : in  sl;
      vNIn            : in  sl);
end AppReg;

architecture mapping of AppReg is

   constant SHARED_MEM_WIDTH_C : positive                           := 10;
   constant IRQ_ADDR_C         : slv(SHARED_MEM_WIDTH_C-1 downto 0) := (others => '1');

   constant NUM_AXI_MASTERS_C : natural := 7;

   constant VERSION_INDEX_C : natural := 0;
   constant XADC_INDEX_C    : natural := 1;
   constant SYS_MON_INDEX_C : natural := 2;
   constant MEM_INDEX_C     : natural := 3;
   constant PRBS_TX_INDEX_C : natural := 4;
   constant PRBS_RX_INDEX_C : natural := 5;
   constant HLS_INDEX_C     : natural := 6;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := (
      VERSION_INDEX_C => (
         baseAddr     => x"0000_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      XADC_INDEX_C    => (
         baseAddr     => x"0001_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      SYS_MON_INDEX_C => (
         baseAddr     => x"0002_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      MEM_INDEX_C     => (
         baseAddr     => x"0003_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      PRBS_TX_INDEX_C => (
         baseAddr     => x"0004_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      PRBS_RX_INDEX_C => (
         baseAddr     => x"0005_0000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      HLS_INDEX_C     => (
         baseAddr     => x"0006_0000",
         addrBits     => 16,
         connectivity => X"FFFF"));

   signal mAxilWriteMaster : AxiLiteWriteMasterType;
   signal mAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal mAxilReadMaster  : AxiLiteReadMasterType;
   signal mAxilReadSlave   : AxiLiteReadSlaveType;

   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal axiWrValid : sl;
   signal axiWrAddr  : slv(SHARED_MEM_WIDTH_C-1 downto 0);

   signal irqReq   : slv(7 downto 0);
   signal irqCount : slv(27 downto 0);

begin

   U_CPU : entity work.MicroblazeBasicCoreWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Master AXI-Lite Interface: [0x00000000:0x7FFFFFFF]
         mAxilWriteMaster => mAxilWriteMaster,
         mAxilWriteSlave  => mAxilWriteSlave,
         mAxilReadMaster  => mAxilReadMaster,
         mAxilReadSlave   => mAxilReadSlave,
         -- Streaming
         mAxisMaster      => mbTxMaster,
         mAxisSlave       => mbTxSlave,
         -- IRQ
         interrupt        => irqReq,
         -- Clock and Reset
         clk              => clk,
         rst              => rst);

   process (clk)
   begin
      if rising_edge(clk) then
         irqReq <= (others => '0') after TPD_G;
         if rst = '1' then
            irqCount <= (others => '0') after TPD_G;
         else
            -- IRQ[0]
            if irqCount = x"9502f90" then
               irqReq(0) <= '1'             after TPD_G;
               irqCount  <= (others => '0') after TPD_G;
            else
               irqCount <= irqCount + 1 after TPD_G;
            end if;
            -- IRQ[1]
            if (axiWrValid = '1') and (axiWrAddr = IRQ_ADDR_C) then
               irqReq(1) <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   ---------------------------
   -- AXI-Lite Crossbar Module
   ---------------------------         
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteMasters(1) => mAxilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiWriteSlaves(1)  => mAxilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadMasters(1)  => mAxilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         sAxiReadSlaves(1)   => mAxilReadSlave,
         mAxiWriteMasters    => mAxilWriteMasters,
         mAxiWriteSlaves     => mAxilWriteSlaves,
         mAxiReadMasters     => mAxilReadMasters,
         mAxiReadSlaves      => mAxilReadSlaves,
         axiClk              => clk,
         axiClkRst           => rst);

   ---------------------------
   -- AXI-Lite: Version Module
   ---------------------------            
   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G            => TPD_G,
         BUILD_INFO_G     => BUILD_INFO_G,
         XIL_DEVICE_G     => XIL_DEVICE_G,
         EN_DEVICE_DNA_G  => true)
      port map (
         axiReadMaster  => mAxilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(VERSION_INDEX_C),
         axiClk         => clk,
         axiRst         => rst);

   GEN_7SERIES : if (XIL_DEVICE_G = "7SERIES") generate
      ------------------------
      -- AXI-Lite: XADC Module
      ------------------------
      U_XADC : entity work.AxiXadcWrapper
         generic map (
            TPD_G            => TPD_G)
         port map (
            axiReadMaster  => mAxilReadMasters(XADC_INDEX_C),
            axiReadSlave   => mAxilReadSlaves(XADC_INDEX_C),
            axiWriteMaster => mAxilWriteMasters(XADC_INDEX_C),
            axiWriteSlave  => mAxilWriteSlaves(XADC_INDEX_C),
            axiClk         => clk,
            axiRst         => rst,
            vPIn           => vPIn,
            vNIn           => vNIn);

   end generate;

   GEN_ULTRA_SCALE : if (XIL_DEVICE_G = "ULTRASCALE") generate
      --------------------------
      -- AXI-Lite: SYSMON Module
      --------------------------
      U_SysMon : entity work.SystemManagementWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            axiReadMaster  => mAxilReadMasters(SYS_MON_INDEX_C),
            axiReadSlave   => mAxilReadSlaves(SYS_MON_INDEX_C),
            axiWriteMaster => mAxilWriteMasters(SYS_MON_INDEX_C),
            axiWriteSlave  => mAxilWriteSlaves(SYS_MON_INDEX_C),
            axiClk         => clk,
            axiRst         => rst,
            vPIn           => vPIn,
            vNIn           => vNIn);
   end generate;

   --------------------------------          
   -- AXI-Lite Shared Memory Module
   --------------------------------          
   U_Mem : entity work.AxiDualPortRam
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => true,
         REG_EN_G     => true,
         AXI_WR_EN_G  => true,
         SYS_WR_EN_G  => false,
         COMMON_CLK_G => false,
         ADDR_WIDTH_G => SHARED_MEM_WIDTH_C,
         DATA_WIDTH_G => 32)
      port map (
         -- Clock and Reset
         clk            => clk,
         rst            => rst,
         -- AXI-Lite Write Monitor
         axiWrValid     => axiWrValid,
         axiWrAddr      => axiWrAddr,
         -- AXI-Lite Interface
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(MEM_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(MEM_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(MEM_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(MEM_INDEX_C));

   -------------------
   -- AXI-Lite PRBS RX
   -------------------
   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map (
         TPD_G                      => TPD_G,
         MASTER_AXI_PIPE_STAGES_G   => 1,
         MASTER_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         mAxisClk        => clk,
         mAxisRst        => rst,
         mAxisMaster     => pbrsTxMaster,
         mAxisSlave      => pbrsTxSlave,
         locClk          => clk,
         locRst          => rst,
         trig            => '0',
         packetLength    => X"000000ff",
         tDest           => X"00",
         tId             => X"00",
         axilReadMaster  => mAxilReadMasters(PRBS_TX_INDEX_C),
         axilReadSlave   => mAxilReadSlaves(PRBS_TX_INDEX_C),
         axilWriteMaster => mAxilWriteMasters(PRBS_TX_INDEX_C),
         axilWriteSlave  => mAxilWriteSlaves(PRBS_TX_INDEX_C));

   -------------------
   -- AXI-Lite PRBS RX
   -------------------
   U_SsiPrbsRx : entity work.SsiPrbsRx
      generic map (
         TPD_G                     => TPD_G,
         SLAVE_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         sAxisClk       => clk,
         sAxisRst       => rst,
         sAxisMaster    => pbrsRxMaster,
         sAxisSlave     => pbrsRxSlave,
         mAxisClk       => clk,
         mAxisRst       => rst,
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(PRBS_RX_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(PRBS_RX_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(PRBS_RX_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(PRBS_RX_INDEX_C));

   ------------------------------
   -- AXI-Lite HLS Example Module
   ------------------------------            
   U_AxiLiteExample : entity work.AxiLiteExample
      port map (
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(HLS_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(HLS_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(HLS_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(HLS_INDEX_C));

   ------------------------------------
   -- AXI Streaming: HLS Example Module
   ------------------------------------
   U_AxiStreamExample : entity work.AxiStreamExample
      port map (
         axisClk     => clk,
         axisRst     => rst,
         -- Slave Port
         sAxisMaster => hlsRxMaster,
         sAxisSlave  => hlsRxSlave,
         -- Master Port
         mAxisMaster => hlsTxMaster,
         mAxisSlave  => hlsTxSlave);

end mapping;
