-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
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

library unisim;
use unisim.vcomponents.all;

entity BootProm is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- AXI-Lite Interface
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMasters  : in  AxiLiteReadMasterArray(1 downto 0);
      axilReadSlaves   : out AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMasters : in  AxiLiteWriteMasterArray(1 downto 0);
      axilWriteSlaves  : out AxiLiteWriteSlaveArray(1 downto 0);
      -- System Ports
      emcClk           : in  sl;
      -- Boot Memory Ports
      flashCsL         : out sl;
      flashMosi        : out sl;
      flashMiso        : in  sl;
      flashHoldL       : out sl;
      flashWp          : out sl);
end BootProm;

architecture mapping of BootProm is

   signal bootCsL  : slv(1 downto 0);
   signal bootSck  : slv(1 downto 0);
   signal bootMosi : slv(1 downto 0);
   signal bootMiso : slv(1 downto 0);
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);
   signal sck      : sl;

   signal eos      : sl;
   signal userCclk : sl;

   signal spiBusyIn  : slv(1 downto 0);
   signal spiBusyOut : slv(1 downto 0);

begin

   spiBusyIn(0) <= spiBusyOut(1);
   spiBusyIn(1) <= spiBusyOut(0);

   GEN_VEC : for i in 1 downto 0 generate

      U_BootProm : entity surf.AxiMicronN25QCore
         generic map (
            TPD_G          => TPD_G,
            AXI_CLK_FREQ_G => 156.25E+6,         -- units of Hz
            SPI_CLK_FREQ_G => (156.25E+6/16.0))  -- units of Hz
         port map (
            -- FLASH Memory Ports
            csL            => bootCsL(i),
            sck            => bootSck(i),
            mosi           => bootMosi(i),
            miso           => bootMiso(i),
            -- Shared SPI Interface
            busyIn         => spiBusyIn(i),
            busyOut        => spiBusyOut(i),
            -- AXI-Lite Register Interface
            axiReadMaster  => axilReadMasters(i),
            axiReadSlave   => axilReadSlaves(i),
            axiWriteMaster => axilWriteMasters(i),
            axiWriteSlave  => axilWriteSlaves(i),
            -- Clocks and Resets
            axiClk         => axilClk,
            axiRst         => axilRst);

   end generate GEN_VEC;

   flashCsL    <= bootCsL(1);
   flashMosi   <= bootMosi(1);
   bootMiso(1) <= flashMiso;
   flashHoldL  <= '1';
   flashWp     <= '1';

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => di,  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => eos,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
         DO        => do,  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => "1110",  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bootCsL(0),  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => userCclk,         -- 1-bit input: User CCLK input
         USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',  -- 1-bit input: User DONE pin output control
         USRDONETS => '0');  -- 1-bit input: User DONE 3-state enable output

   do          <= "111" & bootMosi(0);
   bootMiso(0) <= di(1);
   sck         <= uOr(bootSck);

   userCclk <= emcClk when(eos = '0') else sck;

end mapping;
