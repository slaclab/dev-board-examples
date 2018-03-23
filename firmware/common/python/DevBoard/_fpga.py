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

import pyrogue            as pr
import surf.axi           as axi
import surf.protocols.ssi as ssi
import surf.xilinx        as xil
import time

class Fpga(pr.Device):                         
    def __init__( self,       
        name        = 'Fpga',
        fpgaType    = '',
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
        
        self.add(ssi.SsiPrbsTx(
            offset = 0x00040000,
            expand = False,
        )) 

        self.add(ssi.SsiPrbsRx(
            offset = 0x00050000,
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

    # Raw register rate tester
    def rawRateTest(self):
        print("Running raw rate test")
        cnt = 0
        inc = 0
        last = time.localtime()

        try:
            while True:
                val = self.AxiVersion._rawRead(0x4)
                curr = time.localtime()
                cnt += 1
                inc += 1

                if curr != last:
                    print("Cnt={}, rate={}, val={}".format(cnt,inc,val))
                    last = curr
                    inc = 0

        except KeyboardInterrupt:
            return

