# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2017.2 of Vivado (or later)
if { [VersionCheck 2017.2] < 0 } {exit -1}

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../submodules/surf

# Load local source Code
loadSource -path "$::DIR_PATH/hdl/CntRtl.vhd"
loadSource -path "$::DIR_PATH/hdl/StaticDesign.vhd"
loadSource -path "$::DIR_PATH/hdl/LedRtlA.vhd"
loadSource -path "$::DIR_PATH/hdl/LedRtlB.vhd"

# Load local constraints
loadConstraints -path "$::DIR_PATH/hdl/StaticDesign.xdc"
loadConstraints -path "$::DIR_PATH/hdl/LedRtlA.xdc"
loadConstraints -path "$::DIR_PATH/hdl/LedRtlB.xdc"

# Check if the partial reconfiguration not applied yet
if { [get_property PR_FLOW [current_project]] != 1 } {

   # Configure for partial reconfiguration
   set_property PR_FLOW 1 [current_project]

   #######################################################################################
   # Define the partial reconfiguration partitions
   # Note: TCL commands below were copied from GUI mode's TCL console
   #      Refer to UG947's "Partial Reconfiguration Project Flow"
   #######################################################################################
   create_partition_def -name LED_A -module LedRtlA
   create_partition_def -name LED_B -module LedRtlB

   create_reconfig_module -name LedRtlA -partition_def [get_partition_defs LED_A ]  -define_from LedRtlA
   create_reconfig_module -name LedRtlB -partition_def [get_partition_defs LED_B ]  -define_from LedRtlB

   create_pr_configuration -name config_1 -partitions [list U_LedRtlA:LedRtlA U_LedRtlB:LedRtlB ]
   set_property PR_CONFIGURATION config_1 [get_runs impl_1]
}