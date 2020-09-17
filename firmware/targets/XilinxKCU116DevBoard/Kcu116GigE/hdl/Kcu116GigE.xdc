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

set_property -dict { PACKAGE_PIN P14 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD ANALOG } [get_ports { vNIn }]

set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN F9  IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN F10 IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN G9  IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS33 } [get_ports { led[7] }]

set_property -dict { PACKAGE_PIN AB14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[0] }]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[1] }]
set_property -dict { PACKAGE_PIN AA15 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[2] }]
set_property -dict { PACKAGE_PIN Y15  IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[3] }]

set_property PACKAGE_PIN N5 [get_ports ethTxP[0]]
set_property PACKAGE_PIN N4 [get_ports ethTxN[0]]
set_property PACKAGE_PIN M2 [get_ports ethRxP[0]]
set_property PACKAGE_PIN M1 [get_ports ethRxN[0]]

set_property PACKAGE_PIN L5 [get_ports ethTxP[1]]
set_property PACKAGE_PIN L4 [get_ports ethTxN[1]]
set_property PACKAGE_PIN K2 [get_ports ethRxP[1]]
set_property PACKAGE_PIN K1 [get_ports ethRxN[1]]

set_property PACKAGE_PIN J5 [get_ports ethTxP[2]]
set_property PACKAGE_PIN J4 [get_ports ethTxN[2]]
set_property PACKAGE_PIN H2 [get_ports ethRxP[2]]
set_property PACKAGE_PIN H1 [get_ports ethRxN[2]]

set_property PACKAGE_PIN G5 [get_ports ethTxP[3]]
set_property PACKAGE_PIN G4 [get_ports ethTxN[3]]
set_property PACKAGE_PIN F2 [get_ports ethRxP[3]]
set_property PACKAGE_PIN F1 [get_ports ethRxN[3]]

set_property PACKAGE_PIN M7 [get_ports ethClkP]
set_property PACKAGE_PIN M6 [get_ports ethClkN]

# Timing Constraints
create_clock -name ethClkP -period  6.400 [get_ports {ethClkP}]

create_generated_clock -name ethClk125MHz [get_pins {U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name ethClk62MHz  [get_pins {U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name dnaClk       [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {ethClkP}]
set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {dnaClk}]

set_clock_groups -asynchronous -group [get_clocks {ethClk62MHz}] -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks {ethClk62MHz}] -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]]
