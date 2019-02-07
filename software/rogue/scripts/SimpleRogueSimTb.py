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

import pyrogue 
import pyrogue.gui
import pyrogue.interfaces.simulation
import pyrogue.utilities.prbs
import rogue.interfaces.memory
import rogue.interfaces.stream
import surf.axi 
import surf.protocols.ssi
import rogue
import sys
import argparse

# rogue.Logging.setLevel(rogue.Logging.Warning)
# rogue.Logging.setFilter("pyrogue.SrpV3",rogue.Logging.Debug)
rogue.Logging.setLevel(rogue.Logging.Debug)

#################################################################
class Base(pyrogue.Root):

    def __init__(self,pollEn,initRead):
        pyrogue.Root.__init__(self,name='simulation',description='Simple RogueSim Example')

        # Simulation interfaces
        self.memSim    = rogue.interfaces.memory.TcpClient('127.0.0.1',9000)
        self.streamSim = rogue.interfaces.stream.TcpClient('127.0.0.1',9002,False)
        self.sbandSim  = pyrogue.interfaces.simulation.SideBandSim(host='127.0.0.1',port=9020)

        # Simulation devices
        self.add(surf.axi.AxiVersion( 
            name    = 'AxiVersion', 
            memBase = self.memSim,
            offset  = 0x00000000, 
            expand  = True,
        ))

        self.add(surf.protocols.ssi.SsiPrbsRx( 
            name    = 'SimPrbsRx', 
            memBase = self.memSim,
            offset  = 0x00010000, 
            expand  = True,
        ))

        self.add(surf.protocols.ssi.SsiPrbsTx( 
            name    = 'SimPrbsTx', 
            memBase = self.memSim,
            offset  = 0x00020000, 
            expand  = True,
        ))

        self._prbsRx = pyrogue.utilities.prbs.PrbsRx(name="SwPrbsRx")
        self._prbsTx = pyrogue.utilities.prbs.PrbsTx(name="SwPrbsTx")

        self.add(self._prbsRx)
        self.add(self._prbsTx)

        pyrogue.streamConnect(self._prbsTx,self.streamSim)
        pyrogue.streamConnect(self.streamSim,self._prbsRx)

        self.start(
            pollEn   = pollEn,
            initRead = initRead,
            timeout  = 60.0,    
        )


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
    default  = False,
    help     = "Enable read all variables at start",
)  

# Get the arguments
args = parser.parse_args()

#################################################################
with Base(args.pollEn,args.initRead) as b:

    # Create GUI
    appTop = pyrogue.gui.application(sys.argv)
    guiTop = pyrogue.gui.GuiTop(group='rootMesh')
    appTop.setStyle('Fusion')
    guiTop.addTree(b)
    guiTop.resize(600, 800)

    print("Starting GUI...\n");

    # Run GUI
    appTop.exec_()    

