##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN N12 [get_ports vPIn] set_property PACKAGE_PIN P11 [get_ports vNIn]

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
set_property IOSTANDARD LVCMOS33 [get_ports led*]

######################################
# BITSTREAM: .bit file Configuration #
######################################

# for Quad SPI
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Sets the EMCCLK in the FPGA to divide by 1
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-4 [current_design]

# Shrinks the bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Improves the speed of SPI loading
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.SPI_OPCODE 0x6B [current_design]

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { bootCsL }];
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports { bootMosi }];
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { bootMiso }];

set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { emcClk }]
