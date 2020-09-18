##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN H2 [get_ports gtTxP]
set_property PACKAGE_PIN H1 [get_ports gtTxN]
set_property PACKAGE_PIN G4 [get_ports gtRxP]
set_property PACKAGE_PIN G3 [get_ports gtRxN]

set_property PACKAGE_PIN G8 [get_ports gtClkP]
set_property PACKAGE_PIN G7 [get_ports gtClkN]

# Timing Constraints
create_clock -name gtClkP -period 8.000    [get_ports {gtClkP}]

create_generated_clock -name ethClk125MHz  [get_pins {U_ETH_PHY_MAC/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name ethClk62p5MHz [get_pins {U_ETH_PHY_MAC/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name dnaClk    [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_generated_clock -name dnaClkInv [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]

set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {ethClk125MHz}] -group [get_clocks {dnaClkInv}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_ETH_PHY_MAC/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_7SERIES.Iprog7Series_Inst/DIVCLK_GEN.BUFR_ICPAPE2/O]]
