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
#include <mips/hal.h>
volatile int handled;

int
main ()
{
  /* Enable SW interrupt 0 */
  _mips_bsc0 (C0_STATUS, SR_SINT0);
  /* Trigger the interrupt */
  _mips_bsc0 (C0_CAUSE, SR_SINT0);
  /* Wait for handling */
  while (!handled)
    {
    };

  return 1;
}

/* Handle SW0 */
void __attribute__ ((interrupt("vector=sw0")))
_mips_isr_sw0 (void)
{
  /* Prove that semi-hosting still works! */
  write (1, "Hello World\n", 12);
  /* Count the interrupt */
  handled += 1;
  /* Clear the interrupt */
  _mips_bcc0 (C0_CAUSE, SR_SINT0);
}

/* Provide a fall-back handler if anything other than SW0 is raised */
void __attribute__ ((interrupt, keep_interrupts_masked))
_mips_interrupt (void)
{
  write (1, "Unhandled interrupt occurred\n", 29);
  __exit (2);
}
