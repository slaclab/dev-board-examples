#-----------------------------------------------------------------------------
# This file is part of the 'Development Board Examples'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Development Board Examples', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue             as pr
import surf.axi            as axi
import surf.protocols.ssi  as ssi
import surf.protocols.rssi as rssi
import surf.xilinx         as xil
import surf.ethernet.udp   as udp
import time
import click

class Fpga(pr.Device):
    def __init__( self,
        name        = 'Fpga',
        fpgaType    = '',
        commType    = '',
        description = 'Fpga Container',
        **kwargs):

        super().__init__(name=name,description=description, **kwargs)

        self.add(axi.AxiVersion(
            offset = 0x00000000,
            expand = True,
        ))

        if(fpgaType=='7series'):

            self.add(xil.Xadc(
                offset = 0x00010000,
                expand = False,
            ))

        if(fpgaType=='ultrascale'):

            self.add(xil.AxiSysMonUltraScale(
                offset = 0x00020000,
                expand = False,
            ))

        # self.add(MbSharedMem(
            # name   = 'MbSharedMem',
            # offset = 0x00030000,
            # size   = 0x10000,
            # expand = False,
        # ))

        self.add(ssi.SsiPrbsTx(
            offset = 0x00040000,
            expand = False,
        ))

        self.add(ssi.SsiPrbsRx(
            offset = 0x00050000,
            expand = False,
        ))

        if ( commType == 'rudp' ):

            self.add(rssi.RssiCore(
                offset = 0x00070000,
                expand = False,
            ))

            self.add(udp.UdpEngine(
                offset = 0x00078000,
                numSrv = 1,
                expand = False,
            ))

        self.add(axi.AxiStreamMonAxiL(
            name        = 'AxisMon',
            offset      = 0x00080000,
            numberLanes = 2,
            expand      = False,
        ))

        # self.add(MbSharedMem(
            # name   = 'TestEmptyMem',
            # offset = 0x80000000,
            # size   = 0x80000000,
            # expand = False,
        # ))
