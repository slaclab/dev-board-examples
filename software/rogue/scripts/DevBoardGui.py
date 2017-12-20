#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : PyRogue DevBoardGui Module
#-----------------------------------------------------------------------------
# File       : DevBoardGui.py
# Author     : Larry Ruckman <ruckman@slac.stanford.edu>
# Created    : 2017-02-15
# Last update: 2017-02-15
#-----------------------------------------------------------------------------
# Description:
# Rogue interface to DEV board
#-----------------------------------------------------------------------------
# This file is part of the 'Development Board Examples'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'Development Board Examples', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import rogue.hardware.pgp
import pyrogue as pr
import pyrogue.utilities.fileio
import pyrogue.gui
import pyrogue.protocols
import DevBoard
import threading
import signal
import atexit
import yaml
import time
import sys
import PyQt4.QtGui
import argparse

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Add arguments
parser.add_argument(
    "--type", 
    type     = str,
    required = True,
    help     = "define the type of interface",
)  

parser.add_argument(
    "--dev", 
    type     = str,
    required = False,
    default  = '/dev/datadev_0',
    help     = "true to show gui",
) 

# Get the arguments
args = parser.parse_args()

#################################################################

# Set base
system = pr.Root(name='System',description='Front End Board')

# File writer
dataWriter = pr.utilities.fileio.StreamWriter(name='dataWriter')
system.add(dataWriter)

if ( args.type == 'pcie-datadev' ):

    pgpVc0    = rogue.hardware.data.DataCard(args.dev,0)
    pgpVc1    = rogue.hardware.data.DataCard(args.dev,1)
    
    # Create and Connect SRPv3 to VC1
    srp = rogue.protocols.srp.SrpV3()
    # srp = rogue.protocols.srp.SrpV0()
    pr.streamConnectBiDir(pgpVc0,srp)
    
    # Add data stream to file as channel 1
    pr.streamConnect(pgpVc1,dataWriter.getChannel(0x1))        

elif ( args.type == 'pcie-pgp' ):

    pgpVc0 = rogue.hardware.pgp.PgpCard(args.dev,0,0) # Registers
    pgpVc1 = rogue.hardware.pgp.PgpCard(args.dev,0,1) # Data
    
    # Create and Connect SRPv3 to VC1
    srp = rogue.protocols.srp.SrpV3()
    # srp = rogue.protocols.srp.SrpV0()
    pr.streamConnectBiDir(pgpVc0,srp)
    
    # Add data stream to file as channel 1
    pr.streamConnect(pgpVc1,dataWriter.getChannel(0x1))    

elif ( args.type == 'eth' ):

    # Create the ETH interface @ IP Address = args.dev
    ethLink = pr.protocols.UdpRssiPack(host=args.dev,port=8192,size=1400)    

    # Create and Connect SrpV3 to AxiStream.tDest = 0x0
    srp = rogue.protocols.srp.SrpV3()  
    pr.streamConnectBiDir(srp,ethLink.application(0))

    # Add data stream to file as channel 1 to tDest = 0x1
    pr.streamConnect(ethLink.application(1),dataWriter.getChannel(0x1))
    
else:
    raise ValueError("Invalid type (%s)" % (args.type) )
    
# Add registers
system.add(DevBoard.feb(memBase=srp))

# Start the system
# system.start(pollEn=False)    
system.start(pollEn=True)    
system.ReadAll()
   
# system.add(pyrogue.RunControl('runControl',
                            # rates={1:'1 Hz', 10:'10 Hz',100:'100 Hz'}, 
                            # #cmd=system.feb.sysReg.softTrig()))
                            # #cmd=None))
                            # cmd=runTest))

# Create GUI
appTop = PyQt4.QtGui.QApplication(sys.argv)
guiTop = pr.gui.GuiTop(group='PyRogueGui')
guiTop.resize(800, 1000)
guiTop.addTree(system)

# Run gui
appTop.exec_()

# Stop mesh after gui exits
system.stop()
