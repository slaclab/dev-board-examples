# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf

# Load target's source code and constraints
loadSource -sim_only -dir "$::env(PROJ_DIR)/tb"

# Set the top level synth_1 and sim_1
set_property top {AxiVersion}       [get_filesets {sources_1}]
set_property top {SimpleRogueSimTb} [get_filesets {sim_1}]
