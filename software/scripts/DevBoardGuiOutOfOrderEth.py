#!/usr/bin/env python3
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
import threading

import pyrogue as pr
import pyrogue.gui
import pyrogue.protocols
import pyrogue.utilities.prbs

import rogue
import rogue.hardware.axi
import rogue.interfaces.stream
import rogue.hardware.pgp

import DevBoard as devBoard

# rogue.Logging.setLevel(rogue.Logging.Warning)
# rogue.Logging.setLevel(rogue.Logging.Debug)

#rogue.Logging.setFilter("pyrogue.rssi",rogue.Logging.Info)
#rogue.Logging.setFilter("pyrogue.packetizer",rogue.Logging.Info)
# # rogue.Logging.setLevel(rogue.Logging.Debug)

# logger = logging.getLogger('pyrogue')
# logger.setLevel(logging.DEBUG)

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
    "--varRate",
    action   = "store_true",
    help     = "Run variable register rate test"
)

parser.add_argument(
    "--enPrbs",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable PRBS testing",
)

parser.add_argument(
    "--ooo",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Force Ethernet Out-of-order",
)

parser.add_argument('--html', help='Use html for tables', action="store_true")

# Get the arguments
args = parser.parse_args()

#################################################################

class RssiOutOfOrder(rogue.interfaces.stream.Slave, rogue.interfaces.stream.Master):

    def __init__(self, period=0):
        rogue.interfaces.stream.Slave.__init__(self)
        rogue.interfaces.stream.Master.__init__(self)

        self._period = period
        self._lock   = threading.Lock()
        self._last   = None
        self._cnt    = 0

    @property
    def period(self,value):
        return self._period

    @period.setter
    def period(self,value):
        with self._lock:
            self._period = value

            # Send any cached frames if period is now 0
            if self._period == 0 and self._last is not None:
                self._sendFrame(self._last)
                self._last = None

    def _acceptFrame(self,frame):

        with self._lock:
            self._cnt += 1

            # Frame is cached, send current frame before cached frame
            if self._last is not None:
                self._sendFrame(frame)
                self._sendFrame(self._last)
                self._last = None

            # Out of order period has elapsed, store frame
            elif self._period > 0 and (self._cnt % self._period) == 0:
                self._last = frame

            # Otherwise just forward the frame
            else:
                self._sendFrame(frame)

#################################################################

class MyRoot(pr.Root):
    def __init__(   self,
            name        = "MyRoot",
            description = "my root container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        #################################################################

        # DataDev PCIe Card
        if ( args.type == 'datadev' ):

            self.vc0Srp  = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*0x100)+0,True)
            self.vc1Prbs = rogue.hardware.axi.AxiStreamDma(args.dev,(args.lane*0x100)+1,True)
            # self.vc1Prbs.setZeroCopyEn(False)

        # RUDP Ethernet
        elif ( args.type == 'eth' ):

            # Check for forcing out-of-order ETH frames on outbound
            if ( args.ooo ):

                # UDP Client
                self.cUdp = rogue.protocols.udp.Client(args.ip,8192,True);

                # RSSI Client
                self.cRssi = rogue.protocols.rssi.Client(self.cUdp.maxPayload())

                # Packetizer
                if args.packVer == 1:
                    self.rudp = rogue.protocols.packetizer.Core(True)
                else:
                    self.rudp = rogue.protocols.packetizer.CoreV2(True,True,True)

                # Out of order module on client side
                self.coo = RssiOutOfOrder(period=0)

                # Client stream
                pyrogue.streamConnectBiDir(self.cRssi.application(),self.rudp.transport())

                # Insert out of order in the outbound direction
                pyrogue.streamConnect(self.cRssi.transport(),self.coo)
                pyrogue.streamConnect(self.coo, self.cUdp)
                pyrogue.streamConnect(self.cUdp,self.cRssi.transport())

                # Start RSSI with out of order disabled
                self.cRssi.start()

            else:
                # Create the ETH interface @ IP Address = args.dev
                self.rudp = pr.protocols.UdpRssiPack(
                    host    = args.ip,
                    port    = 8192,
                    packVer = args.packVer,
                    jumbo   = True,
                    expand  = False,
                    )
                # self.add(self.rudp)

            # Map the AxiStream.TDEST
            self.vc0Srp  = self.rudp.application(0); # AxiStream.tDest = 0x0
            self.vc1Prbs = self.rudp.application(1); # AxiStream.tDest = 0x1
            # self.vc1Prbs.setZeroCopyEn(False)

        # Legacy PGP PCIe Card
        elif ( args.type == 'pgp' ):

            self.vc0Srp  = rogue.hardware.pgp.PgpCard(args.dev,args.lane,0) # Registers
            self.vc1Prbs = rogue.hardware.pgp.PgpCard(args.dev,args.lane,1) # Data
            # self.vc1Prbs.setZeroCopyEn(False)

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
        ))

# Set base
rootTop = MyRoot(name='System',description='Front End Board')

#################################################################
# Start the system
rootTop.start(
    pollEn   = args.pollEn,
    initRead = args.initRead,
)

# Check for forcing out-of-order ETH frames on outbound
if ( args.type == 'eth' ) and (args.ooo) :
    print ('Enable out of order with a period of 3')
    rootTop.coo.period = 0

# time.sleep(10)


# # Print the AxiVersion Summary
# rootTop.Fpga.AxiVersion.printStatus()

# # Rate testers
# if args.varRate: rootTop.Fpga.varRateTest()

# Create GUI
appTop = pr.gui.application(sys.argv)
guiTop = pr.gui.GuiTop()
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
