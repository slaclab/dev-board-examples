#-----------------------------------------------------------------------------
# This file is part of the 'Development Board Examples'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Development Board Examples', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import setupLibPaths

import sys
import argparse
import time
import logging

import pyrogue as pr
import pyrogue.gui
import pyrogue.pydm
import pyrogue.protocols
import pyrogue.utilities.prbs

import rogue
import rogue.hardware.axi
import rogue.interfaces.stream

import DevBoard as devBoard

#################################################################

#rogue.Logging.setLevel(rogue.Logging.Warning)
#rogue.Logging.setLevel(rogue.Logging.Debug)
#rogue.Logging.setFilter("pyrogue.rssi",rogue.Logging.Info)
#rogue.Logging.setFilter("pyrogue.packetizer",rogue.Logging.Info)
# # rogue.Logging.setLevel(rogue.Logging.Debug)

#logger = logging.getLogger('pyrogue')
#logger.setLevel(logging.DEBUG)

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
    "--enPrbs",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable PRBS testing",
)

parser.add_argument('--html', help='Use html for tables', action="store_true")

# Get the arguments
args = parser.parse_args()

#################################################################

class MyRoot(pr.Root):
    def __init__(   self,
            name        = "MyRoot",
            description = "my root container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        #################################################################

        # DataDev PCIe Card (used for PGP PCIe applications)
        if ( args.type == 'datadev' ):

            self.vc0Srp  = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*0x100)+0,True)
            self.vc1Prbs = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*0x100)+1,True)

        # RUDP Ethernet
        elif ( args.type == 'eth' ):

            # Create the ETH interface @ IP Address = args.dev
            self.rudp = pr.protocols.UdpRssiPack(
                host    = args.ip,
                port    = 8192,
                packVer = 2,
                jumbo   = True,
                expand  = False,
                )
            self.add(self.rudp)

            # Map the AxiStream.TDEST
            self.vc0Srp  = self.rudp.application(0); # AxiStream.tDest = 0x0
            self.vc1Prbs = self.rudp.application(1); # AxiStream.tDest = 0x1

        # Undefined device type
        else:
            raise ValueError("Invalid type (%s)" % (args.type) )

        #################################################################

        # Connect VC0 to SRPv3
        self.srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(self.vc0Srp,self.srp)

        if args.enPrbs:

            # Connect VC1 to FW TX PRBS
            self.prbsRx = pyrogue.utilities.prbs.PrbsRx(name='PrbsRx',width=128,expand=False)
            pyrogue.streamConnect(self.vc1Prbs,self.prbsRx)
            self.add(self.prbsRx)

            # Connect VC1 to FW RX PRBS
            self.prbTx = pyrogue.utilities.prbs.PrbsTx(name="PrbsTx",width=128,expand=False)
            pyrogue.streamConnect(self.prbTx, self.vc1Prbs)
            self.add(self.prbTx)

        else:
            pyrogue.streamConnect(self.vc1Prbs,self.vc1Prbs)

        # Add registers
        self.add(devBoard.Fpga(
            memBase  = self.srp,
            commType = args.type,
            fpgaType = args.fpgaType,
            expand   = True,
        ))

#################################################################

with MyRoot(
        name        = 'System',
        description = 'Front End Board',
        pollEn      = args.pollEn,
        initRead    = args.initRead,
    ) as root:

    pyrogue.pydm.runPyDM(root=root)

#################################################################
