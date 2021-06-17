#-----------------------------------------------------------------------------
# This file is part of the 'Development Board Examples'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Development Board Examples', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue  as pr
import DevBoard as devBoard

import pyrogue.protocols
import pyrogue.utilities.prbs

import rogue
import rogue.hardware.axi
import rogue.interfaces.stream

class MyRoot(pr.Root):
    def __init__(   self,
            name        = "MyRoot",
            description = "my root container",
            type        = 'datadev',
            dev         = '/dev/datadev_0',
            ip          = '192.168.2.10',
            lane        = 0,
            enPrbs      = True,
            jumbo       = False,
            fpgaType    = '',
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        #################################################################

        # DataDev PCIe Card (used for PGP PCIe applications)
        if ( type == 'pcie' ):

            self.vc0Srp  = rogue.hardware.axi.AxiStreamDma(dev,(lane*0x100)+0,True)
            self.vc1Prbs = rogue.hardware.axi.AxiStreamDma(dev,(lane*0x100)+1,True)

        # RUDP Ethernet
        elif ( type == 'rudp' ):

            # Create the ETH interface @ IP Address = ip
            self.rudp = pr.protocols.UdpRssiPack(
                host    = ip,
                port    = 8192,
                packVer = 2,
                jumbo   = jumbo,
                expand  = False,
                )
            self.add(self.rudp)

            # Map the AxiStream.TDEST
            self.vc0Srp  = self.rudp.application(0); # AxiStream.tDest = 0x0
            self.vc1Prbs = self.rudp.application(1); # AxiStream.tDest = 0x1

        # Undefined device type
        else:
            raise ValueError("Invalid type (%s)" % (type) )

        #################################################################

        # Connect VC0 to SRPv3
        self.srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(self.vc0Srp,self.srp)

        if enPrbs:

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
            commType = type,
            fpgaType = fpgaType,
            expand   = True,
        ))
