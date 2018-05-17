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
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/clk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_App/U_Reg/U_XBAR/sAxiWriteMasters[0][awvalid]}
ConfigProbe ${ilaName} {U_App/U_Reg/U_XBAR/sAxiWriteMasters[0][wvalid]}
ConfigProbe ${ilaName} {U_App/U_Reg/U_XBAR/sAxiWriteMasters[0][bready]}
ConfigProbe ${ilaName} {U_App/U_Reg/U_XBAR/sAxiWriteSlaves[*}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/sAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/sAxisMaster[tUser][1]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/sAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/sAxisSlave[*}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/mAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/mAxisMaster[tUser][1]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/mAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_SRPv3/mAxisSlave[*}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_rxSeqN[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_rxLastSeqN[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_rxAckN[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_rxLastAckN[*]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_mAppAxisCtrl[pause]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_mAppAxisCtrl[overflow]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_mTspAxisCtrl[pause]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/s_mTspAxisCtrl[overflow]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/Monitor_INST/r[sndResend]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/chksumValid_i}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[segValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[segDrop]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[tspState][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[appState][*]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxF][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxBufferAddr][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[windowArray][*][occupied]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxHeadLen][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[inorderSeqN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/r[rxAckN][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/txWindowSize_i[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/U_RssiCore/RxFSM_INST/s_chksumOk}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
