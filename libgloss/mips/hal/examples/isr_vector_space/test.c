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
volatile int handledsw1 = 0;
volatile int handledsw0 = 0;

int
main ()
{
  /* Enable SW interrupts 0/1 */
  _mips_bsc0 (C0_STATUS, SR_SINT0 | SR_SINT1);
  /* Trigger the interrupt */
  _mips_bsc0 (C0_CAUSE, SR_SINT1);
  _mips_bsc0 (C0_CAUSE, SR_SINT0);
  /* Wait for handling */
  while (!handledsw1 || !handledsw0)
    {
    };

  printf ("SW0 and SW1 interrupts handled\n");

  return 1;
}

/* Handle SW1 */
void __attribute__ ((interrupt("vector=sw1")))
_mips_isr_sw1 (void)
{
  /* Prove that semi-hosting still works! */
  write (1, "Hello World\n", 12);
  /* Count the interrupt */
  handledsw1 += 1;
  /* Clear the interrupt */
  _mips_bcc0 (C0_CAUSE, SR_SINT1);
}

/* Provide a fall-back handler if anything other than SW0/SW1 is raised */
void __attribute__ ((interrupt, keep_interrupts_masked))
_mips_interrupt (void)
{
  write (1, "Generic interrupt trapped.\n", 27);
  __exit(2);
}
