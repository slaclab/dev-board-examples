-------------------------------------------------------------------------------
-- File       : Kcu105Pgp3.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-02-09
-- Last update: 2017-08-09
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
use work.AxiLitePkg.all;
use work.Pgp2bPkg.all;
use work.Pgp3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity Kcu105Pgp3 is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false);
   port (
      -- Misc. IOs
      extRst  : in  sl;
      led     : out slv(7 downto 0);
      -- XADC Ports
      vPIn    : in  sl;
      vNIn    : in  sl;
      -- Pgp GT Pins
      pgpClkP : in  sl;
      pgpClkN : in  sl;
      pgpRxP  : in  sl;
      pgpRxN  : in  sl;
      pgpTxP  : out sl;
      pgpTxN  : out sl;

      -- PGP3 GT Pins
      pgp3RxP : in  sl;
      pgp3RxN : in  sl;
      pgp3TxP : out sl;
      pgp3TxN : out sl);
end Kcu105Pgp3;

architecture top_level of Kcu105Pgp3 is

   signal pgpRefClk     : sl;
   signal pgpRefClkDiv2 : sl;
   signal clk           : sl;
   signal rst           : sl;
   signal phyReady      : sl;

   -- PGP2b
   constant PGP_NUM_VC_C : positive := 4;

   signal pgpTxOut     : Pgp2bTxOutType;
   signal pgpRxOut     : Pgp2bRxOutType;
   signal pgpTxMasters : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0);
   signal pgpTxSlaves  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0);
   signal pgpRxMasters : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0);
   signal pgpRxSlaves  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0);
   signal pgpRxCtrl    : AxiStreamCtrlArray(PGP_NUM_VC_C-1 downto 0);

   -- PGP3
   constant PGP3_NUM_VC_C : integer := 4;

   signal pgp3Clk       : sl;
   signal pgp3ClkRst    : sl;
   signal pgp3RxIn      : Pgp3RxInType;                                    -- [in]
   signal pgp3RxOut     : Pgp3RxOutType;                                   -- [out]
   signal pgp3TxIn      : Pgp3TxInType;                                    -- [in]
   signal pgp3TxOut     : Pgp3TxOutType;                                   -- [out]
   signal pgp3TxMasters : AxiStreamMasterArray(PGP3_NUM_VC_C-1 downto 0);  -- [in]
   signal pgp3TxSlaves  : AxiStreamSlaveArray(PGP3_NUM_VC_C-1 downto 0);   -- [out]
   signal pgp3TxCtrl    : AxiStreamCtrlArray(PGP3_NUM_VC_C-1 downto 0);    -- [out]
   signal pgp3RxMasters : AxiStreamMasterArray(PGP3_NUM_VC_C-1 downto 0);  -- [out]
   signal pgp3RxCtrl    : AxiStreamCtrlArray(PGP3_NUM_VC_C-1 downto 0);    -- [in]


   constant XBAR_CFG_C : AxiLiteCrossbarMasterConfigArray(PGP3_NUM_VC_C*2-1 downto 0) :=
      genAxiLiteConfig(PGP3_NUM_VC_C*2, X"10000000", 24, 16);

   signal appAxilWriteMaster : AxiLiteWriteMasterType;
   signal appAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal appAxilReadMaster  : AxiLiteReadMasterType;
   signal appAxilReadSlave   : AxiLiteReadSlaveType;

   signal prbsAxilWriteMasters : AxiLiteWriteMasterArray(PGP3_NUM_VC_C*2-1 downto 0);
   signal prbsAxilWriteSlaves  : AxiLiteWriteSlaveArray(PGP3_NUM_VC_C*2-1 downto 0);
   signal prbsAxilReadMasters  : AxiLiteReadMasterArray(PGP3_NUM_VC_C*2-1 downto 0);
   signal prbsAxilReadSlaves   : AxiLiteReadSlaveArray(PGP3_NUM_VC_C*2-1 downto 0);


