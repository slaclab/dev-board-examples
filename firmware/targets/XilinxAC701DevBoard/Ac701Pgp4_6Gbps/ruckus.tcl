# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../
loadRuckusTcl $::env(PROJ_DIR)/../shared

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

# Load local SIM source Code
set_property top {Pgp3Gtp7Tb} [get_filesets sim_1]

## Place and Route strategies
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

## Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
