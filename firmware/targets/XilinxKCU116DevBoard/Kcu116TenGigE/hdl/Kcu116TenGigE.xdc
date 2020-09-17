##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

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

create_generated_clock -name dnaClk [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {ethClkP}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks ethClkP] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks ethClkP] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks ethClkP]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
