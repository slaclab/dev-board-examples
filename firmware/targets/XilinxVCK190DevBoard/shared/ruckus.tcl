# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2020.2 of Vivado
if { [VersionCheck 2020.2] < 0 } {exit -1}

# Load local source Code and constraints
# loadSource      -dir "$::DIR_PATH/rtl"
loadConstraints -dir "$::DIR_PATH/xdc"
