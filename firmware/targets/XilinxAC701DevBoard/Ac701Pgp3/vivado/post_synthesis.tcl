##############################################################################
## This file is part of 'LCLS Laserlocker Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'LCLS Laserlocker Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# Bypass the debug chipscope generation
return

# Get variables and procedures
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Open the synthesis design
open_run synth_1

# TX ILA Core
set ilaName u_ila_tx_fast

CreateDebugCore ${ilaName}

set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

SetDebugCoreClk ${ilaName} {clk}

ConfigProbe ${ilaName} {pgpTxOut[linkReady]}
ConfigProbe ${ilaName} {pgpRxOut[remRxLinkReady]}
ConfigProbe ${ilaName} {pgpRxOut[phyRxActive]}
ConfigProbe ${ilaName} {pgpRxOut[linkReady]}

ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/locRxLinkReady}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/protTxData[*]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/protTxHeader[*]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/protTxValid}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/protTxReady}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Tx_1/U_Pgp3TxProtocol_1/phyTxActive}

ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/U_Pgp3RxProtocol_1/protRxHeader[*]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/U_Pgp3RxProtocol_1/protRxData[*]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/U_Pgp3RxProtocol_1/protRxValid}

ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[gearboxAligned]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[phyRxInit]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[frameRxErr]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[frameRx]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[frameRxErr]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[ebOverflow]}
ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Core/U_Pgp3Rx_1/pgpRxOut[cellError]}

WriteDebugProbes ${ilaName}

# # RX ILA Core
# set ilaName u_ila_rx_fast

# CreateDebugCore ${ilaName}

# set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

# SetDebugCoreClk ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/phyRxClk}

# ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/phyRxValid}
# ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/phyRxSlip}
# ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/phyRxHeader[*]}
# ConfigProbe ${ilaName} {U_PGP/REAL_PGP.GEN_LANE[0].U_Pgp/phyRxData[*]}

# WriteDebugProbes ${ilaName}
