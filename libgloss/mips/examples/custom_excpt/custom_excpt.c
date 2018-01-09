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
#include <stdint.h>
#include <unistd.h>
#include <mips/hal.h>
#include <mips/cpu.h>

#define TRAPCODE1 0x4321
#define TRAPCODE2 0x8765

volatile int num_traps = 0;

int
main ()
{
  /* Write special trap code */
  asm volatile ("li $t0, %0\n"
      "teq $r0, $r0, 20\n"  /* 20 is unused, just put something */
      "li $t0, %1\n"
      "teq $r0, $r0, 20\n"
      "li $t0, 0"
      :: "i" (TRAPCODE1), "i" (TRAPCODE2)
      : "$t0");

  if (num_traps != 3)  /* 3 because gets OR'd with 1 and 2 on each trap respectively */
    {
      printf ("2 traps expected to have been done. Failed.\n");
      return 2;
    }
  else
    {
      printf ("Succeded!\n");
      return 0;
    }
}

void
_mips_handle_exception (struct gpctx *ctx, int exception)
{
  /*
   * This example is designed to work only on MIPS32 and does not handle the
   * case where a memory operation occurs in a branch delay slot.
   *
   * Look for a 'teq' operation, ie. 'trap if equal'.
   */
  if ((mips32_get_c0 (C0_CAUSE) & CR_BD) == 0
      && ((ctx->epc & 0x1) == 0)
      && (exception == EXC_TRAP))
  {
    unsigned short *fault_insnhi = (unsigned short *) (ctx->epc);
    if ((*fault_insnhi >> 10) == 0x8)  /* teq insn opcode in bits 31..26 */
      switch (ctx->r[C_CTX_REGNO (12)])
      {
        case TRAPCODE1:
          write(1, "Trap 1 done!\n", 13);
          num_traps |= 1;
          ctx->epc += 4;
          return;
        case TRAPCODE2:
          write(1, "Trap 2 done!\n", 13);
          num_traps |= 2;
          ctx->epc += 4;
          return;
        default:
          break;
      }
  }

  /* All other exceptions are passed to the default exception handler.  */
  __exception_handle (ctx, exception);
}
