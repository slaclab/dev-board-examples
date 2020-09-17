##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# PROM configuration
set format     "mcs"
set inteface   "bpix16"
set size       "1024"

###############################################
# Static  Image = [0x00000000:0x01FFFFFF] range
# LedRtlA Image = [0x02000000:0x03FFFFFF] range
# LedRtlB Image = [0x04000000:0x05FFFFFF] range
###############################################

# Boot Address = 0x00000000  (no overlap with dynamic images)
set loadbit "up 0x0 $::env(IMPL_DIR)/$::env(PROJECT).bit"
