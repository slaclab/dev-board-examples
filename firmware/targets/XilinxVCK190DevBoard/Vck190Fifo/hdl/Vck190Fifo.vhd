-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Hardware Testbed for checking FifoAsync with two ASYNC clocks
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Vck190Fifo is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      ddr4SmaClkP : in  sl;
      ddr4SmaClkN : in  sl;
      led         : out slv(3 downto 0));
end Vck190Fifo;

architecture top_level of Vck190Fifo is

   constant SIZE_C           : natural      := 1;
   constant PRBS_SEED_SIZE_C : natural      := 32;
   constant PRBS_TAPS_C      : NaturalArray := (0 => 31, 1 => 6, 2 => 2, 3 => 1);

   signal axisMasters : AxiStreamMasterArray(SIZE_C-1 downto 0);
   signal axisSlaves  : AxiStreamSlaveArray(SIZE_C-1 downto 0);
   signal errorDet    : slv(SIZE_C-1 downto 0);
   signal errorDetDly : slv(SIZE_C-1 downto 0);
   signal updated     : slv(SIZE_C-1 downto 0);

   signal clock : sl;
   signal clk   : sl;
   signal rst   : sl;

   signal heartBeat  : sl;
   signal errLed     : sl;
   signal updatedLed : sl;

begin

   ----------------------
   -- Clocking and Resets
   ----------------------
   U_IBUFDS0 : IBUFDS
      port map (
         I  => ddr4SmaClkP,
         IB => ddr4SmaClkN,
         O  => clock);

   U_BUFG0 : BUFG
      port map (
         I => clock,
         O => clk);

   U_PwrUpRst0 : entity surf.PwrUpRst
      generic map(
         TPD_G => TPD_G)
      port map(
         clk    => clk,
         rstOut => rst);

   GEN_VEC :
   for i in (SIZE_C-1) downto 0 generate
      -----------------
      -- Data Generator
      -----------------
      SsiPrbsTx_Inst : entity surf.SsiPrbsTx
         generic map (
            -- General Configurations
            TPD_G                      => TPD_G,
            -- FIFO configurations
            MEMORY_TYPE_G              => "block",
            GEN_SYNC_FIFO_G            => false,
            FIFO_ADDR_WIDTH_G          => 9,
            FIFO_PAUSE_THRESH_G        => 1,
            -- PRBS Configurations
            PRBS_SEED_SIZE_G           => PRBS_SEED_SIZE_C,
            PRBS_TAPS_G                => PRBS_TAPS_C,
            -- AXI Stream Configurations
            MASTER_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4),
            MASTER_AXI_PIPE_STAGES_G   => 1)
         port map (
            -- Master Port (mAxisClk)
            mAxisClk     => clk,
            mAxisRst     => rst,
            mAxisMaster  => axisMasters(i),
            mAxisSlave   => axisSlaves(i),
            -- Trigger Signal (locClk domain)
            locClk       => clk,
            locRst       => rst,
            trig         => '1',
            packetLength => x"00000FFF",
            forceEofe    => '0',
            busy         => open,
            tDest        => (others => '0'),
            tId          => (others => '0'));
      ---------------
      -- Data Checker
      ---------------
      SsiPrbsRx_Inst : entity surf.SsiPrbsRx
         generic map (
            -- General Configurations
            TPD_G                     => TPD_G,
            -- FIFO Configurations
            MEMORY_TYPE_G             => "distributed",
            GEN_SYNC_FIFO_G           => true,
            FIFO_ADDR_WIDTH_G         => 4,
            FIFO_PAUSE_THRESH_G       => 1,
            -- PRBS Configurations
            PRBS_SEED_SIZE_G          => PRBS_SEED_SIZE_C,
            PRBS_TAPS_G               => PRBS_TAPS_C,
            -- AXI Stream Configurations
            SLAVE_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4))
         port map (
            -- Streaming RX Data Interface (sAxisClk domain)
            sAxisClk       => clk,
            sAxisRst       => rst,
            sAxisMaster    => axisMasters(i),
            sAxisSlave     => axisSlaves(i),
            -- Optional: AXI-Lite Register Interface (axiClk domain)
            axiClk         => '0',
            axiRst         => '1',
            axiReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
            axiReadSlave   => open,
            axiWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
            -- Error Detection Signals (sAxisClk domain)
            updatedResults => updated(i),
            errorDet       => errorDet(i));
   end generate GEN_VEC;

   ----------------
   -- Misc. Signals
   ----------------
   led(3) <= errLed;
   led(2) <= updatedLed;
   led(1) <= heartBeat;
   led(0) <= not(rst);

   process(clk)
   begin
      if rising_edge(clk) then
         errorDetDly <= errorDet after TPD_G;
         if rst = '1' then
            errLed <= '0' after TPD_G;
         else
            if uOr(errorDetDly) = '1' then
               errLed <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   U_Heartbeat_0 : entity surf.Heartbeat
      generic map(
         TPD_G       => TPD_G,
         PERIOD_IN_G => 5.0E-9)
      port map (
         clk => clk,
         o   => heartBeat);

   PwrUpRst_updatedLed : entity surf.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map(
         clk    => clk,
         arst   => updated(0),
         rstOut => updatedLed);

end top_level;
