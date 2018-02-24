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
SetDebugCoreClk ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/clk_i}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tData][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/mAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/sAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tData][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tDest][*]}
# ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/mAxisSlave[tReady]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
