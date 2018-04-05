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
SetDebugCoreClk ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/axisClk}

#######################
## Set the debug Probes
#######################

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/r[state][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/r[packetNumber][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/r[frameNumber][*]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/inputAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/inputAxisMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/inputAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/inputAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/inputAxisSlave[tReady]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/outputAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/outputAxisMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/outputAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/outputAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V1.U_Depacketizer/outputAxisSlave[tReady]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/r[state][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/r[packetNumber][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/r[frameNumber][*]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/inputAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/inputAxisMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/inputAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/inputAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/inputAxisSlave[tReady]}

# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/outputAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/outputAxisMaster[tUser][1]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/outputAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/outputAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V1.U_Packetizer/outputAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_sAppAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_sAppAxisMaster[tUser][1]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_sAppAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_sAppAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/appSsiSlave_o[ready]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/mTspAxisMaster_o[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/mTspAxisMaster_o[tUser][1]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/mTspAxisMaster_o[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/mTspAxisMaster_o[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/mTspAxisSlave_i[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[firstUnackAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[nextSentAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[lastSentAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[lastAckSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[bufferFull]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[bufferEmpty]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[ackErr]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[ackState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[appState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[rxSegmentAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[rxBufferAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[rxSegmentWe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[sndData]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[lenErr]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[appBusy]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[nextSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[seqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[txHeaderAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[txSegmentAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[txBufferAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[tspState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[txRdy]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[buffWe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[buffSent]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[chkEn]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[chkStb]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[synH]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[ackH]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[rstH]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[nullH]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[dataH]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[dataD]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[resend]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/TxFSM_INST/r[ackSndData]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
