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
import pyrogue.simulation
import pyrogue.gui 

import surf.axi
import surf.protocols.ssi
import surf.protocols.pgp

import logging
import PyQt4.QtGui
import PyQt4.QtCore
import sys


class Kcu105Pgp3(pr.Device):
    def __init__(self, channels=4, **kwargs):
                 
        super().__init__(**kwargs)

        self.add(surf.protocols.pgp.Pgp3AxiL(
            offset = 0x10000000 + 0x10000*(2*channels),
            channels = channels,
            writeEn = False,
            errorCountBits = 4,
            statusCountBits = 32))        

        for i in range(0, channels*2, 2):
            self.add(surf.protocols.ssi.SsiPrbsTx(name=f'Ch{i}PrbsTx', offset=0x10010000*i))
            self.add(surf.protocols.ssi.SsiPrbsRx(name=f'Ch{i}PrbsRx', offset=0x10020000*i))        




class Kcu105Pgp3Root(pr.Root):
    def __init__(self, **kwargs):
        super().__init__(name='Kcu105', description='', **kwargs)

        #vc = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0', 0, 0)
        #srp = rogue.protocols.srp.SrpV3()
        #pr.streamConnectBiDir(vc, srp)
        srp = pyrogue.simulation.MemEmulate()
        

        logging.getLogger('pyrogue.SRP').setLevel(logging.DEBUG)
        
        self.add(Kcu105Pgp3(memBase=srp))

        self.start(pollEn=False)

        
if __name__ == '__main__':

    with Kcu105Pgp3Root() as root:
        appTop = PyQt4.QtGui.QApplication(sys.argv)
        guiTop = pyrogue.gui.GuiTop(group='Pgp3')
        guiTop.addTree(root)
        guiTop.resize(1000,1000)

        # Run gui
        appTop.exec_()
