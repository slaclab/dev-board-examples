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

# SGMII/Ext. PHY
set_property PACKAGE_PIN P25 [get_ports sgmiiRxN]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports sgmiiRxN]
set_property PACKAGE_PIN P24 [get_ports sgmiiRxP]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports sgmiiRxP]
set_property PACKAGE_PIN M24 [get_ports sgmiiTxN]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports sgmiiTxN]
set_property PACKAGE_PIN N24 [get_ports sgmiiTxP]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports sgmiiTxP]
set_property PACKAGE_PIN N26 [get_ports sgmiiClkN]
set_property IOSTANDARD LVDS_25 [get_ports sgmiiClkN]
set_property PACKAGE_PIN P26 [get_ports sgmiiClkP]
set_property IOSTANDARD LVDS_25 [get_ports sgmiiClkP]

# Placement - put SGMII ETH close in clock region of the 625MHz clock;
#             otherwise it is difficult to meet timing.
create_pblock SGMII_ETH_BLK
add_cells_to_pblock [get_pblocks SGMII_ETH_BLK] [get_cells GEN_SGMII.U_1GigE]
resize_pblock       [get_pblocks SGMII_ETH_BLK] -add {CLOCKREGION_X2Y1:CLOCKREGION_X2Y1}


# Timing Constraints 
create_clock -name lvdsClkP  -period 1.600 [get_ports {sgmiiClkP}]

create_generated_clock -name ethClk125MHz  [get_pins {GEN_SGMII.U_1GigE/U_MMCM/CLKOUT0}] 
