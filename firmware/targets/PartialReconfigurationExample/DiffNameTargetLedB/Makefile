# Define target output
target: bit

# Define the file path to the static checkpoint
export RECONFIG_CHECKPOINT = $(PROJ_DIR)/../StaticDesign/images/StaticDesign-0x00000001-20170918153056-ruckman-27107730-static.dcp

# Define hierarchical path to dynamic module
export RECONFIG_ENDPOINT = U_LedRtlB

# Define the PBLOCK name
export RECONFIG_PBLOCK = LED_B

# Define target part
export PRJ_PART = XC7K325TFFG900-2

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/targets/shared_config.mk
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
