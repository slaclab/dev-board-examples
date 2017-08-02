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

import pyrogue as pr

import surf.axi
import surf.protocols.ssi

class AppReg(pr.Device):
    def __init__(self, **kwargs):
                 
        super().__init__(**kwargs):

        self.add(surf.axi.AxiVersion(offset=0x00000000))
        self.add(pr.MemoryDevice(name='Mem', offset=0x00030000))
        self.add(surf.protocols.ssi.SsiPrbsTx(offset=0x00040000))
        self.add(surf.protocols.ssi.SsiPrbsRx(offset=0x00050000))        

     
