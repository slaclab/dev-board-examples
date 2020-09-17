# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../submodules/surf

# Load local source Code
loadSource -path "$::DIR_PATH/hdl/LedRtlA.vhd"

# Load local constraints
loadConstraints -path "$::DIR_PATH/hdl/LedRtlA.xdc"
