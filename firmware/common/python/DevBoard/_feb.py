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

from surf.protocols.ssi._SsiPrbsTx import *
from surf.protocols.ssi._SsiPrbsRx import *

class feb(pr.Device):                         
    def __init__( self,       
        name        = "feb",
        description = "feb Module",
        memBase     =  None,
        offset      =  0x00,
        hidden      =  False,
        expand      =  True,
    ):
        super().__init__(
            name        = name,
            description = description,
            memBase     = memBase,
            offset      = offset,
            hidden      = hidden,
            expand      = expand,
        )        
        #############
        # Add devices
        #############
        self.add(surf.axi.AxiVersion(
            offset = 0x00000000,
            expand = False,
        ))
        
        self.add(SsiPrbsTx(
            offset = 0x40000,
            expand = False,
        )) 

        self.add(SsiPrbsRx(
            offset = 0x40000,
            expand = False,
        ))         
