-------------------------------------------------------------------------------
-- File       : Kcu105Pgp3.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-02-09
-- Last update: 2018-03-13
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
      TPD_G           : time    := 1 ns;
      BUILD_INFO_G    : BuildInfoType;
      RESET_RX_TIME_G : time    := 50 us;
      SIM_SPEEDUP_G   : boolean := false;
      SIMULATION_G    : boolean := false;
      NO_PGP2B_G      : boolean := false);
   port (
      -- Misc. IOs
      --extRst  : in  sl;
      led     : out slv(7 downto 0) := (others => '0');
      -- XADC Ports
--       vPIn    : in  sl;
--       vNIn    : in  sl;
      -- Pgp GT Pins
      pgpClkP : in  sl;
      pgpClkN : in  sl;
--       pgpRxP  : in  sl;
--       pgpRxN  : in  sl;
--       pgpTxP  : out sl;
--       pgpTxN  : out sl;

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
   signal rstL          : sl;

   -- PGP2b
   constant PGP_NUM_VC_C : positive := 4;

   signal pgpTxOut     : Pgp2bTxOutType                                := PGP2B_TX_OUT_INIT_C;
   signal pgpRxOut     : Pgp2bRxOutType                                := PGP2B_RX_OUT_INIT_C;
   signal pgpTxMasters : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpTxSlaves  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_INIT_C);
   signal pgpRxMasters : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpRxSlaves  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_INIT_C);
   signal pgpRxCtrl    : AxiStreamCtrlArray(PGP_NUM_VC_C-1 downto 0)   := (others => AXI_STREAM_CTRL_UNUSED_C);

   signal rxMasters0 : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves0  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_INIT_C);
   signal rxMasters1 : AxiStreamMasterArray(PGP_NUM_VC_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves1  : AxiStreamSlaveArray(PGP_NUM_VC_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_INIT_C);

   -- PGP3
   constant PGP3_NUM_VC_C : integer := 4;

   signal pgp3Clk       : sl;
   signal pgp3ClkRst    : sl;
   signal pgp3RxIn      : Pgp3RxInType := PGP3_RX_IN_INIT_C;               -- [in]
   signal pgp3RxOut     : Pgp3RxOutType;                                   -- [out]
   signal pgp3TxIn      : Pgp3TxInType := PGP3_TX_IN_INIT_C;               -- [in]
   signal pgp3TxOut     : Pgp3TxOutType;                                   -- [out]
   signal pgp3TxMasters : AxiStreamMasterArray(PGP3_NUM_VC_C-1 downto 0);  -- [in]
   signal pgp3TxSlaves  : AxiStreamSlaveArray(PGP3_NUM_VC_C-1 downto 0);   -- [out]
   signal pgp3RxMasters : AxiStreamMasterArray(PGP3_NUM_VC_C-1 downto 0);  -- [out]
   signal pgp3RxCtrl    : AxiStreamCtrlArray(PGP3_NUM_VC_C-1 downto 0);    -- [in]

   constant XBAR_MASTERS_C : integer := 4;

   constant VERSION_AXIL_C : integer := 0;
   constant PGP3_AXIL_C    : integer := 1;
   constant PRBS_AXIL_C    : integer := 2;
   constant PROM_AXIL_C    : integer := 3;

   constant XBAR_CFG_C : AxiLiteCrossbarMasterConfigArray(XBAR_MASTERS_C-1 downto 0) := (
      VERSION_AXIL_C  => (
         baseAddr     => X"00000000",
         addrBits     => 12,
         connectivity => X"0001"),
      PGP3_AXIL_C     => (
         baseAddr     => X"00001000",
         addrBits     => 12,
         connectivity => X"0001"),
      PROM_AXIL_C     => (
         baseAddr     => X"00002000",
         addrBits     => 12,
         connectivity => X"0001"),
      PRBS_AXIL_C     => (
         baseAddr     => X"10000000",
         addrBits     => 24,
         connectivity => X"0001")
      );

   signal srpAxilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal srpAxilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal srpAxilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal srpAxilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;

   signal locAxilWriteMasters : AxiLiteWriteMasterArray(XBAR_MASTERS_C-1 downto 0);
   signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(XBAR_MASTERS_C-1 downto 0);
   signal locAxilReadMasters  : AxiLiteReadMasterArray(XBAR_MASTERS_C-1 downto 0);
   signal locAxilReadSlaves   : AxiLiteReadSlaveArray(XBAR_MASTERS_C-1 downto 0);

   signal prbsClk : slv(7 downto 0);
   signal prbsRst : slv(7 downto 0);

   signal bootCsL  : sl;
   signal bootSck  : sl;
   signal bootMosi : sl;
   signal bootMiso : sl;
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);

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

