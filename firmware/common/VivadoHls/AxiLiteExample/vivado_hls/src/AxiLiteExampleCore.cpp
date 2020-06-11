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

#include <stdio.h>
#include <stdint.h>

void AxiLiteExampleCore(uint32_t *a, uint32_t *b, uint32_t *c)
{

  *c += *a + *b;
}
  
  
