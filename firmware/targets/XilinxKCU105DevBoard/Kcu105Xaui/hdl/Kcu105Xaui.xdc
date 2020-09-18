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

# 1st SFP channel on FMC card
set_property PACKAGE_PIN F6 [get_ports ethTxP[0]]
set_property PACKAGE_PIN F5 [get_ports ethTxN[0]]
set_property PACKAGE_PIN E4 [get_ports ethRxP[0]]
set_property PACKAGE_PIN E3 [get_ports ethRxN[0]]

# 2nd SFP channel on FMC card
set_property PACKAGE_PIN D6 [get_ports ethTxP[1]]
set_property PACKAGE_PIN D5 [get_ports ethTxN[1]]
set_property PACKAGE_PIN D2 [get_ports ethRxP[1]]
set_property PACKAGE_PIN D1 [get_ports ethRxN[1]]

# 3rd SFP channel on FMC card
set_property PACKAGE_PIN C4 [get_ports ethTxP[2]]
set_property PACKAGE_PIN C3 [get_ports ethTxN[2]]
set_property PACKAGE_PIN B2 [get_ports ethRxP[2]]
set_property PACKAGE_PIN B1 [get_ports ethRxN[2]]

# 4th SFP channel on FMC card
set_property PACKAGE_PIN B6 [get_ports ethTxP[3]]
set_property PACKAGE_PIN B5 [get_ports ethTxN[3]]
set_property PACKAGE_PIN A4 [get_ports ethRxP[3]]
set_property PACKAGE_PIN A3 [get_ports ethRxN[3]]

# 1st Osc. on FMC card
#set_property PACKAGE_PIN K6 [get_ports ethClkP]
#set_property PACKAGE_PIN K5 [get_ports ethClkN]

# 2nd Osc. on FMC card
set_property PACKAGE_PIN H6 [get_ports ethClkP]
set_property PACKAGE_PIN H5 [get_ports ethClkN]

# FMC card: Control IOs
####################################################################################
####################################################################################
# NOTE: Requires modifying the FMC's VADJ from 2.5V to 1.8V (else could damage FPGA)
####################################################################################
####################################################################################
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS18 } [get_ports { fmcLed[0] }]
set_property -dict { PACKAGE_PIN C21 IOSTANDARD LVCMOS18 } [get_ports { fmcLed[1] }]
set_property -dict { PACKAGE_PIN E23 IOSTANDARD LVCMOS18 } [get_ports { fmcLed[2] }]
set_property -dict { PACKAGE_PIN E22 IOSTANDARD LVCMOS18 } [get_ports { fmcLed[3] }]

set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpLossL[0] }]
set_property -dict { PACKAGE_PIN K11 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpLossL[1] }]
set_property -dict { PACKAGE_PIN E8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpLossL[2] }]
set_property -dict { PACKAGE_PIN L12 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpLossL[3] }]

set_property -dict { PACKAGE_PIN C24 IOSTANDARD LVCMOS18 } [get_ports { fmcTxFault[0] }]
set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS18 } [get_ports { fmcTxFault[1] }]
set_property -dict { PACKAGE_PIN K8  IOSTANDARD LVCMOS18 } [get_ports { fmcTxFault[2] }]
set_property -dict { PACKAGE_PIN F8  IOSTANDARD LVCMOS18 } [get_ports { fmcTxFault[3] }]

set_property -dict { PACKAGE_PIN D24 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpTxDisable[0] }]
set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpTxDisable[1] }]
set_property -dict { PACKAGE_PIN L8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpTxDisable[2] }]
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpTxDisable[3] }]

set_property -dict { PACKAGE_PIN D8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpRateSel[0] }]
set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpRateSel[1] }]
set_property -dict { PACKAGE_PIN J8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpRateSel[2] }]
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpRateSel[3] }]

set_property -dict { PACKAGE_PIN C8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpModDef0[0] }]
set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpModDef0[1] }]
set_property -dict { PACKAGE_PIN H8  IOSTANDARD LVCMOS18 } [get_ports { fmcSfpModDef0[2] }]
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS18 } [get_ports { fmcSfpModDef0[3] }]

# Timing Constraints
create_clock -name ethClkP -period  6.400 [get_ports {ethClkP}]

create_generated_clock -name ethClk [get_pins {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name dnaClk [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {ethClk}] -group [get_clocks {dnaClk}]

# Placement Constraints
# Note: This had to be done because there is a placement bug in Vivado 2014.4
#       where declaring the PACKAGE_PIN didn't place GTHE3_CHANNEL correctly.
set_property LOC GTHE3_CHANNEL_X0Y19 [get_cells {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y18 [get_cells {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[2].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y17 [get_cells {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[1].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_CHANNEL_X0Y16 [get_cells {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST}]
set_property LOC GTHE3_COMMON_X0Y4   [get_cells {U_XAUI/XauiGthUltraScale_Inst/GEN_10GIGE.GEN_156p25MHz.U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_common.gen_common_container[0].gen_enabled_common.gthe3_common_wrapper_inst/common_inst/gthe3_common_gen.GTHE3_COMMON_PRIM_INST}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_XAUI/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe3_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]]