--    U_ClockManagerUltraScale_1 : entity work.ClockManagerUltraScale
--       generic map (
--          TPD_G              => TPD_G,
--          TYPE_G             => "MMCM",
--          INPUT_BUFG_G       => false,
--          FB_BUFG_G          => false,
--          NUM_CLOCKS_G       => 7,
--          BANDWIDTH_G        => "OPTIMIZED",
--          CLKIN_PERIOD_G     => 6.4,
--          DIVCLK_DIVIDE_G    => 7,
--          CLKFBOUT_MULT_F_G  => 53.750,
--          CLKOUT0_DIVIDE_F_G => 100.0,
--          CLKOUT1_DIVIDE_G   => 90,
--          CLKOUT2_DIVIDE_G   => 125,
--          CLKOUT3_DIVIDE_G   => 110,
--          CLKOUT4_DIVIDE_G   => 125,
--          CLKOUT5_DIVIDE_G   => 100,
--          CLKOUT6_DIVIDE_G   => 120)
--       port map (
--          clkIn  => clk,                   -- [in]
--          rstIn  => '0',                   -- [in]
--          clkOut => prbsClk(7 downto 1),   -- [out]
--          rstOut => prbsRst(7 downto 1));  -- [out]

--    prbsClk(0) <= clk;
--    prbsRst(0) <= rst;

   SIM_RESET_RX : if (SIMULATION_G) generate
      test : process is
      begin
         pgp3RxIn.resetRx <= '0';
         wait for RESET_RX_TIME_G;
         wait until clk = '1';
         pgp3RxIn.resetRx <= '1' after 1 ns;
         wait until clk = '1';
         pgp3RxIn.resetRx <= '0' after 1 ns;
         wait;
      end process test;
   end generate SIM_RESET_RX;

--    GEN_PGP : if (not NO_PGP2B_G) generate

--       REAL_PGP : if (not SIMULATION_G) generate

--          U_PGP : entity work.Pgp2bGthUltra
--             generic map (
--                TPD_G             => TPD_G,
--                PAYLOAD_CNT_TOP_G => 7,
--                VC_INTERLEAVE_G   => 1,
--                NUM_VC_EN_G       => 1)
--             port map (
--                stableClk       => clk,
--                stableRst       => rst,
--                gtRefClk        => pgpRefClk,
--                pgpGtTxP        => pgpTxP,
--                pgpGtTxN        => pgpTxN,
--                pgpGtRxP        => pgpRxP,
--                pgpGtRxN        => pgpRxN,
--                pgpTxReset      => rst,
--                pgpTxOutClk     => open,
--                pgpTxClk        => clk,
--                pgpTxMmcmLocked => '1',
--                pgpRxReset      => rst,
--                pgpRxOutClk     => open,
--                pgpRxClk        => clk,
--                pgpRxMmcmLocked => '1',
--                pgpTxIn         => PGP2B_TX_IN_INIT_C,
--                pgpTxOut        => pgpTxOut,
--                pgpRxIn         => PGP2B_RX_IN_INIT_C,
--                pgpRxOut        => pgpRxOut,
--                pgpTxMasters    => pgpTxMasters,
--                pgpTxSlaves     => pgpTxSlaves,
--                pgpRxMasters    => pgpRxMasters,
--                pgpRxCtrl       => pgpRxCtrl);

--          pgpRxSlaves <= (others => AXI_STREAM_SLAVE_FORCE_C);
--       end generate REAL_PGP;

