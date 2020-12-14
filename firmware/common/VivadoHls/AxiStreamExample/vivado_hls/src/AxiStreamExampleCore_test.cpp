//////////////////////////////////////////////////////////////////////////////
// This file is part of 'Vivado HLS Example'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'Vivado HLS Example', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include "ap_axi_sdata.h"

#include "AxiStreamExampleCore.h"

void AxiStreamExampleCore(AXIS_STREAM axisSlave[50], AXIS_STREAM axisMaster[50]);

int main()
{
   int i;
   
   AXIS_STREAM axisSlave[50];
   AXIS_STREAM axisMaster[50];

   for(i=0; i < 50; i++){
      axisSlave[i].data = i;
      axisSlave[i].keep = 1;
      axisSlave[i].strb = 1;
      axisSlave[i].user = 1;
      axisSlave[i].last = 0;
      axisSlave[i].id = 0;
      axisSlave[i].dest = 1;
   }

  AxiStreamExampleCore(axisSlave,axisMaster);
   
  for(i=0; i < 50; i++){
    if(axisMaster[i].data.to_int() != (i+5)){
      printf("ERROR: HW and SW results mismatch\n");
      return 1;
    }
  }

  printf("Success: HW and SW results match\n");
  return 0;
}
