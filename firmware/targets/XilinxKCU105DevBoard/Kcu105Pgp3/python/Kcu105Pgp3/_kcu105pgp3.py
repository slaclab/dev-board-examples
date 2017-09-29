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
import rogue

import pyrogue as pr
import pyrogue.simulation
import pyrogue.gui 

import surf.axi
import surf.protocols.ssi
import surf.protocols.pgp
import surf.devices.micron

import logging
import PyQt4.QtGui
import PyQt4.QtCore
import sys

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

class PrbsChannels(pr.Device):
    def __init__(self, channels=4, **kwargs):
        super().__init__(**kwargs)
        
        for i in range(channels):
            self.add(surf.protocols.ssi.SsiPrbsTx(name=f'Ch{i}PrbsTx', offset=(0x10000*2*i)))
            self.add(surf.protocols.ssi.SsiPrbsRx(name=f'Ch{i}PrbsRx', offset=(0x10000*2*i+0x10000)))
        

class Kcu105Pgp3(pr.Device):
    def __init__(self, channels=4, **kwargs):
                 
        super().__init__(**kwargs)

        self.add(surf.axi.AxiVersion(offset=0x0))

        self.add(surf.protocols.pgp.Pgp3AxiL(
            offset = 0x1000,
            channels = channels,
            writeEn = False,
            errorCountBits = 4,
            statusCountBits = 32))

        self.add(PrbsChannels(channels=channels, offset=0x10000000))

        self.add(surf.devices.micron.AxiMicronN25Q(addrMode=False, offset=0x2000, hidden=True))



class Kcu105Pgp3Root(pr.Root):
    def __init__(self, memBase):
        super().__init__(name='Kcu105', description='')
        

        rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)
        
        self.add(Kcu105Pgp3(name='Kcu105Pgp3[0]', memBase=memBase[0]))
        self.add(Kcu105Pgp3(name='Kcu105Pgp3[1]', memBase=memBase[1]))        

        self.start(pollEn=False)

        
if __name__ == '__main__':

    vc = [rogue.hardware.pgp.PgpCard('/dev/pgpcard_0', 0, 0),
          rogue.hardware.pgp.PgpCard('/dev/pgpcard_0', 1, 0)]
    srp = [rogue.protocols.srp.SrpV3(),
           rogue.protocols.srp.SrpV3()]
    
    pr.streamConnectBiDir(vc[0], srp[0])
    pr.streamConnectBiDir(vc[1], srp[1])    
    #    srp = pyrogue.simulation.MemEmulate()    

    with Kcu105Pgp3Root(memBase=srp) as root:
        appTop = PyQt4.QtGui.QApplication(sys.argv)
        guiTop = pyrogue.gui.GuiTop(group='Pgp3')
        guiTop.addTree(root)
        guiTop.resize(1000,1000)

        # Run gui
        appTop.exec_()