--       SIM_PGP : if (SIMULATION_G) generate

--          GEN_AXIS_LANE : for i in 3 downto 0 generate
--             U_RogueStreamSimWrap_PGP_VC : entity work.RogueStreamSimWrap
--                generic map (
--                   TPD_G         => TPD_G,
--                   DEST_ID_G     => i,
--                   AXIS_CONFIG_G => SSI_PGP2B_CONFIG_C)
--                port map (
--                   clk         => clk,              -- [in]
--                   rst         => rst,              -- [in]
--                   sAxisClk    => clk,              -- [in]
--                   sAxisRst    => rst,              -- [in]
--                   sAxisMaster => pgpTxMasters(i),  -- [in]
--                   sAxisSlave  => pgpTxSlaves(i),   -- [out]
--                   mAxisClk    => clk,              -- [in]
--                   mAxisRst    => rst,              -- [in]
--                   mAxisMaster => pgpRxMasters(i),  -- [out]
--                   mAxisSlave  => pgpRxSlaves(i));  -- [in]
--          end generate GEN_AXIS_LANE;

--          pgpRxOut.phyRxReady   <= '1';
--          pgpRxOut.linkReady    <= '1';
--          pgpRxOut.linkPolarity <= (others => '0');
--          pgpRxOut.frameRx      <= '0';
--          pgpRxOut.frameRxErr   <= '0';
--          pgpRxOut.linkDown     <= '0';
--          pgpRxOut.linkError    <= '0';
--          pgpRxOut.remLinkReady <= '1';
--          pgpRxOut.remOverflow  <= (others => '0');
--          pgpRxOut.remPause     <= (others => '0');

--          pgpTxOut.locOverflow <= (others => '0');
--          pgpTxOut.locPause    <= (others => '0');
--          pgpTxOut.phyTxReady  <= '1';
--          pgpTxOut.linkReady   <= '1';
--          pgpTxOut.frameTx     <= '0';
--          pgpTxOut.frameTxErr  <= '0';

