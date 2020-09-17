# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../submodules/surf

# Load local source Code
loadSource -path "$::DIR_PATH/hdl/LedRtlB.vhd"

# Load local constraints
loadConstraints -path "$::DIR_PATH/hdl/LedRtlB.xdc"

# Set the top-level RTL
set_property top {LedRtlB} [current_fileset]

