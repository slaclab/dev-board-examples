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

import pyrogue as pr
import DevBoard as devBoard
import pyrogue.gui
import pyrogue.protocols
import pyrogue.utilities.prbs
import rogue.hardware.pgp
import rogue.hardware.axi
import sys
import argparse

# rogue.Logging.setLevel(rogue.Logging.Warning)
#rogue.Logging.setFilter("pyrogue.rssi",rogue.Logging.Info)
#rogue.Logging.setFilter("pyrogue.packetizer",rogue.Logging.Info)
# # rogue.Logging.setLevel(rogue.Logging.Debug)

#################################################################

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

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

parser.add_argument(
    "--ip", 
    type     = str,
    required = False,
    default  = '192.168.2.10',
    help     = "IP address",
) 

parser.add_argument(
    "--lane", 
    type     = int,
    required = False,
    default  = 0,
    help     = "PGP Lane",
) 

parser.add_argument(
    "--packVer", 
    type     = int,
    required = False,
    default  = 2,
    help     = "RSSI's Packetizer Version",
) 

parser.add_argument(
    "--fpgaType", 
    type     = str,
    required = False,
    default  = '',
    help     = "fpgaType = [empty_string,7series,ultrascale]",
) 

parser.add_argument(
    "--pollEn", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "auto-polling",
)  

parser.add_argument(
    "--initRead", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)  

parser.add_argument(
    "--rawRate", 
    action   = "store_true",
    help     = "Run raw register rate test"
)  

parser.add_argument(
    "--varRate", 
    action   = "store_true",
    help     = "Run variable register rate test"
)  

parser.add_argument('--html', help='Use html for tables', action="store_true")
# Get the arguments
args = parser.parse_args()

#################################################################

# DataDev PCIe Card
if ( args.type == 'datadev' ):

    vc0Srp  = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*32)+0,True)
    vc1Prbs = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*32)+1,True)
    # vc1Prbs.setZeroCopyEn(False)
    
# RUDP Ethernet
elif ( args.type == 'eth' ):

    # Create the ETH interface @ IP Address = args.dev
    rudp = pr.protocols.UdpRssiPack(
        host    = args.ip,
        port    = 8192,
        packVer = args.packVer,
        )    

    # Map the AxiStream.TDEST
    vc0Srp  = rudp.application(0); # AxiStream.tDest = 0x0
    vc1Prbs = rudp.application(1); # AxiStream.tDest = 0x1
    # vc1Prbs.setZeroCopyEn(False)
        
# Legacy PGP PCIe Card
elif ( args.type == 'pgp' ):

    vc0Srp  = rogue.hardware.pgp.PgpCard(args.dev,args.lane,0) # Registers
    vc1Prbs = rogue.hardware.pgp.PgpCard(args.dev,args.lane,1) # Data
    # vc1Prbs.setZeroCopyEn(False)

# Undefined device type
else:
    raise ValueError("Invalid type (%s)" % (args.type) )
    
#################################################################    

# Set base
rootTop = pr.Root(name='System',description='Front End Board')
    
# Connect VC0 to SRPv3
srp = rogue.protocols.srp.SrpV3()
pr.streamConnectBiDir(vc0Srp,srp)  

# # Connect VC1 to FW TX PRBS
prbsRx = pyrogue.utilities.prbs.PrbsRx(name='PrbsRx',width=128,expand=False)
pyrogue.streamConnect(vc1Prbs,prbsRx)
rootTop.add(prbsRx)  
    
# # Connect VC1 to FW RX PRBS
prbTx = pyrogue.utilities.prbs.PrbsTx(name="PrbsTx",width=128,expand=False)
pyrogue.streamConnect(prbTx, vc1Prbs)
rootTop.add(prbTx)  
    
# Loopback the PRBS data
#pyrogue.streamConnect(vc1Prbs,vc1Prbs)    
    
# Add registers
rootTop.add(devBoard.Fpga(
    memBase  = srp,
    commType = args.type,
    fpgaType = args.fpgaType,
))

if ( args.type == 'eth' ):
    rootTop.add(rudp)

#################################################################    

# Start the system
rootTop.start(
    pollEn   = args.pollEn,
    initRead = args.initRead,
)
# rootTop.setTimeout(5)

# Print the AxiVersion Summary
rootTop.Fpga.AxiVersion.printStatus()

# Rate testers
if args.varRate: rootTop.Fpga.varRateTest()
if args.rawRate: rootTop.Fpga.rawRateTest()

# Create GUI
appTop = pr.gui.application(sys.argv)
guiTop = pr.gui.GuiTop(group='PyRogueGui')
guiTop.addTree(rootTop)
guiTop.resize(800, 1200)

print("Starting GUI...\n");

# Run gui
appTop.exec_()

#################################################################    

# Stop mesh after gui exits
rootTop.stop()
exit()

#################################################################
