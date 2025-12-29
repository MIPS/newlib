/*
 * Copyright 2015, Imagination Technologies Limited and/or its
 *                 affiliated group companies.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <unistd.h>
#include <mips/cpu.h>
#include <mips/hal.h>
volatile int handled;

int
main ()
{
  /* Enable SW interrupt 0 */
  mips32_bs_c0 (C0_STATUS, SR_SINT0);
  /* Trigger the interrupt */
  mips32_bs_c0 (C0_CAUSE, SR_SINT0);
  /* Wait for handling */
  while (!handled)
    {
    };

  printf ("SW0 interrupt handled\n");

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
  mips32_bc_c0 (C0_CAUSE, SR_SINT0);
}

/* Provide a fall-back handler if anything other than SW0 is raised */
void __attribute__ ((interrupt, keep_interrupts_masked))
_mips_interrupt (void)
{
  write (1, "Unhandled interrupt occurred\n", 29);
  __exit (2);
}
