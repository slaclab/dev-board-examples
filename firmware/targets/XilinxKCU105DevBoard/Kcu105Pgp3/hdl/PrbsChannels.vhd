library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.Pgp3Pkg.all;

entity PrbsChannels is

   generic (
      TPD_G            : time             := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := (others => '0');
      CHANNELS_G       : integer          := 4);

   port (
      txClk     : in  sl;
      txRst     : in  sl;
      txMasters : out AxiStreamMasterArray(CHANNELS_G-1 downto 0);
      txSlaves  : in  AxiStreamSlaveArray(CHANNELS_G-1 downto 0);

      rxClk     : in  sl;
      rxRst     : in  sl;
      rxMasters : in  AxiStreamMasterArray(CHANNELS_G-1 downto 0);
      rxSlaves  : out AxiStreamSlaveArray(CHANNELS_G-1 downto 0);
      rxCtrl    : out AxiStreamCtrlArray(CHANNELS_G-1 downto 0);

      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType
      );

end entity PrbsChannels;

architecture rtl of PrbsChannels is

   constant XBAR_CFG_C : AxiLiteCrossbarMasterConfigArray(CHANNELS_G*2-1 downto 0) :=
      genAxiLiteConfig(CHANNELS_G*2, AXIL_BASE_ADDR_G, 24, 16);

   signal prbsAxilWriteMasters : AxiLiteWriteMasterArray(CHANNELS_G*2-1 downto 0);
   signal prbsAxilWriteSlaves  : AxiLiteWriteSlaveArray(CHANNELS_G*2-1 downto 0);
   signal prbsAxilReadMasters  : AxiLiteReadMasterArray(CHANNELS_G*2-1 downto 0);
   signal prbsAxilReadSlaves   : AxiLiteReadSlaveArray(CHANNELS_G*2-1 downto 0);

begin

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => CHANNELS_G*2,
         MASTERS_CONFIG_G   => XBAR_CFG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => prbsAxilWriteMasters,
         mAxiWriteSlaves     => prbsAxilWriteSlaves,
         mAxiReadMasters     => prbsAxilReadMasters,
         mAxiReadSlaves      => prbsAxilReadSlaves);

   PRBS_GEN : for i in 0 to CHANNELS_G-1 generate
      U_SsiPrbsTx_1 : entity work.SsiPrbsTx
         generic map (
            TPD_G                      => TPD_G,
            GEN_SYNC_FIFO_G            => false,
            PRBS_INCREMENT_G           => false,
            PRBS_SEED_SIZE_G           => 64,
            PRBS_TAPS_G                => (0 => 63, 1 => 3, 2 => 2),
            MASTER_AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C)
         port map (
            mAxisClk        => txClk,                      -- [in]
            mAxisRst        => txRst,                      -- [in]
            mAxisMaster     => txMasters(i),               -- [out]
            mAxisSlave      => txSlaves(i),                -- [in]
            locClk          => axilClk,                    -- [in]
            locRst          => axilRst,                    -- [in]
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
            PRBS_SEED_SIZE_G          => 64,
            PRBS_TAPS_G               => (0 => 63, 1 => 3, 2 => 2),
            SLAVE_AXI_STREAM_CONFIG_G => PGP3_AXIS_CONFIG_C,
            SLAVE_AXI_PIPE_STAGES_G   => 1)
         port map (
            sAxisClk       => rxClk,                        -- [in]
            sAxisRst       => rxRst,                        -- [in]
            sAxisMaster    => rxMasters(i),                 -- [in]
            sAxisSlave     => rxSlaves(i),                  -- [out]
            sAxisCtrl      => rxCtrl(i),                    -- [out]
            mAxisClk       => axilClk,                      -- [in]
            mAxisRst       => axilRst,                      -- [in]
            axiClk         => axilClk,                      -- [in]
            axiRst         => axilRst,                      -- [in]
            axiReadMaster  => prbsAxilReadMasters(2*i+1),   -- [in]
            axiReadSlave   => prbsAxilReadSlaves(2*i+1),    -- [out]
            axiWriteMaster => prbsAxilWriteMasters(2*i+1),  -- [in]
            axiWriteSlave  => prbsAxilWriteSlaves(2*i+1));  -- [out]

   end generate PRBS_GEN;
end architecture rtl;
