#!/usr/bin/env python3
##############################################################################
## This file is part of 'Development Board Examples'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'Development Board Examples', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

import pyrogue as pr
import pyrogue.gui
import pyrogue.interfaces.simulation
import surf.axi as axiVer
import rogue
import sys
import argparse

# rogue.Logging.setLevel(rogue.Logging.Warning)
# rogue.Logging.setFilter("pyrogue.SrpV3",rogue.Logging.Debug)
# rogue.Logging.setLevel(rogue.Logging.Debug)

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--pollEn", 
    type     = argBool,
    required = False,
    default  = False,
    help     = "Enable auto-polling",
) 

parser.add_argument(
    "--initRead", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)  

# Get the arguments
args = parser.parse_args()

#################################################################

# Set base
base = pr.Root(name='simulation',description='Simple RogueSim Example')

# Connect the SRPv3 stream port
srpStream = pr.interfaces.simulation.StreamSim(host='localhost', dest=0, uid=1, ssi=True)
memMap = rogue.protocols.srp.SrpV3()                
pr.streamConnectBiDir( memMap, srpStream )  

# Add devices
base.add(axiVer.AxiVersion( 
    name    = 'AxiVersion', 
    memBase = memMap, 
    offset  = 0x00000000, 
    expand  = False,
))

# Start the system
base.start(
    pollEn   = args.pollEn,
    initRead = args.initRead,
    timeout  = 1.0,    
)

# Create GUI
appTop = pr.gui.application(sys.argv)
guiTop = pr.gui.GuiTop(group='rootMesh')
appTop.setStyle('Fusion')
guiTop.addTree(base)
guiTop.resize(600, 800)

print("Starting GUI...\n");

# Run GUI
appTop.exec_()    
    
# Close
base.stop()
exit()   
