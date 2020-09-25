#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue feb Module
#-----------------------------------------------------------------------------
# File       : _feb.py
# Created    : 2017-02-15
# Last update: 2017-02-15
#-----------------------------------------------------------------------------
# Description:
# PyRogue Feb Module
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

        #############
        # Add devices
        #############
        self.add(axi.AxiVersion(
            offset = 0x00000000,
            expand = False,
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

        self.add(MbSharedMem(
            name   = 'MbSharedMem',
            offset = 0x00030000,
            size   = 0x10000,
            expand = False,
        ))

        self.add(ssi.SsiPrbsTx(
            offset = 0x00040000,
            expand = False,
        ))

        self.add(ssi.SsiPrbsRx(
            offset = 0x00050000,
            expand = False,
        ))

        if ( commType == 'eth' ):
            self.add(rssi.RssiCore(
                offset = 0x00070000,
                expand = False,
            ))

            # self.add(udp.UdpEngine(
                # offset = 0x00078000,
                # numSrv = 1,
                # expand = False,
            # ))

        self.add(axi.AxiStreamMonitoring(
            name        = 'AxisMon',
            offset      = 0x00080000,
            numberLanes = 2,
            expand      = False,
        ))

        self.add(MbSharedMem(
            name   = 'TestEmptyMem',
            offset = 0x80000000,
            size   = 0x80000000,
            expand = False,
        ))

    # Normal register rate tester
    def varRateTest(self):
        print("Running variable rate test")
        cnt = 0
        inc = 0
        last = time.localtime()

        try:
            while True:
                val = self.AxiVersion.ScratchPad.get()
                curr = time.localtime()
                cnt += 1
                inc += 1

                if curr != last:
                    print("Cnt={}, rate={}, val={}".format(cnt,inc,val))
                    last = curr
                    inc = 0

        except KeyboardInterrupt:
            return

class MbSharedMem(pr.Device):
    def __init__( self,
        name        = 'MbSharedMem',
        description = 'MbSharedMem Container',
        **kwargs):

        super().__init__(
            name        = name,
            description = description,
            size        = size,
            **kwargs)

        for i in range(16):
            self.add(pr.RemoteVariable(name=f'MemBlock[{i}]',
                                       offset=0x1000*i,
                                       base=pr.UInt,
                                       bitSize=32*4096,
                                       bitOffset=0,
                                       numValues=1024,
                                       valueBits=32,
                                       valueStride=32,
                                       retryCount=tryCount,
                                       updateNotify=False,
                                       bulkOpEn=False,
                                       hidden=True,
                                       verify=False))


        @self.command(description='rawBurstWriteTest')
        def rawBurstWriteTest(arg):
            smpl = 0x4000

            data = [[] for i in in range(16)]]
            for i in range(smpl):
                data[i//0x400][i%0x400].append(i)

            click.secho( 'MbSharedMem.rawBurstWriteTest(%d): %d' % (smpl,len(data)), fg='green')
            for i in range(16):
                self.MemBlock[i].set(data[i],write=True)

        @self.command(description='rawBurstReadTest')
        def rawBurstReadTest(arg):

            click.secho( 'MbSharedMem.rawBurstReadTest(%d): %d' % (smpl,len(data)), fg='green')
            for i in range(16):
                self.MemBlock[i].get(read=True)

