/*
 * Copyright (c) 2015, Imagination Technologies LLC and Imagination Technologies 
 * Limited. 
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted under the terms of the MIPS Free To Use 1.0 
 * license that you will have received with this package. If you haven't 
 * received this file, please contact Imagination Technologies or see the 
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 */


#include <stdio.h>
#include <mips/cpu.h>
volatile int handled;

#define C0_SET_BITS(REG, IDX, BITS) \
  _m32c0_mtc0((REG), (IDX), _m32c0_mfc0 ((REG), (IDX)) | (BITS))
#define C0_CLEAR_BITS(REG, IDX, BITS) \
  _m32c0_mtc0((REG), (IDX), _m32c0_mfc0 ((REG), (IDX)) & ~(BITS))

int
main ()
{

  /* Enable SW interrupt 0 */
  C0_SET_BITS (C0_STATUS, 0, SR_SINT0);
  /* Trigger the interrupt */
  C0_SET_BITS (C0_CAUSE, 0, SR_SINT0);
  /* Wait for handling */
  while (!handled)
    {
    };

  return 1;
}

void __attribute__ ((interrupt, keep_interrupts_masked))
_mips_interrupt (void)
{
  /* Stash our EPC */
  unsigned long epc = _m32c0_mfc0 (C0_EPC, 0);
  /* Prove that semi-hosting still works! */
  write (1, "Hello World\n", 12);
  /* Count the interrupt */
  handled += 1;
  /* Clear the interrupt */
  C0_CLEAR_BITS (C0_CAUSE, 0, SR_SINT0);
  /* Restore EPC */
  _m32c0_mtc0 (C0_EPC, 0, epc);
}
