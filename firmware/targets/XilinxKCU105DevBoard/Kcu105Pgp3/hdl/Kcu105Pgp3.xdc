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

set_property PACKAGE_PIN U4 [get_ports pgpTxP]
set_property PACKAGE_PIN U3 [get_ports pgpTxN]
set_property PACKAGE_PIN T2 [get_ports pgpRxP]
set_property PACKAGE_PIN T1 [get_ports pgpRxN]

set_property PACKAGE_PIN P6 [get_ports pgpClkP]
set_property PACKAGE_PIN P5 [get_ports pgpClkN]

# Timing Constraints 
create_clock -name pgpClkP -period  6.400 [get_ports {pgpClkP}]

create_clock -name pgp3PhyTxClk -period 3.200 [get_pins {U_Pgp/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]
create_clock -name pgp3PhyRxClk -period 3.200 [get_pins {U_Pgp/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]

create_generated_clock -name dnaClk [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pgpClkP}] -group [get_clocks -include_generated_clocks {pgp3PhyTxClk}] -group [get_clocks -include_generated_clocks {pgp3PhyRxClk}]
set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {dnaClk}]
 
 # BITSTREAM Configurations
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design] 
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE No [current_design]
 
