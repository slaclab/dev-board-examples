-------------------------------------------------------------------------------
-- File       : SimpleRogueSimTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-23
-- Last update: 2018-06-23
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the SimpleRogueSim module
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.BuildInfoPkg.all;
use work.Pgp3Pkg.all;

entity SimpleRogueSimTb is end SimpleRogueSimTb;

architecture testbed of SimpleRogueSimTb is

   constant TPD_G : time := 1 ns;

   signal clk : sl := '0';
   signal rst : sl := '1';

   signal prbIbMaster : AxiStreamMasterType;
   signal prbIbSlave  : AxiStreamSlaveType;
   signal prbObMaster : AxiStreamMasterType;
   signal prbObSlave  : AxiStreamSlaveType;

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal intReadMaster   : AxiLiteReadMasterArray(2 downto 0);
   signal intReadSlave    : AxiLiteReadSlaveArray(2 downto 0);
   signal intWriteMaster  : AxiLiteWriteMasterArray(2 downto 0);
   signal intWriteSlave   : AxiLiteWriteSlaveArray(2 downto 0);

   signal opCode   : slv(7 downto 0);
   signal opCodeEn : sl;
   signal remData  : slv(7 downto 0);

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(2 downto 0) := genAxiLiteConfig(3, x"00000000", 20, 16);

begin

   U_ClkRst : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,   -- 156.25 MHz
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1000 ns)  -- Hold reset for this long)
      port map (
         clkP => clk,
         rst  => rst);

   -- Memory bridge
   U_RogueMem: entity work.RogueTcpMemoryWrap
      generic map (
         TPD_G      => TPD_G,
         PORT_NUM_G => 9000
      ) port map (
         axiClk         => clk,
         axiRst         => rst, 
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave);

   U_Crossbar: entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 3,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C,
         DEBUG_G            => false)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => intWriteMaster,
         mAxiWriteSlaves     => intWriteSlave,
         mAxiReadMasters     => intReadMaster,
         mAxiReadSlaves      => intReadSlave);

   -- 0x00000000
   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_C,
         CLK_PERIOD_G => 6.4E-9)
      port map (
         axiReadMaster  => intReadMaster(0),
         axiReadSlave   => intReadSlave(0),
         axiWriteMaster => intWriteMaster(0),
         axiWriteSlave  => intWriteSlave(0),
         axiClk         => clk,
         axiRst         => rst);

   -- Bi-directional stream bridge
   U_RogueStream: entity work.RogueTcpStreamWrap
      generic map (
         TPD_G               => 1 ns,
         PORT_NUM_G          => 9002,
         SSI_EN_G            => true,
         CHAN_COUNT_G        => 1,
         COMMON_MASTER_CLK_G => true,
         COMMON_SLAVE_CLK_G  => true,
         AXIS_CONFIG_G       => PGP3_AXIS_CONFIG_C)
      port map (
         clk         => clk,
         rst         => rst,
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => prbIbMaster,
         sAxisSlave  => prbIbSlave,
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => prbObMaster,
         mAxisSlave  => prbObSlave);

   -- 0x00010000
   U_SsiPrbsRx: entity work.SsiPrbsRx 
      generic map (
         -- General Configurations
         TPD_G                      => TPD_G,
         STATUS_CNT_WIDTH_G         => 32,
         SLAVE_READY_EN_G           => true,
         BRAM_EN_G                  => true,
         XIL_DEVICE_G               => "7SERIES",
         USE_BUILT_IN_G             => false,
         GEN_SYNC_FIFO_G            => true,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         CASCADE_SIZE_G             => 1,
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 2**8,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 31, 1 => 6, 2 => 2, 3 => 1),
         SLAVE_AXI_STREAM_CONFIG_G  => PGP3_AXIS_CONFIG_C,
         SLAVE_AXI_PIPE_STAGES_G    => 0)
      port map (
         sAxisClk        => clk,
         sAxisRst        => rst,
         sAxisMaster     => prbObMaster,
         sAxisSlave      => prbObSlave,
         axiClk          => clk,
         axiRst          => rst,
         axiReadMaster   => intReadMaster(1),
         axiReadSlave    => intReadSlave(1),
         axiWriteMaster  => intWriteMaster(1),
         axiWriteSlave   => intWriteSlave(1));

   -- 0x00020000
   U_SsiPrbsTx: entity work.SsiPrbsTx
      generic map (
         TPD_G                      => TPD_G,
         AXI_EN_G                   => '1',
         VALID_THOLD_G              => 1,
         VALID_BURST_MODE_G         => false,
         BRAM_EN_G                  => true,
         XIL_DEVICE_G               => "7SERIES",
         USE_BUILT_IN_G             => false,
         GEN_SYNC_FIFO_G            => true,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         CASCADE_SIZE_G             => 1,
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 2**8,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 31, 1 => 6, 2 => 2, 3 => 1),
         PRBS_INCREMENT_G           => false,
         MASTER_AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 0)
      port map (
         mAxisClk        => clk,
         mAxisRst        => rst,
         mAxisMaster     => prbIbMaster,
         mAxisSlave      => prbIbSlave,
         axilReadMaster  => intReadMaster(2),
         axilReadSlave   => intReadSlave(2),
         axilWriteMaster => intWriteMaster(2),
         axilWriteSlave  => intWriteSlave(2),
         locClk          => clk,
         locRst          => rst,
         trig            => '1',
         packetLength    => x"00000FFF",
         forceEofe       => '0',
         tDest           => X"00",
         tId             => X"00");


   U_Sb: entity work.RogueSideBandWrap
      generic map (
         TPD_G      => TPD_G,
         PORT_NUM_G => 9020)
      port map (
         sysClk      => clk,
         sysRst      => rst,
         opCode      => opCode,
         opCodeEn    => opCodeEn,
         remData     => remData);

end testbed;
