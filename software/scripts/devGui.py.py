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

import pyrogue as pr
import pyrogue.pydm

import DevBoard as devBoard

#################################################################

# rogue.Logging.setFilter("pyrogue.SrpV3",rogue.Logging.Debug)

#rogue.Logging.setLevel(rogue.Logging.Warning)
#rogue.Logging.setLevel(rogue.Logging.Debug)
#rogue.Logging.setFilter("pyrogue.rssi",rogue.Logging.Info)
#rogue.Logging.setFilter("pyrogue.packetizer",rogue.Logging.Info)
#rogue.Logging.setLevel(rogue.Logging.Debug)

#################################################################

if __name__ == "__main__":

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
        "--enPrbs",
        type     = argBool,
        required = False,
        default  = True,
        help     = "Enable PRBS testing",
    )

    parser.add_argument('--html', help='Use html for tables', action="store_true")

    # Get the arguments
    args = parser.parse_args()

    #################################################################

    with devBoard.MyRoot(
            type        = args.type,
            dev         = args.dev,
            ip          = args.ip,
            lane        = args.lane,
            enPrbs      = args.enPrbs,
            fpgaType    = args.fpgaType,
            pollEn      = args.pollEn,
            initRead    = args.initRead,
        ) as root:

        pyrogue.pydm.runPyDM(root=root)

    #################################################################
