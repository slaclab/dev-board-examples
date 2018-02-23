export GIT_BYPASS = 0

# Define target output
target: bit

# Define Firmware Version Number
export PRJ_VERSION = 0x00000001

# Define target part
export PRJ_PART = XC7VX690TFFG1761-3

# # Define the Microblaze source path
# export SDK_SRC_PATH = $(PROJ_DIR)/../../../common/core/src

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
