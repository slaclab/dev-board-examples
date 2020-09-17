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
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVDS     } [get_ports { FPGA_SYSCLK_P }]; #IO_L13P_T2_MRCC_38 Sch=fpga_sysclk_p
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVDS     } [get_ports { FPGA_SYSCLK_N }]; #IO_L13N_T2_MRCC_38 Sch=fpga_sysclk_n

# ETH1
set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS15 } [get_ports { ETH1_LED[0] }]; #IO_L12N_T1_MRCC_39 Sch=eth1_led[0]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS15 } [get_ports { ETH1_LED[1] }]; #IO_L18N_T2_39 Sch=eth1_led[1]
set_property -dict { PACKAGE_PIN N18 IOSTANDARD LVCMOS15 } [get_ports { ETH1_MOD_DETECT }]; #IO_L21N_T3_DQS_38 Sch=eth1_mod_detect
set_property -dict { PACKAGE_PIN N19 IOSTANDARD LVCMOS15 } [get_ports { ETH1_RS[0] }]; #IO_L21P_T3_DQS_38 Sch=eth1_rs[0]
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS15 } [get_ports { ETH1_RS[1] }]; #IO_L19P_T3_38 Sch=eth1_rs[1]
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS15 } [get_ports { ETH1_RX_LOS }]; #IO_L20N_T3_38 Sch=eth1_rx_los
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS15 } [get_ports { ETH1_TX_DISABLE }]; #IO_L22N_T3_38 Sch=eth1_tx_disable
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS15 } [get_ports { ETH1_TX_FAULT }]; #IO_L22P_T3_38 Sch=eth1_tx_fault

# MGT Ports
set_property PACKAGE_PIN A6 [get_ports ETH1_TX_P]
set_property PACKAGE_PIN A5 [get_ports ETH1_TX_N]
set_property PACKAGE_PIN B4 [get_ports ETH1_RX_P]
set_property PACKAGE_PIN B3 [get_ports ETH1_RX_N]

# Timing Constraints
create_clock -name sysClkP -period  5.000 [get_ports {FPGA_SYSCLK_P}]

create_generated_clock -name pgpClk    [get_pins {ClockManager7_0/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]

set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {sysClkP}]
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClkInv}]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# FPGA BIT Configurations
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
