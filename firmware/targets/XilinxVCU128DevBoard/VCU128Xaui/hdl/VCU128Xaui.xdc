##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGtyUltraScale_Inst/U_XauiGtyUltraScaleCore/U0/XauiGtyUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gtye4_top.XauiGtyUltraScale156p25MHz10GigECore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
