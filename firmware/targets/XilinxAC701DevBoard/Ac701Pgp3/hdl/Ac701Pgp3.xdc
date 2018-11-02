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
set_property PACKAGE_PIN U4 [get_ports extRst]
set_property IOSTANDARD LVCMOS25 [get_ports extRst]

set_property PACKAGE_PIN A24 [get_ports {clkSelA[0]}]
set_property PACKAGE_PIN C26 [get_ports {clkSelA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelA*]

set_property PACKAGE_PIN B26 [get_ports {clkSelB[0]}]
set_property PACKAGE_PIN C24 [get_ports {clkSelB[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB*]

set_property PACKAGE_PIN M26 [get_ports {led[0]}]
set_property PACKAGE_PIN T24 [get_ports {led[1]}]
set_property PACKAGE_PIN T25 [get_ports {led[2]}]
set_property PACKAGE_PIN R26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports led*]

set_property PACKAGE_PIN AC10 [get_ports gtTxP]
set_property PACKAGE_PIN AD10 [get_ports gtTxN]
set_property PACKAGE_PIN AC12 [get_ports gtRxP]
set_property PACKAGE_PIN AD12 [get_ports gtRxN]

set_property PACKAGE_PIN AA13 [get_ports gtClkP]
set_property PACKAGE_PIN AB13 [get_ports gtClkN]

# XADC ports
set_property PACKAGE_PIN N12 [get_ports vPIn] set_property PACKAGE_PIN P11 [get_ports vNIn]

# Timing Constraints 
create_clock -name gtClkP    -period 8.000 [get_ports {gtClkP}]

create_generated_clock -name stableClk [get_pins {U_PGP/INT_REFCLK.U_pgpRefClk/ODIV2}]

create_generated_clock -name pgpRxClk2x  [get_pins {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT2}]
create_generated_clock -name pgpRxClk4x  [get_pins {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Gtp7IpWrapper/U_RX_PLL/CLKOUT1}]

create_generated_clock -name pgpTxClk1x  [get_pins {U_PGP/REAL_PGP.U_TX_PLL/CLKOUT0}]
create_generated_clock -name pgpTxClk2x  [get_pins {U_PGP/REAL_PGP.U_TX_PLL/CLKOUT2}]
create_generated_clock -name pgpTxClk4x  [get_pins {U_PGP/REAL_PGP.U_TX_PLL/CLKOUT1}]

create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 

set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk1x}] \
   -group [get_clocks {pgpTxClk2x}] \
   -group [get_clocks {pgpRxClk2x}] \   
   -group [get_clocks {stableClk}]
   
set_clock_groups -asynchronous \
   -group [get_clocks {pgpTxClk4x}] \
   -group [get_clocks {pgpRxClk4x}] \
   -group [get_clocks {stableClk}]   
   
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk1x}] -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkInv}] 
set_clock_groups -asynchronous -group [get_clocks {stableClk}]  -group [get_clocks {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Gtp7IpWrapper/GEN_6G.U_Pgp3Gtp7Ip6G/U0/Pgp3Gtp7Ip6G_i/gt0_Pgp3Gtp7Ip6G_i/gtpe2_i/RXOUTCLK}]

# .bit File Configuration
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]  
