##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_generated_clock -name ethClk125MHz [get_pins {U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name ethClk62MHz  [get_pins {U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]

set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {gtClkP}]
set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {dnaClk}]

set_clock_groups -asynchronous -group [get_clocks {ethClk62MHz}] -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks {ethClk62MHz}] -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]
