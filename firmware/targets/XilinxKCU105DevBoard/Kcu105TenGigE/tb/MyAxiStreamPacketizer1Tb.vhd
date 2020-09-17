-------------------------------------------------------------------------------
-- File       : MyAxiStreamPacketizer1Tb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation test bed for AxiStreamPacketizer
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS FTK DF DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS FTK DF DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

entity MyAxiStreamPacketizer1Tb is end MyAxiStreamPacketizer1Tb;

architecture testbed of MyAxiStreamPacketizer1Tb is

   constant CLK_PERIOD_C       : time             := 10 ns;
   constant TPD_G              : time             := CLK_PERIOD_C/4;
   constant PKT_SIZE_C         : positive         := 127;
   constant MAX_PACKET_BYTES_C : positive         := 1024; -- 1024 = 128 x 4

   -- constant MAX_PACKET_BYTES_C : positive         := 3+(8*PKT_SIZE_C)/8;
   constant TKEEP_TLAST_C      : slv(15 downto 0) := genTKeep(4);

   type RegType is record
      cnt         : slv(31 downto 0);
      sAxisMaster : AxiStreamMasterType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      cnt         => (others => '0'),
      sAxisMaster => AXI_STREAM_MASTER_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal clk : sl := '0';
   signal rst : sl := '1';

   signal sAxisMaster : AxiStreamMasterType;
   signal sAxisSlave  : AxiStreamSlaveType;
   signal master      : AxiStreamMasterType;
   signal slave       : AxiStreamSlaveType;
   signal mAxisMaster : AxiStreamMasterType;
   signal mAxisSlave  : AxiStreamSlaveType;

begin

   -----------------------------
   -- Generate clocks and resets
   -----------------------------
   U_ClkRst : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_C,
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1000 ns)  -- Hold reset for this long)
      port map (
         clkP => clk,
         rst  => rst);

   U_Packetizer : entity surf.AxiStreamPacketizer
      generic map (
         TPD_G                => TPD_G,
         MAX_PACKET_BYTES_G   => MAX_PACKET_BYTES_C,
         INPUT_PIPE_STAGES_G  => 0,
         OUTPUT_PIPE_STAGES_G => 0)
      port map (
         axisClk     => clk,
         axisRst     => rst,
         sAxisMaster => sAxisMaster,
         sAxisSlave  => sAxisSlave,
         mAxisMaster => master,
         mAxisSlave  => slave);

   U_Depacketizer : entity surf.AxiStreamDepacketizer
      generic map (
         TPD_G                => TPD_G,
         INPUT_PIPE_STAGES_G  => 0,
         OUTPUT_PIPE_STAGES_G => 0)
      port map (
         axisClk     => clk,
         axisRst     => rst,
         restart     => '0',
         sAxisMaster => master,
         sAxisSlave  => slave,
         mAxisMaster => mAxisMaster,
         mAxisSlave  => mAxisSlave);

   mAxisSlave <= AXI_STREAM_SLAVE_FORCE_C;

   -------------------------------
   -- Generate different addresses
   -------------------------------
   comb : process (r, rst, sAxisSlave) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      if (sAxisSlave.tReady = '1') then
         v.sAxisMaster.tValid   := '0';
         v.sAxisMaster.tLast    := '0';
         v.sAxisMaster.tUser(1) := '0';
      end if;

      -- Check if ready to move data
      if v.sAxisMaster.tValid = '0' then
         -- Increment the counter
         v.cnt := r.cnt + 1;
         -- Generate a packet
         if (r.cnt < PKT_SIZE_C) then
            v.sAxisMaster.tValid             := '1';
            v.sAxisMaster.tData(31 downto 0) := r.cnt;
            if r.cnt = 0 then
               v.sAxisMaster.tUser(1) := '1';
               v.sAxisMaster.tKeep    := x"00FF";
            end if;
            if r.cnt = PKT_SIZE_C-1 then
               v.sAxisMaster.tLast := '1';
               v.sAxisMaster.tKeep := TKEEP_TLAST_C;
            end if;
         end if;
         if (r.cnt = 4*PKT_SIZE_C) then
            v.cnt := (others => '0');
         end if;
      end if;

      -- Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      sAxisMaster <= r.sAxisMaster;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end testbed;
