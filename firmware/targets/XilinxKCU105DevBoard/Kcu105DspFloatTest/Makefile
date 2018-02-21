export GIT_BYPASS = 1

# Define target output
target: bit

# Define Firmware Version Number
export PRJ_VERSION = 0x00000002

# Define target part
export PRJ_PART = XCKU040-FFVA1156-2-E

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
