##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
# I/O Port Mapping

set_property -dict { PACKAGE_PIN V12 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN W11 IOSTANDARD ANALOG } [get_ports { vNIn }]

set_property -dict { PACKAGE_PIN AN8 IOSTANDARD LVCMOS18 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN AP8 IOSTANDARD LVCMOS18 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN H23 IOSTANDARD LVCMOS18 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS18 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN P21 IOSTANDARD LVCMOS18 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS18 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN M22 IOSTANDARD LVCMOS18 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN R23 IOSTANDARD LVCMOS18 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS18 } [get_ports { led[7] }]

# MDIO/Ext. PHY
set_property PACKAGE_PIN K25     [get_ports "phyIrqN"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyIrqN"]
set_property PACKAGE_PIN L25     [get_ports "phyMdc"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyMdc"]
set_property PACKAGE_PIN H26     [get_ports "phyMdio"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyMdio"]
set_property PACKAGE_PIN J23     [get_ports "phyRstN"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyRstN"]

# GPIO DIP Switch
set_property PACKAGE_PIN AN16 [get_ports "gpioDip[0]"]
set_property IOSTANDARD LVCMOS12 [get_ports "gpioDip[0]"]
set_property PACKAGE_PIN AN19 [get_ports "gpioDip[1]"]
set_property IOSTANDARD LVCMOS12 [get_ports "gpioDip[1]"]
set_property PACKAGE_PIN AP18 [get_ports "gpioDip[2]"]
set_property IOSTANDARD LVCMOS12 [get_ports "gpioDip[2]"]
set_property PACKAGE_PIN AN14 [get_ports "gpioDip[3]"]
set_property IOSTANDARD LVCMOS12 [get_ports "gpioDip[3]"]

# On-Board System clock
set_property ODT RTT_48 [get_ports "sysClk300N"]
set_property PACKAGE_PIN AK16 [get_ports "sysClk300N"]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports "sysClk300N"]
set_property PACKAGE_PIN AK17 [get_ports "sysClk300P"]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports "sysClk300P"]
set_property ODT RTT_48 [get_ports "sysClk300P"]

create_generated_clock -name dnaClk        [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {dnaClk}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins GEN_GTH.U_1GigE/GEN_INT_PLL.U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins GEN_GTH.U_1GigE/GEN_INT_PLL.U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]]
