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
set_property PACKAGE_PIN AB7 [get_ports extRst]
set_property IOSTANDARD LVCMOS15 [get_ports extRst]

set_property PACKAGE_PIN AB8  [get_ports {led[0]}]
set_property PACKAGE_PIN AA8  [get_ports {led[1]}]
set_property PACKAGE_PIN AC9  [get_ports {led[2]}]
set_property PACKAGE_PIN AB9  [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports led[0]]
set_property IOSTANDARD LVCMOS15 [get_ports led[1]]
set_property IOSTANDARD LVCMOS15 [get_ports led[2]]
set_property IOSTANDARD LVCMOS15 [get_ports led[3]]

set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
set_property PACKAGE_PIN G19  [get_ports {led[5]}]
set_property PACKAGE_PIN E18  [get_ports {led[6]}]
set_property PACKAGE_PIN F16  [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports led[4]]
set_property IOSTANDARD LVCMOS25 [get_ports led[5]]
set_property IOSTANDARD LVCMOS25 [get_ports led[6]]
set_property IOSTANDARD LVCMOS25 [get_ports led[7]]

# 1st SFP channel on FMC card
set_property PACKAGE_PIN D2 [get_ports ethTxP]
set_property PACKAGE_PIN D1 [get_ports ethTxN]
set_property PACKAGE_PIN E4 [get_ports ethRxP]
set_property PACKAGE_PIN E3 [get_ports ethRxN]

# 1st Osc. on FMC card
set_property PACKAGE_PIN C8 [get_ports ethClkP]
set_property PACKAGE_PIN C7 [get_ports ethClkN]

# 2nd Osc. on FMC card
#set_property PACKAGE_PIN E8 [get_ports ethClkP]
#set_property PACKAGE_PIN E7 [get_ports ethClkN]

set_property PACKAGE_PIN F18 [get_ports {fmcLed[0]}]
set_property PACKAGE_PIN G18 [get_ports {fmcLed[1]}]
set_property PACKAGE_PIN E21 [get_ports {fmcLed[2]}]
set_property PACKAGE_PIN F21 [get_ports {fmcLed[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcLed*]

set_property PACKAGE_PIN A28 [get_ports {fmcSfpLossL[0]}]
set_property PACKAGE_PIN G27 [get_ports {fmcSfpLossL[1]}]
set_property PACKAGE_PIN D28 [get_ports {fmcSfpLossL[2]}]
set_property PACKAGE_PIN G28 [get_ports {fmcSfpLossL[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcSfpLossL*]

set_property PACKAGE_PIN E20 [get_ports {fmcTxFault[0]}]
set_property PACKAGE_PIN B28 [get_ports {fmcTxFault[1]}]
set_property PACKAGE_PIN C30 [get_ports {fmcTxFault[2]}]
set_property PACKAGE_PIN E28 [get_ports {fmcTxFault[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcTxFault*]

set_property PACKAGE_PIN F20 [get_ports {fmcSfpTxDisable[0]}]
set_property PACKAGE_PIN A26 [get_ports {fmcSfpTxDisable[1]}]
set_property PACKAGE_PIN D29 [get_ports {fmcSfpTxDisable[2]}]
set_property PACKAGE_PIN G30 [get_ports {fmcSfpTxDisable[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcSfpTxDisable*]

set_property PACKAGE_PIN C24 [get_ports {fmcSfpRateSel[0]}]
set_property PACKAGE_PIN F27 [get_ports {fmcSfpRateSel[1]}]
set_property PACKAGE_PIN E29 [get_ports {fmcSfpRateSel[2]}]
set_property PACKAGE_PIN F28 [get_ports {fmcSfpRateSel[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcSfpRateSel*]

set_property PACKAGE_PIN B24 [get_ports {fmcSfpModDef0[0]}]
set_property PACKAGE_PIN C29 [get_ports {fmcSfpModDef0[1]}]
set_property PACKAGE_PIN E30 [get_ports {fmcSfpModDef0[2]}]
set_property PACKAGE_PIN G29 [get_ports {fmcSfpModDef0[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports fmcSfpModDef0*]

# Timing Constraints 
create_clock -name ethClkP -period  3.200 [get_ports {ethClkP}]

create_generated_clock  -name ethClk    [get_pins {U_10GigE/TenGigEthGtx7Clk_Inst/IBUFDS_GTE2_Inst/ODIV2}]  
create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 

set ethTxClk {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}
set ethRxClk {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK}

set_clock_groups -asynchronous -group [get_clocks {ethClk}] -group [get_clocks ${ethTxClk}]                               
set_clock_groups -asynchronous -group [get_clocks {ethClk}] -group [get_clocks ${ethRxClk}]                
set_clock_groups -asynchronous -group [get_clocks {ethClk}] -group [get_clocks {dnaClk}] 
set_clock_groups -asynchronous -group [get_clocks {ethClk}] -group [get_clocks {dnaClkInv}]                

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_10GigE/TenGigEthGtx7Clk_Inst/IBUFDS_GTE2_Inst/ODIV2]] -group [get_clocks {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}]

# .bit File Configuration
set_property BITSTREAM.CONFIG.CONFIGRATE 9 [current_design]  