begin

   U_IBUFDS_GTE3 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => pgpClkP,
         IB    => pgpClkN,
         CEB   => '0',
         ODIV2 => pgpRefClkDiv2,        -- Divide by 1
         O     => pgpRefClk);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => pgpRefClkDiv2,
         CE      => '1',
         CLR     => '0',
         CEMASK  => '1',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => clk);

   REAL_PGP : if (not SIMULATION_G) generate

      U_PGP : entity work.Pgp2bGthUltra
         generic map (
            TPD_G             => TPD_G,
            PAYLOAD_CNT_TOP_G => 7,
            VC_INTERLEAVE_G   => 1,
            NUM_VC_EN_G       => 4)
         port map (
            stableClk       => clk,
            stableRst       => rst,
            gtRefClk        => pgpRefClk,
            pgpGtTxP        => pgpTxP,
            pgpGtTxN        => pgpTxN,
            pgpGtRxP        => pgpRxP,
            pgpGtRxN        => pgpRxN,
            pgpTxReset      => rst,
            pgpTxRecClk     => open,
            pgpTxClk        => clk,
            pgpTxMmcmLocked => '1',
            pgpRxReset      => rst,
            pgpRxRecClk     => open,
            pgpRxClk        => clk,
            pgpRxMmcmLocked => '1',
            pgpTxIn         => PGP2B_TX_IN_INIT_C,
            pgpTxOut        => pgpTxOut,
            pgpRxIn         => PGP2B_RX_IN_INIT_C,
            pgpRxOut        => pgpRxOut,
            pgpTxMasters    => pgpTxMasters,
            pgpTxSlaves     => pgpTxSlaves,
            pgpRxMasters    => pgpRxMasters,
            pgpRxCtrl       => pgpRxCtrl);

      pgpRxSlaves <= (others => AXI_STREAM_SLAVE_FORCE_C);
   end generate REAL_PGP;

   SIM_PGP : if (SIMULATION_G) generate

      GEN_AXIS_LANE : for i in 3 downto 0 generate
         U_RogueStreamSimWrap_PGP_VC : entity work.RogueStreamSimWrap
            generic map (
               TPD_G         => TPD_G,
               DEST_ID_G     => i,
               AXIS_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               clk         => clk,              -- [in]
               rst         => rst,              -- [in]
               sAxisClk    => clk,              -- [in]
               sAxisRst    => rst,              -- [in]
               sAxisMaster => pgpTxMasters(i),  -- [in]
               sAxisSlave  => pgpTxSlaves(i),   -- [out]
               mAxisClk    => clk,              -- [in]
               mAxisRst    => rst,              -- [in]
               mAxisMaster => pgpRxMasters(i),  -- [out]
               mAxisSlave  => pgpRxSlaves(i));  -- [in]
      end generate GEN_AXIS_LANE;

      pgpRxOut.phyRxReady   <= '1';
      pgpRxOut.linkReady    <= '1';
      pgpRxOut.linkPolarity <= (others => '0');
      pgpRxOut.frameRx      <= '0';
      pgpRxOut.frameRxErr   <= '0';
      pgpRxOut.linkDown     <= '0';
      pgpRxOut.linkError    <= '0';
      pgpRxOut.remLinkReady <= '1';
      pgpRxOut.remOverflow  <= (others => '0');
      pgpRxOut.remPause     <= (others => '0');

      pgpTxOut.locOverflow <= (others => '0');
      pgpTxOut.locPause    <= (others => '0');
      pgpTxOut.phyTxReady  <= '1';
      pgpTxOut.linkReady   <= '1';
      pgpTxOut.frameTx     <= '0';
      pgpTxOut.frameTxErr  <= '0';

   end generate SIM_PGP;

   U_Pgp3GthUs_2 : entity work.Pgp3GthUs
      generic map (
         TPD_G           => TPD_G,
         PGP_RX_ENABLE_G => true,
--          RX_ALIGN_GOOD_COUNT_G           => RX_ALIGN_GOOD_COUNT_G,
--          RX_ALIGN_BAD_COUNT_G            => RX_ALIGN_BAD_COUNT_G,
--          RX_ALIGN_SLIP_WAIT_G            => RX_ALIGN_SLIP_WAIT_G,
         PGP_TX_ENABLE_G => true,
         NUM_VC_G        => PGP3_NUM_VC_C)
