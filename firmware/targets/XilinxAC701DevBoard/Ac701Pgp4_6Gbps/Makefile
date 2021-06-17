# Use the PGPv3 6G core
export INCLUDE_PGP3_6G = 1

# Define target output
target: prom

# Define Firmware Version Number
export PRJ_VERSION = 0x00000009

# Define target part
export PRJ_PART = XC7A200TFBG676-2

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
