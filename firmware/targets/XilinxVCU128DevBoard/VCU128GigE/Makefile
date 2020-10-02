# Define target output
target: prom

# Define Firmware Version Number
export PRJ_VERSION = 0x00000001

# Define target part
export PRJ_PART = XCVU37P-FSVH2892-2L-E

# # Define the Microblaze source path
# export SDK_SRC_PATH = $(PROJ_DIR)/../../../common/core/src

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
