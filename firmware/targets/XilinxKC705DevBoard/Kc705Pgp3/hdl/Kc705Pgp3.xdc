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

set_property PACKAGE_PIN H2 [get_ports gtTxP]
set_property PACKAGE_PIN H1 [get_ports gtTxN]
set_property PACKAGE_PIN G4 [get_ports gtRxP]
set_property PACKAGE_PIN G3 [get_ports gtRxN]

set_property PACKAGE_PIN G8 [get_ports gtClkP]
set_property PACKAGE_PIN G7 [get_ports gtClkN]

# Timing Constraints 
create_clock -name gtClkP -period 8.000 [get_ports {gtClkP}]

create_generated_clock -name stableClk  [get_pins {REAL_PGP.U_PGP/IBUFDS_GTE2_Inst/ODIV2}]
create_generated_clock -name pgpClk     [get_pins {REAL_PGP.U_PGP/ClockManager7_Inst/MmcmGen.U_Mmcm/CLKOUT0}] 
create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 

set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {stableClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClk}] 
set_clock_groups -asynchronous -group [get_clocks {pgpClk}] -group [get_clocks {dnaClkInv}] 

# .bit File Configuration
set_property BITSTREAM.CONFIG.CONFIGRATE 9 [current_design]  
