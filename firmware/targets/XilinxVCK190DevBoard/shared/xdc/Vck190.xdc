##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { PACKAGE_PIN AE42 IOSTANDARD LVDS15 } [get_ports { ddr4SmaClkP }]
set_property -dict { PACKAGE_PIN AF43 IOSTANDARD LVDS15 } [get_ports { ddr4SmaClkN }]

set_property -dict { PACKAGE_PIN H34 IOSTANDARD LVCMOS18 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN J33 IOSTANDARD LVCMOS18 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN K36 IOSTANDARD LVCMOS18 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN L35 IOSTANDARD LVCMOS18 } [get_ports { led[3] }]

# Timing Constraints
create_clock -name ddr4SmaClkP -period 5.000 [get_ports {ddr4SmaClkP}]
