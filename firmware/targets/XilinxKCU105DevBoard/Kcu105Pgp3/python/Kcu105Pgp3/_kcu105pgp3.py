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

class Pgp3Vcs(pr.Device):
    def __init__(self, channels=4, **kwargs):
                 
        super().__init__(**kwargs):

        for i in range(0, channels*2, 2):
            self.add(surf.protocols.ssi.SsiPrbsTx(name=f'Ch{i}PrbsTx', offset=0x00010000*i))
            self.add(surf.protocols.ssi.SsiPrbsRx(name=f'Ch{i}PrbsRx', offset=0x00020000*i))        

     
