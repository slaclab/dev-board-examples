# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/" -fileType "VHDL 2008"
loadConstraints -dir "$::DIR_PATH/hdl/"

# Load Simulation
loadSource -sim_only -path "$::DIR_PATH/tb/Kcu105DspFloatTestTb.vhd" -fileType "VHDL 2008"
set_property top "Kcu105DspFloatTestTb" [get_filesets sim_1]
