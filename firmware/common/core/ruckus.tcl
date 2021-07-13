# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir  "$::DIR_PATH/rtl"

# Set the board part
if { $::env(PRJ_PART) eq {XC7A200TFBG676-2} } {
   set_property board_part xilinx.com:ac701:part0:1.4 [current_project]

} elseif { $::env(PRJ_PART) eq {XC7K325TFFG900-2} } {
   set_property board_part xilinx.com:kc705:part0:1.6 [current_project]

} elseif { $::env(PRJ_PART) eq {XCKU040-FFVA1156-2-E} } {
   set_property board_part xilinx.com:kcu105:part0:1.6 [current_project]

} elseif { $::env(PRJ_PART) eq {XCKU5P-FFVB676-2-E} } {
   set_property board_part xilinx.com:kcu116:part0:1.5 [current_project]

} else {
}
