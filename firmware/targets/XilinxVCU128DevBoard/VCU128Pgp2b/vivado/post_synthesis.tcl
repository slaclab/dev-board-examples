##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# # Bypass the debug chipscope generation
# return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_0

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {clk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {pgpRxOut[linkDown]}
ConfigProbe ${ilaName} {pgpRxOut[linkReady]}
ConfigProbe ${ilaName} {pgpRxOut[phyRxReady]}
ConfigProbe ${ilaName} {pgpRxOut[remLinkReady]}

ConfigProbe ${ilaName} {pgpTxOut[linkReady]}
ConfigProbe ${ilaName} {pgpTxOut[phyTxReady]}

#ConfigProbe ${ilaName} {rst}
#ConfigProbe ${ilaName} {rstL}
ConfigProbe ${ilaName} {ledInt[*]}

#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/txResetDone}
#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/txReset}
#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/stableRst}
#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/rxResetDone}
#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/rxReset}
#ConfigProbe ${ilaName} {REAL_PGP.U_PGP/PgpGtyCoreWrapper_1/drpRdy}

ConfigProbe ${ilaName} {REAL_PGP.U_PGP/gtRxUserReset}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/gtTxUserReset}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/phyRxInit}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/phyRxInitSync}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/resetGtSync}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/resetRxSync}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/stableRst}
ConfigProbe ${ilaName} {REAL_PGP.U_PGP/gtHardReset}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName}
