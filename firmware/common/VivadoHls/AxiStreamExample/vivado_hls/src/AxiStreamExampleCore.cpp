//////////////////////////////////////////////////////////////////////////////
// This file is part of 'Vivado HLS Example'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'Vivado HLS Example', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//////////////////////////////////////////////////////////////////////////////
// https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Vivado-2015-3-HLS-Bug-gmp-h/td-p/661141
#include <gmp.h>
#define __gmp_const const
//////////////////////////////////////////////////////////////////////////////

#include "ap_axi_sdata.h"

#include "AxiStreamExampleCore.h"

// Note:
//   template<int D, int U, int TI, int TD>
//   struct ap_axis{
//      ap_int<D>    data;
//      ap_uint<D/8> keep;
//      ap_uint<D/8> strb;
//      ap_uint<U>   user;
//      ap_uint<1>   last;
//      ap_uint<TI>  id;
//      ap_uint<TD>  dest;
//   };

void AxiStreamExampleCore(AXIS_STREAM axisSlave[50], AXIS_STREAM axisMaster[50]) {

// Don't generate ap_ctrl ports in RTL
#pragma HLS INTERFACE ap_ctrl_none port=return

// Allow parallel loops to convert data arrays into FIFOs interfaces
#pragma HLS DATAFLOW

// Set the input and output ports as AXI4-Stream
#pragma HLS INTERFACE axis port=axisSlave
#pragma HLS INTERFACE axis port=axisMaster

  int i;

   for(i = 0; i < 50; i++){
      axisMaster[i].data = axisSlave[i].data.to_int() + 5;
      axisMaster[i].keep = axisSlave[i].keep;
      axisMaster[i].strb = axisSlave[i].strb;
      axisMaster[i].user = axisSlave[i].user;
      axisMaster[i].last = axisSlave[i].last;
      axisMaster[i].id   = axisSlave[i].id;
      axisMaster[i].dest = axisSlave[i].dest;
   }

}
