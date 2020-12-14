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
#include <stdint.h>

void AxiLiteExampleCore(uint32_t *a, uint32_t *b, uint32_t *c);

int main()
{

  uint32_t a;
  uint32_t b;
  uint32_t c;
  uint32_t d;
  uint32_t sw_result;


  printf("HLS AXI-Lite Example\n");
  printf("Function c += a + b\n");
  printf("Initial values a = 5, b = 10, c = 0\n");

  a = 5;
  b = 10;
  c = 0;
  d = 0;

  AxiLiteExampleCore(&a,&b,&c);
  d += a + b;

  printf("HW result = %d\n",c);
  printf("SW result = %d\n",d);

  if(d == c){
    printf("Success SW and HW results match\n");
    return 0;
  }
  else{
    printf("ERROR SW and HW results mismatch\n");
    return 1;
  }
}
  
 
