# IO Constraints

set_property PACKAGE_PIN AB8  [get_ports {led[0]}]
set_property PACKAGE_PIN AA8  [get_ports {led[1]}]
set_property PACKAGE_PIN AC9  [get_ports {led[2]}]
set_property PACKAGE_PIN AB9  [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports led[0]]
set_property IOSTANDARD LVCMOS15 [get_ports led[1]]
set_property IOSTANDARD LVCMOS15 [get_ports led[2]]
set_property IOSTANDARD LVCMOS15 [get_ports led[3]]

set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
set_property PACKAGE_PIN G19  [get_ports {led[5]}]
set_property PACKAGE_PIN E18  [get_ports {led[6]}]
set_property PACKAGE_PIN F16  [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports led[4]]
set_property IOSTANDARD LVCMOS25 [get_ports led[5]]
set_property IOSTANDARD LVCMOS25 [get_ports led[6]]
set_property IOSTANDARD LVCMOS25 [get_ports led[7]]

set_property PACKAGE_PIN AD12 [get_ports {clkP}]
set_property IOSTANDARD LVDS  [get_ports {clkP}]
set_property DIFF_TERM false  [get_ports {clkP}]

set_property PACKAGE_PIN AD11 [get_ports {clkN}]
set_property IOSTANDARD LVDS  [get_ports {clkN}]
set_property DIFF_TERM false  [get_ports {clkN}]

# BANK 0 Configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Timing Constraints
create_clock -period 5 -name clkP [get_ports clkP]

# CntRtl_Inst Area Constraints (static logic)
create_pblock pblock_cnt
add_cells_to_pblock [get_pblocks pblock_cnt]  [get_cells -quiet [list CntRtl_Inst]]
resize_pblock [get_pblocks pblock_cnt] -add {SLICE_X80Y50:SLICE_X109Y99}
resize_pblock [get_pblocks pblock_cnt] -add {DSP48_X3Y20:DSP48_X3Y39}
resize_pblock [get_pblocks pblock_cnt] -add {RAMB18_X3Y20:RAMB18_X3Y39}
resize_pblock [get_pblocks pblock_cnt] -add {RAMB36_X3Y10:RAMB36_X3Y19}

# LedRtlA_Inst Area Constraints (reconfigurable logic)
set_property HD.RECONFIGURABLE 1 [get_cells {U_LedRtlA}]
create_pblock LED_A
add_cells_to_pblock [get_pblocks LED_A]  [get_cells -quiet [list U_LedRtlA]]
resize_pblock [get_pblocks LED_A] -add {SLICE_X132Y50:SLICE_X145Y99}
resize_pblock [get_pblocks LED_A] -add {DSP48_X5Y20:DSP48_X5Y39}
resize_pblock [get_pblocks LED_A] -add {RAMB18_X5Y20:RAMB18_X6Y39}
resize_pblock [get_pblocks LED_A] -add {RAMB36_X5Y10:RAMB36_X6Y19}
set_property RESET_AFTER_RECONFIG 1 [get_pblocks LED_A]; # 7-series only
set_property SNAPPING_MODE ON [get_pblocks {LED_A}]

# LedRtlB_Inst Area Constraints (reconfigurable logic)
set_property HD.RECONFIGURABLE 1 [get_cells {U_LedRtlB}]
create_pblock LED_B
add_cells_to_pblock [get_pblocks LED_B]  [get_cells -quiet [list U_LedRtlB]]
resize_pblock [get_pblocks LED_B] -add {SLICE_X132Y100:SLICE_X145Y149}
resize_pblock [get_pblocks LED_B] -add {DSP48_X5Y40:DSP48_X5Y59}
resize_pblock [get_pblocks LED_B] -add {RAMB18_X5Y40:RAMB18_X6Y59}
resize_pblock [get_pblocks LED_B] -add {RAMB36_X5Y20:RAMB36_X6Y29}
set_property RESET_AFTER_RECONFIG 1 [get_pblocks LED_B]; # 7-series only
set_property SNAPPING_MODE ON [get_pblocks {LED_B}]
