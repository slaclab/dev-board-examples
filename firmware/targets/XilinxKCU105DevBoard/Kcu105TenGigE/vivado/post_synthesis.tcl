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
SetDebugCoreClk ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/clk_i}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/inputAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/outputAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/crcOut[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/packetNumberRam[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/packetActiveRam}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/sentEofeRam}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[state][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[activeTDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[packetNumber][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[packetActive]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[sentEofe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[ramWe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_DEPACKER.DEPACKER_V2.U_Depacketizer/r[sideband]}

#################################################################################################################################

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/inputAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/outputAxisMaster[tData][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/outputAxisMaster[tUser][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/outputAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/outputAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/outputAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/crcOut[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/packetNumberOut[*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[activeTDest][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[lastByteCount][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[packetNumber][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[state][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[tUserLast][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[wordCount][*]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/packetActiveOut}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[ramWe]}
ConfigProbe ${ilaName} {U_App/GEN_ETH.U_EthPortMapping/U_RssiServer/GEN_PACKER.PACKER_V2.U_Packetizer/r[rearbitrate]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 
