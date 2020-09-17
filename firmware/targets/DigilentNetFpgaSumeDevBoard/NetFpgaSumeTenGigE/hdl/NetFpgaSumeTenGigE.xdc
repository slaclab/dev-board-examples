##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# System Clock signal (200 MHz)
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVDS } [get_ports { sysClkP }]; #IO_L13P_T2_MRCC_38 Sch=fpga_sysclk_p
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVDS } [get_ports { sysClkN }]; #IO_L13N_T2_MRCC_38 Sch=fpga_sysclk_n

# SFP+ Control Ports (ETH1)
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS15 } [get_ports { sfpLed1[0] }]; #IO_L18N_T2_39 Sch=eth1_led[1]
set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS15 } [get_ports { sfpLed0[0] }]; #IO_L12N_T1_MRCC_39 Sch=eth1_led[0]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS15 } [get_ports { sfpTxDisable[0] }]; #IO_L22N_T3_38 Sch=eth1_tx_disable

# SFP+ Control Ports (ETH2)
set_property -dict { PACKAGE_PIN BA20  IOSTANDARD LVCMOS15 } [get_ports { sfpLed1[1] }]; #IO_L22N_T3_32 Sch=eth2_led[1]
set_property -dict { PACKAGE_PIN AL22  IOSTANDARD LVCMOS15 } [get_ports { sfpLed0[1] }]; #IO_L6P_T0_33 Sch=eth2_led[0]
set_property -dict { PACKAGE_PIN B31   IOSTANDARD LVCMOS15 } [get_ports { sfpTxDisable[1] }]; #IO_L18N_T2_37 Sch=eth2_tx_disable

# SFP+ Control Ports (ETH3)
set_property -dict { PACKAGE_PIN AY17  IOSTANDARD LVCMOS15 } [get_ports { sfpLed1[2] }]; #IO_L13N_T2_MRCC_32 Sch=eth3_led[1]
set_property -dict { PACKAGE_PIN AY18  IOSTANDARD LVCMOS15 } [get_ports { sfpLed0[2] }]; #IO_L13P_T2_MRCC_32 Sch=eth3_led[0]
set_property -dict { PACKAGE_PIN J38   IOSTANDARD LVCMOS15 } [get_ports { sfpTxDisable[2] }]; #IO_L22N_T3_35 Sch=eth3_tx_disable

# SFP+ Control Ports (ETH4)
set_property -dict { PACKAGE_PIN K32 IOSTANDARD LVCMOS15 } [get_ports { sfpLed1[3] }]; #IO_L12N_T1_MRCC_34 Sch=eth4_led[1]
set_property -dict { PACKAGE_PIN P31 IOSTANDARD LVCMOS15 } [get_ports { sfpLed0[3] }]; #IO_L18N_T2_34 Sch=eth4_led[0]
set_property -dict { PACKAGE_PIN L21 IOSTANDARD LVCMOS15 } [get_ports { sfpTxDisable[3] }]; #IO_L18N_T2_36 Sch=eth4_tx_disable

# ETH MGT Ports (ETH1_TX_P/N)
set_property PACKAGE_PIN A6  [get_ports ethRxP]
set_property PACKAGE_PIN A5  [get_ports ethRxN]
set_property PACKAGE_PIN B4  [get_ports ethTxP]
set_property PACKAGE_PIN B3  [get_ports ethTxN]

# PGP MGT Ports (ETH4_TX_P/N)
set_property PACKAGE_PIN D8 [get_ports pgpRxP]
set_property PACKAGE_PIN D7 [get_ports pgpRxN]
set_property PACKAGE_PIN E2 [get_ports pgpTxP]
set_property PACKAGE_PIN E1 [get_ports pgpTxN]

# Timing Constraints
create_clock -name sysClkP -period  5.000 [get_ports {sysClkP}]
# create_clock -name ethClk  -period  6.400 [get_pins {U_XAUI/XauiGth7_Inst/U_XauiGth7Core/U0/gt_wrapper_i/gt0_XauiGth7Core_gt_wrapper_i/gthe2_i/TXOUTCLK}]

create_generated_clock -name ethRefClk [get_pins {ClockManager7_0/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]

set ethTxClk {U_10GigE/GEN_LANE[0].TenGigEthGth7_Inst/U_TenGigEthGth7Core/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_gth_10gbaser_i/gthe2_i/TXOUTCLK}
set ethRxClk {U_10GigE/GEN_LANE[0].TenGigEthGth7_Inst/U_TenGigEthGth7Core/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_gth_10gbaser_i/gthe2_i/RXOUTCLK}

set_clock_groups -asynchronous -group [get_clocks {ethRefClk}] -group [get_clocks ${ethTxClk}]
set_clock_groups -asynchronous -group [get_clocks {ethRefClk}] -group [get_clocks ${ethRxClk}]
set_clock_groups -asynchronous -group [get_clocks {ethRefClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {ethRefClk}] -group [get_clocks {dnaClkInv}]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# FPGA BIT Configurations
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
