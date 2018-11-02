-------------------------------------------------------------------------------
-- File       : SystemManagementWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-01-30
-- Last update: 2017-03-17
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

entity SystemManagementWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      axiClk         : in  sl;
      axiRst         : in  sl;
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;
      vPIn           : in  sl;
      vNIn           : in  sl);
end entity SystemManagementWrapper;

architecture mapping of SystemManagementWrapper is

   signal axiRstL : sl;

begin

   axiRstL <= not axiRst;

   SystemManagementCore_Inst : entity work.SystemManagementCore
      port map (
         s_axi_aclk    => axiClk,
         s_axi_aresetn => axiRstL,
         s_axi_awaddr  => axiWriteMaster.awaddr(12 downto 0),
         s_axi_awvalid => axiWriteMaster.awvalid,
         s_axi_awready => axiWriteSlave.awready,
         s_axi_wdata   => axiWriteMaster.wdata,
         s_axi_wstrb   => axiWriteMaster.wstrb,
         s_axi_wvalid  => axiWriteMaster.wvalid,
         s_axi_wready  => axiWriteSlave.wready,
         s_axi_bresp   => axiWriteSlave.bresp,
         s_axi_bvalid  => axiWriteSlave.bvalid,
         s_axi_bready  => axiWriteMaster.bready,
         s_axi_araddr  => axiReadMaster.araddr(12 downto 0),
         s_axi_arvalid => axiReadMaster.arvalid,
         s_axi_arready => axiReadSlave.arready,
         s_axi_rdata   => axiReadSlave.rdata,
         s_axi_rresp   => axiReadSlave.rresp,
         s_axi_rvalid  => axiReadSlave.rvalid,
         s_axi_rready  => axiReadMaster.rready,
         ip2intc_irpt  => open,
         vp            => vpIn,
         vn            => vnIn,
         channel_out   => open,
         eoc_out       => open,
         alarm_out     => open,
         eos_out       => open,
         busy_out      => open);

end architecture mapping;
