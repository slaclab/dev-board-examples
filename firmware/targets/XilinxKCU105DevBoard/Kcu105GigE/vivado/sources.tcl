set genericArgList [get_property generic [current_fileset]]

if { "$::env(USE_RJ45_ETH)" != 0 } {
   lappend genericArgList "SGMII_ETH_G=1"
}

set_property generic ${genericArgList} -objects [current_fileset]
