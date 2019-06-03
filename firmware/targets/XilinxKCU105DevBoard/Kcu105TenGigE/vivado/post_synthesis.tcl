##############################################################################
## This file is part of 'DUNE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'DUNE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Bypass the debug chipscope generation
return

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
set_property C_DATA_DEPTH 4096 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/clk}

#######################
## Set the debug Probes
#######################

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/axisMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/axisMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/axisMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/axisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/axisSlave[tReady]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxSlave[tReady]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxMaster[tData][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxSlave[tReady]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxTLastTUser[*]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxCtrl[idle]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxCtrl[pause]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/rxCtrl[overflow]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[state][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[hdrCnt][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[opCode][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[remVer][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[addr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[memResp][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[reqSize][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[tid][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[tidDly][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[frameError]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[verMismatch]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[timeout]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[reqSizeError]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[skip]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/r[rxRst]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiMaster_i[eof]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiMaster_i[eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiMaster_i[packed]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiMaster_i[sof]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiMaster_i[valid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiSlave_o[ready]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[ackErr]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[appDrop]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[bufferFull]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[bufferEmpty]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[lenErr]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[tspSsiMaster][eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[tspSsiSlave][overflow]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/tspSsiSlave_i[overflow]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[pending][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/lastAckN_i[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[appState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxAckN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxLastSeqN][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[inOrderSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[tspState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/appSsiSlave_i[overflow]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[appSsiMaster][eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][ack]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][busy]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][data]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][eack]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][nul]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][rst]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][syn]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[segDrop]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[segValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[tspSsiMaster][eofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/rxBuffBusy_o}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/chksumValid_i}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
