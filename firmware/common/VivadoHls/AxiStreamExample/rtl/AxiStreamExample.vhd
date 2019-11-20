-------------------------------------------------------------------------------
-- File       : AxiStreamExample.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper on the Vivado HLS AXI Stream Example
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;

entity AxiStreamExample is
   generic (
      TPD_G : time := 1 ns);
   port (
      axisClk     : in  sl;
      axisRst     : in  sl;
      -- Slave Port
      sAxisMaster : in  AxiStreamMasterType;
      sAxisSlave  : out AxiStreamSlaveType;
      -- Master Port
      mAxisMaster : out AxiStreamMasterType;
      mAxisSlave  : in  AxiStreamSlaveType);
end AxiStreamExample;

architecture rtl of AxiStreamExample is

   component AxiStreamExampleCore
      port (
         ap_clk            : in  std_logic;
         ap_rst_n          : in  std_logic;
         -- Inbound Interface
         axisSlave_TVALID  : in  std_logic;
         axisSlave_TDATA   : in  std_logic_vector(31 downto 0);
         axisSlave_TKEEP   : in  std_logic_vector(3 downto 0);
         axisSlave_TSTRB   : in  std_logic_vector(3 downto 0);
         axisSlave_TUSER   : in  std_logic_vector(1 downto 0);
         axisSlave_TLAST   : in  std_logic_vector(0 downto 0);
         axisSlave_TID     : in  std_logic_vector(0 downto 0);
         axisSlave_TDEST   : in  std_logic_vector(0 downto 0);
         axisSlave_TREADY  : out std_logic;
         -- Outbound Interface
         axisMaster_TVALID : out std_logic;
         axisMaster_TDATA  : out std_logic_vector(31 downto 0);
         axisMaster_TKEEP  : out std_logic_vector(3 downto 0);
         axisMaster_TSTRB  : out std_logic_vector(3 downto 0);
         axisMaster_TUSER  : out std_logic_vector(1 downto 0);
         axisMaster_TLAST  : out std_logic_vector(0 downto 0);
         axisMaster_TID    : out std_logic_vector(0 downto 0);
         axisMaster_TDEST  : out std_logic_vector(0 downto 0);
         axisMaster_TREADY : in  std_logic);
   end component;

   signal axisRstL   : sl;
   signal axisMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;

begin

   axisRstL    <= not(axisRst);
   mAxisMaster <= axisMaster;

   AxiStreamExampleCore_inst : AxiStreamExampleCore
      port map (
         ap_clk              => axisClk,
         ap_rst_n            => axisRstL,
         -- Inbound Interface
         axisSlave_TVALID    => sAxisMaster.tValid,
         axisSlave_TDATA     => sAxisMaster.tData(31 downto 0),
         axisSlave_TKEEP     => sAxisMaster.tKeep(3 downto 0),
         axisSlave_TSTRB     => sAxisMaster.tStrb(3 downto 0),
         axisSlave_TUSER     => sAxisMaster.tUser(1 downto 0),
         axisSlave_TLAST(0)  => sAxisMaster.tLast,
         axisSlave_TID       => sAxisMaster.tId(0 downto 0),
         axisSlave_TDEST     => sAxisMaster.tDest(0 downto 0),
         axisSlave_TREADY    => sAxisSlave.tReady,
         -- Outbound Interface
         axisMaster_TVALID   => axisMaster.tValid,
         axisMaster_TDATA    => axisMaster.tData(31 downto 0),
         axisMaster_TKEEP    => axisMaster.tKeep(3 downto 0),
         axisMaster_TSTRB    => axisMaster.tStrb(3 downto 0),
         axisMaster_TUSER    => axisMaster.tUser(1 downto 0),
         axisMaster_TLAST(0) => axisMaster.tLast,
         axisMaster_TID      => axisMaster.tId(0 downto 0),
         axisMaster_TDEST    => axisMaster.tDest(0 downto 0),
         axisMaster_TREADY   => mAxisSlave.tReady);

end rtl;