--          TX_CELL_WORDS_MAX_G             => TX_CELL_WORDS_MAX_G,
--          TX_SKP_INTERVAL_G               => TX_SKP_INTERVAL_G,
--          TX_SKP_BURST_SIZE_G             => TX_SKP_BURST_SIZE_G,
--          TX_MUX_MODE_G                   => TX_MUX_MODE_G,
--          TX_MUX_TDEST_ROUTES_G           => TX_MUX_TDEST_ROUTES_G,
--          TX_MUX_TDEST_LOW_G              => TX_MUX_TDEST_LOW_G,
--          TX_MUX_INTERLEAVE_EN_G          => TX_MUX_INTERLEAVE_EN_G,
--          TX_MUX_INTERLEAVE_ON_NOTVALID_G => TX_MUX_INTERLEAVE_ON_NOTVALID_G)
      port map (
         stableClk    => clk,            -- [in]
         stableRst    => rst,            -- [in]
         gtRefClk     => pgpRefClk,      -- [in]
         pgpGtTxP     => pgp3TxP,        -- [out]
         pgpGtTxN     => pgp3TxN,        -- [out]
         pgpGtRxP     => pgp3RxP,        -- [in]
         pgpGtRxN     => pgp3RxN,        -- [in]
         pgpClk       => pgp3Clk,        -- [out]
         pgpClkRst    => pgp3ClkRst,     -- [out]
         pgpRxIn      => pgp3RxIn,       -- [in]
         pgpRxOut     => pgp3RxOut,      -- [out]
         pgpTxIn      => pgp3TxIn,       -- [in]
         pgpTxOut     => pgp3TxOut,      -- [out]
         pgpTxMasters => pgp3TxMasters,  -- [in]
         pgpTxSlaves  => pgp3TxSlaves,   -- [out]
         pgpTxCtrl    => pgp3TxCtrl,     -- [out]
         pgpRxMasters => pgp3RxMasters,  -- [out]
         pgpRxCtrl    => pgp3RxCtrl);    -- [in]


   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => PGP3_NUM_VC_C*2,
         MASTERS_CONFIG_G   => XBAR_CFG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => appAxilWriteMaster,
         sAxiWriteSlaves(0)  => appAxilWriteSlave,
         sAxiReadMasters(0)  => appAxilReadMaster,
         sAxiReadSlaves(0)   => appAxilReadSlave,
         mAxiWriteMasters    => prbsAxilWriteMasters,
         mAxiWriteSlaves     => prbsAxilWriteSlaves,
         mAxiReadMasters     => prbsAxilReadMasters,
         mAxiReadSlaves      => prbsAxilReadSlaves);


   PRBS_GEN : for i in 0 to PGP3_NUM_VC_C-1 generate
      U_SsiPrbsTx_1 : entity work.SsiPrbsTx
         generic map (
            TPD_G                      => TPD_G,
            GEN_SYNC_FIFO_G            => false,
            PRBS_INCREMENT_G           => true,
            MASTER_AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C)
         port map (
            mAxisClk        => pgp3Clk,                    -- [in]
            mAxisRst        => pgp3ClkRst,                 -- [in]
            mAxisMaster     => pgp3TxMasters(i),           -- [out]
            mAxisSlave      => pgp3TxSlaves(i),            -- [in]
            locClk          => clk,                        -- [in]
            locRst          => rst,                        -- [in]
            trig            => '1',                        -- [in]
            packetLength    => X"0000FFFF",                -- [in]
            forceEofe       => '0',                        -- [in]
            busy            => open,                       -- [out]
            tDest           => toSlv(i, 8),                -- [in]
            tId             => X"00",                      -- [in]
            axilReadMaster  => prbsAxilReadMasters(2*i),   -- [in]
            axilReadSlave   => prbsAxilReadSlaves(2*i),    -- [out]
            axilWriteMaster => prbsAxilWriteMasters(2*i),  -- [in]
            axilWriteSlave  => prbsAxilWriteSlaves(2*i));  -- [out]


      U_SsiPrbsRx_1 : entity work.SsiPrbsRx
         generic map (
            TPD_G                     => TPD_G,
            BRAM_EN_G                 => true,
            GEN_SYNC_FIFO_G           => false,
            FIFO_ADDR_WIDTH_G         => 9,
--            FIFO_PAUSE_THRESH_G        => FIFO_PAUSE_THRESH_G,
            SLAVE_AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C,
            SLAVE_AXI_PIPE_STAGES_G   => 1)
         port map (
            sAxisClk       => pgp3Clk,                      -- [in]
            sAxisRst       => pgp3ClkRst,                   -- [in]
            sAxisMaster    => pgp3RxMasters(i),             -- [in]
            sAxisSlave     => open,                         -- [out]
            sAxisCtrl      => pgp3RxCtrl(i),                -- [out]
            mAxisClk       => clk,                          -- [in]
            mAxisRst       => rst,                          -- [in]
            axiClk         => clk,                          -- [in]
            axiRst         => rst,                          -- [in]
            axiReadMaster  => prbsAxilReadMasters(2*i+1),   -- [in]
            axiReadSlave   => prbsAxilReadSlaves(2*i+1),    -- [out]
            axiWriteMaster => prbsAxilWriteMasters(2*i+1),  -- [in]
            axiWriteSlave  => prbsAxilWriteSlaves(2*i+1));  -- [out]


   end generate PRBS_GEN;


   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G          => TPD_G,
         SIM_SPEEDUP_G  => SIM_SPEEDUP_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map (
         clk    => clk,
         arst   => extRst,
         rstOut => rst);

   -------------------
   -- Application Core
   -------------------
   U_App : entity work.AppCore
      generic map (
         TPD_G           => TPD_G,
         SIMULATION_G    => SIMULATION_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         XIL_DEVICE_G    => "ULTRASCALE",
         MICROBLAZE_EN_G => false,
         APP_TYPE_G      => "PGP",
         AXIS_SIZE_G     => PGP_NUM_VC_C)
      port map (
         -- Clock and Reset
         clk                => clk,
         rst                => rst,
         -- AXIS interface
         txMasters          => pgpTxMasters,
         txSlaves           => pgpTxSlaves,
         rxMasters          => pgpRxMasters,
         rxSlaves           => pgpRxSlaves,
         rxCtrl             => pgpRxCtrl,
         -- AXIL interface
         extAxilWriteMaster => appAxilWriteMaster,
         extAxilWriteSlave  => appAxilWriteSlave,
         extAxilReadMaster  => appAxilReadMaster,
         extAxilReadSlave   => appAxilReadSlave,
         -- ADC Ports
         vPIn               => vPIn,
         vNIn               => vNIn);

   ----------------
   -- Misc. Signals
   ----------------
   led(7) <= phyReady;
   led(6) <= phyReady;
   led(5) <= phyReady;
   led(4) <= phyReady;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;



end top_level;
