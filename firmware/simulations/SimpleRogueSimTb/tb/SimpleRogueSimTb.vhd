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

   signal srpIbMaster : AxiStreamMasterType;
   signal srpIbSlave  : AxiStreamSlaveType;
   signal srpObMaster : AxiStreamMasterType;
   signal srpObSlave  : AxiStreamSlaveType;

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

begin

   U_ClkRst : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,   -- 156.25 MHz
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1000 ns)  -- Hold reset for this long)
      port map (
         clkP => clk,
         rst  => rst);

   U_RogueStreamSimWrap : entity work.RogueStreamSimWrap
      generic map (
         TPD_G               => TPD_G,
         DEST_ID_G           => 0,
         USER_ID_G           => 1,
         COMMON_MASTER_CLK_G => true,
         COMMON_SLAVE_CLK_G  => true,
         AXIS_CONFIG_G       => PGP3_AXIS_CONFIG_C)
      port map (
         -- Main Clock and reset used internally
         clk         => clk,
         rst         => rst,
         -- Slave
         sAxisClk    => clk,
         sAxisRst    => rst,
         sAxisMaster => srpObMaster,
         sAxisSlave  => srpObSlave,
         -- Master
         mAxisClk    => clk,
         mAxisRst    => rst,
         mAxisMaster => srpIbMaster,
         mAxisSlave  => srpIbSlave);

   U_SrpV3AxiLite : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain)
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => srpIbMaster,
         sAxisSlave       => srpIbSlave,
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => srpObMaster,
         mAxisSlave       => srpObSlave,
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => clk,
         axilRst          => rst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave);

   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_C,
         CLK_PERIOD_G => 6.4E-9)
      port map (
         -- AXI-Lite Register Interface
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave,
         -- Clocks and Resets
         axiClk         => clk,
         axiRst         => rst);

end testbed;