--       end generate SIM_PGP;
--    end generate GEN_PGP;

   led(0) <= pgpTxOut.linkReady;
   led(1) <= pgpRxOut.linkReady;

   U_SrpV3AxiLite_1 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => SIMULATION_G,
         GEN_SYNC_FIFO_G     => true,
         AXIL_CLK_FREQ_G     => 156.25e+6,
         AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         sAxisClk         => pgp3Clk,             -- [in]
         sAxisRst         => pgp3ClkRst,          -- [in]
         sAxisMaster      => pgp3RxMasters(0),    -- [in]
         sAxisSlave       => open,                -- [out]
         sAxisCtrl        => pgp3RxCtrl(0),       -- [out]
         mAxisClk         => pgp3Clk,             -- [in]
         mAxisRst         => pgp3ClkRst,          -- [in]
         mAxisMaster      => pgp3TxMasters(0),    -- [out]
         mAxisSlave       => pgp3TxSlaves(0),     -- [in]
         axilClk          => clk,                 -- [in]
         axilRst          => rst,                 -- [in]
         mAxilWriteMaster => srpAxilWriteMaster,  -- [out]
         mAxilWriteSlave  => srpAxilWriteSlave,   -- [in]
         mAxilReadMaster  => srpAxilReadMaster,   -- [out]
         mAxilReadSlave   => srpAxilReadSlave);   -- [in]

   U_Pgp3GthUs_2 : entity work.Pgp3GthUsWrapper
      generic map (
         TPD_G       => TPD_G,
         REFCLK_G    => true,               -- TRUE: pgpRefClkIn
         NUM_LANES_G => 1,
         NUM_VC_G    => PGP3_NUM_VC_C)
      port map (
         -- Stable Clock and Reset
         stableClk       => clk,            -- [in]
         stableRst       => rst,            -- [in]
         -- Gt Serial IO
         pgpGtTxP(0)     => pgp3TxP,        -- [out]
         pgpGtTxN(0)     => pgp3TxN,        -- [out]
         pgpGtRxP(0)     => pgp3RxP,        -- [in]
         pgpGtRxN(0)     => pgp3RxN,        -- [in]
         -- GT Clocking
         pgpRefClkIn     => pgpRefClk,
         -- Clocking
         pgpClk(0)       => pgp3Clk,        -- [out]
         pgpClkRst(0)    => pgp3ClkRst,     -- [out]
         -- Non VC Rx Signals
         pgpRxIn(0)      => pgp3RxIn,       -- [in]
         pgpRxOut(0)     => pgp3RxOut,      -- [out]
         -- Non VC Tx Signals
         pgpTxIn(0)      => pgp3TxIn,       -- [in]
         pgpTxOut(0)     => pgp3TxOut,      -- [out]
         -- Frame Transmit Interface
         pgpTxMasters    => pgp3TxMasters,  -- [in]
         pgpTxSlaves     => pgp3TxSlaves,   -- [out]
         -- Frame Receive Interface
         pgpRxMasters    => pgp3RxMasters,  -- [out]
         pgpRxCtrl       => pgp3RxCtrl,     -- [in]
         axilClk         => clk,            -- [in]
         axilRst         => rst,            -- [in]
         axilWriteMaster => locAxilWriteMasters(PGP3_AXIL_C),
         axilWriteSlave  => locAxilWriteSlaves(PGP3_AXIL_C),
         axilReadMaster  => locAxilReadMasters(PGP3_AXIL_C),
         axilReadSlave   => locAxilReadSlaves(PGP3_AXIL_C));

   led(2) <= pgp3TxOut.linkReady;
   led(3) <= pgp3RxOut.linkReady;

   U_PrbsChannels_1 : entity work.PrbsChannels
      generic map (
         TPD_G            => TPD_G,
         AXIL_BASE_ADDR_G => XBAR_CFG_C(PRBS_AXIL_C).baseAddr,
         CHANNELS_G       => PGP3_NUM_VC_C-1)
      port map (
         txClk           => pgp3Clk,                           -- [in]
         txRst           => pgp3ClkRst,                        -- [in]
         txMasters       => pgp3TxMasters(PGP3_NUM_VC_C-1 downto 1),                     -- [out]
         txSlaves        => pgp3TxSlaves(PGP3_NUM_VC_C-1 downto 1),                      -- [in]
         rxClk           => pgp3Clk,                           -- [in]
         rxRst           => pgp3ClkRst,                        -- [in]
         rxMasters       => pgp3RxMasters(PGP3_NUM_VC_C-1 downto 1),                     -- [in]
         rxSlaves        => open,                              -- [in]
         rxCtrl          => pgp3RxCtrl(PGP3_NUM_VC_C-1 downto 1),                        -- [out]
         axilClk         => clk,                               -- [in]
         axilRst         => rst,                               -- [in]
         axilReadMaster  => locAxilReadMasters(PRBS_AXIL_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(PRBS_AXIL_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(PRBS_AXIL_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(PRBS_AXIL_C));  -- [out]

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => XBAR_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CFG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => srpAxilWriteMaster,
         sAxiWriteSlaves(0)  => srpAxilWriteSlave,
         sAxiReadMasters(0)  => srpAxilReadMaster,
         sAxiReadSlaves(0)   => srpAxilReadSlave,
         mAxiWriteMasters    => locAxilWriteMasters,
         mAxiWriteSlaves     => locAxilWriteSlaves,
         mAxiReadMasters     => locAxilReadMasters,
         mAxiReadSlaves      => locAxilReadSlaves);


   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G          => TPD_G,
         SIM_SPEEDUP_G  => SIM_SPEEDUP_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map (
         clk    => clk,
--         arst   => extRst,
         rstOut => rst);

   -------------------
   -- Application Core
   -------------------
--    GEN_APP_CORE: if (not NO_PGP2B_G) generate


--    U_App : entity work.AppCore
--       generic map (
--          TPD_G           => TPD_G,
--          SIMULATION_G    => SIMULATION_G,
--          BUILD_INFO_G    => BUILD_INFO_G,
--          XIL_DEVICE_G    => "ULTRASCALE",
--          MICROBLAZE_EN_G => false,
--          APP_TYPE_G      => "PGP",
--          AXIS_SIZE_G     => PGP_NUM_VC_C)
--       port map (
--          -- Clock and Reset
--          clk                => clk,
--          rst                => rst,
--          -- AXIS interface
--          txMasters          => pgpTxMasters,
--          txSlaves           => pgpTxSlaves,
--          rxMasters          => pgpRxMasters,
--          rxSlaves           => pgpRxSlaves,
--          rxCtrl             => pgpRxCtrl,
--          -- AXIL interface
--          extAxilWriteMaster => appAxilWriteMaster,
--          extAxilWriteSlave  => appAxilWriteSlave,
--          extAxilReadMaster  => appAxilReadMaster,
--          extAxilReadSlave   => appAxilReadSlave,
--          -- ADC Ports
--          vPIn               => vPIn,
--          vNIn               => vNIn);
--    end generate GEN_APP_CORE;   

   ----------------
   -- Misc. Signals
   ----------------

   U_AxiVersion_1 : entity work.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         XIL_DEVICE_G    => "ULTRASCALE",
--         SIM_DNA_VALUE_G    => SIM_DNA_VALUE_G,
--         AXI_ERROR_RESP_G   => AXI_ERROR_RESP_G,
--         DEVICE_ID_G        => DEVICE_ID_G,
         CLK_PERIOD_G    => 6.4e-9,
         EN_DEVICE_DNA_G => true,
         EN_DS2411_G     => false,
         EN_ICAP_G       => true)
--         USE_SLOWCLK_G      => USE_SLOWCLK_G,
--         BUFR_CLK_DIV_G     => BUFR_CLK_DIV_G,

      port map (
         axiClk         => clk,                                  -- [in]
         axiRst         => rst,                                  -- [in]
         axiReadMaster  => locAxilReadMasters(VERSION_AXIL_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(VERSION_AXIL_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(VERSION_AXIL_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(VERSION_AXIL_C));  -- [out]

   U_AxiMicronN25QCore_1 : entity work.AxiMicronN25QCore
      generic map (
         TPD_G            => TPD_G,
--         MEM_ADDR_MASK_G  => MEM_ADDR_MASK_G,
         AXI_CLK_FREQ_G   => 156.25e6,
--         SPI_CLK_FREQ_G   => SPI_CLK_FREQ_G,
         AXI_ERROR_RESP_G => AXI_RESP_DECERR_C)
      port map (
         csL            => bootCsL,                           -- [out]
         sck            => bootSck,                           -- [out]
         mosi           => bootMosi,                          -- [out]
         miso           => bootMiso,                          -- [in]
         axiReadMaster  => locAxilReadMasters(PROM_AXIL_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(PROM_AXIL_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(PROM_AXIL_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(PROM_AXIL_C),   -- [out]
         axiClk         => clk,                               -- [in]
         axiRst         => rst);                              -- [in]

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)          -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,             -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => di,               -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,             -- 1-bit output: PROGRAM request to fabric output
         DO        => do,               -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => "1110",           -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bootCsL,          -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',              -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => bootSck,          -- 1-bit input: User CCLK input
         USRCCLKTS => '0',              -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => rstL,             -- 1-bit input: User DONE pin output control
         USRDONETS => '0');             -- 1-bit input: User DONE 3-state enable output

   rstL     <= not(rst);                -- IPMC uses DONE to determine if FPGA is ready
   do       <= "111" & bootMosi;
   bootMiso <= di(1);



   U_Heartbeat_1 : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 6.4e-9,
         PERIOD_OUT_G => 1.0)
      port map (
         clk => clk,                    -- [in]
         rst => rst,                    -- [in]
         o   => led(6));                -- [out]

   U_Heartbeat_2 : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 6.4e-9,
         PERIOD_OUT_G => 1.0)
      port map (
         clk => pgp3Clk,                -- [in]
         rst => pgp3ClkRst,             -- [in]
         o   => led(7));                -- [out]

end top_level;
