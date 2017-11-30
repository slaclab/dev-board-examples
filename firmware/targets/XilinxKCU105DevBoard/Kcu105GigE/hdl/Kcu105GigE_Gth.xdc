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

# GTH/SFP
set_property PACKAGE_PIN U4 [get_ports ethTxP]
set_property PACKAGE_PIN U3 [get_ports ethTxN]
set_property PACKAGE_PIN T2 [get_ports ethRxP]
set_property PACKAGE_PIN T1 [get_ports ethRxN]

set_property PACKAGE_PIN P6 [get_ports ethClkP]
set_property PACKAGE_PIN P5 [get_ports ethClkN]

# Timing Constraints 
create_clock -name gtClkP    -period 6.400 [get_ports {ethClkP}  ]

create_generated_clock -name ethClk125MHz  [get_pins {GEN_GTH.U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}] 
create_generated_clock -name ethClk62p5MHz [get_pins {GEN_GTH.U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}] 

set_clock_groups -asynchronous -group [get_clocks {gtClkP}] -group [get_clocks {ethClk125MHz}] 
set_clock_groups -asynchronous -group [get_clocks {gtClkP}] -group [get_clocks {ethClk62p5MHz}] 
