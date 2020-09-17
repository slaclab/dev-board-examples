-------------------------------------------------------------------------------
-- File       : Kcu105FifoAsync.vhd
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

entity Kcu105FifoAsync is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst    : in  sl;
      clk125P   : in  sl;
      clk125N   : in  sl;
      gtClk156P : in  sl;
      gtClk156N : in  sl;
      led       : out slv(7 downto 0));
end Kcu105FifoAsync;

architecture top_level of Kcu105FifoAsync is

   constant SIZE_C           : natural      := 1;
   constant PRBS_SEED_SIZE_C : natural      := 32;
   constant PRBS_TAPS_C      : NaturalArray := (0 => 31, 1 => 6, 2 => 2, 3 => 1);

   signal axisMasters : AxiStreamMasterArray(SIZE_C-1 downto 0);
   signal axisSlaves  : AxiStreamSlaveArray(SIZE_C-1 downto 0);
   signal errorDet    : slv(SIZE_C-1 downto 0);
   signal errorDetDly : slv(SIZE_C-1 downto 0);
   signal updated     : slv(SIZE_C-1 downto 0);

   signal heartBeat : slv(1 downto 0);
   signal clock     : slv(1 downto 0);

   signal clk156     : sl;
   signal rst156     : sl;
   signal clk125     : sl;
   signal rst125     : sl;
   signal errLed     : sl;
   signal updatedLed : sl;

begin

   ----------------------
   -- Clocking and Resets
   ----------------------
   U_IBUFDS0 : IBUFDS
      port map (
         I  => clk125P,
         IB => clk125N,
         O  => clock(0));

   U_BUFG0 : BUFG
      port map (
         I => clock(0),
         O => clk125);

   U_PwrUpRst0 : entity surf.PwrUpRst
      generic map(
         TPD_G => TPD_G)
      port map(
         clk    => clk125,
         arst   => extRst,
         rstOut => rst125);

   U_IBUFDS1 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => gtClk156P,
         IB    => gtClk156N,
         CEB   => '0',
         ODIV2 => clock(1),
         O     => open);

   U_BUFG1 : BUFG_GT
      port map (
         I       => clock(1),
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => clk156);

   U_PwrUpRst1 : entity surf.PwrUpRst
      generic map(
         TPD_G => TPD_G)
      port map(
         clk    => clk156,
         arst   => extRst,
         rstOut => rst156);

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
            mAxisClk     => clk125,
            mAxisRst     => rst125,
            mAxisMaster  => axisMasters(i),
            mAxisSlave   => axisSlaves(i),
            -- Trigger Signal (locClk domain)
            locClk       => clk156,
            locRst       => rst156,
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
            TPD_G                      => TPD_G,
            -- FIFO Configurations
            MEMORY_TYPE_G              => "distributed",
            GEN_SYNC_FIFO_G            => true,
            FIFO_ADDR_WIDTH_G          => 4,
            FIFO_PAUSE_THRESH_G        => 1,
            -- PRBS Configurations
            PRBS_SEED_SIZE_G           => PRBS_SEED_SIZE_C,
            PRBS_TAPS_G                => PRBS_TAPS_C,
            -- AXI Stream Configurations
            SLAVE_AXI_STREAM_CONFIG_G  => ssiAxiStreamConfig(4))
         port map (
            -- Streaming RX Data Interface (sAxisClk domain)
            sAxisClk       => clk125,
            sAxisRst       => rst125,
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
   led(7) <= heartBeat(0);
   led(6) <= heartBeat(1);
   led(5) <= errLed;
   led(4) <= errLed;
   led(3) <= errLed;
   led(2) <= errLed;
   led(1) <= updatedLed;
   led(0) <= '1';

   process(clk125)
   begin
      if rising_edge(clk125) then
         errorDetDly <= errorDet after TPD_G;
         if rst125 = '1' then
            errLed <= '0' after TPD_G;
         else
            if uOr(errorDetDly) = '1' then
               errLed <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   Heartbeat_0 : entity surf.Heartbeat
      generic map(
         TPD_G       => TPD_G,
         PERIOD_IN_G => 6.4E-9)
      port map (
         clk => clk156,
         o   => heartBeat(0));

   Heartbeat_1 : entity surf.Heartbeat
      generic map(
         TPD_G       => TPD_G,
         PERIOD_IN_G => 8.0E-9)
      port map (
         clk => clk125,
         o   => heartBeat(1));

   PwrUpRst_updatedLed : entity surf.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map(
         clk    => clk125,
         arst   => updated(0),
         rstOut => updatedLed);

end top_level;
