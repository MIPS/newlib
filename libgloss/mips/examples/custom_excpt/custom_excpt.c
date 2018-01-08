/*
 * Copyright (C) 2015-2018 MIPS Tech, LLC
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

/* Store a secret from register t0 */
#define TRAPCODE1 14
/* Retrieve a secret into register t0 */
#define TRAPCODE2 15

/* Count the traps we saw in the exception handler */
volatile int num_traps = 0;

int
main (void)
{
  volatile register int secret __asm("$t0") = 0x1234;

  /* Store a secret */
  asm volatile ("teq $zero, $zero, %1\n"
		::"r" (secret), "i" (TRAPCODE1));
  secret = 0;
  /* Retrieve the secret */
  asm volatile ("teq $zero, $zero, %1\n"
		:"=r" (secret): "i" (TRAPCODE2));

  if (num_traps != 2)
    {
      printf ("2 traps expected to have been done. Failed.\n");
      return 2;
    }
  else if (secret != 0x1234)
    {
      printf ("Expected secret to be 0x1234 but got 0x%x\n", secret);
    }

  printf ("Succeeded!\n");
  return 0;
}

void
_mips_handle_exception (struct gpctx *ctx, int exception)
{
  /* The secret data we stash */
  static int secret_store = 0;

  if ((mips32_get_c0 (C0_CAUSE) & CR_BD) == 0
      && (exception == EXC_TRAP))
  {
#ifdef __mips_micromips
    unsigned int trap_insn = ((*(unsigned short *)ctx->epc & ~1) << 16
			      | *(unsigned short *)((ctx->epc & ~1) + 2));
    switch ((trap_insn >> 12) & 0xf)
#else
    unsigned int trap_insn = *(unsigned int *)ctx->epc;
    switch ((trap_insn >> 6) & 0x3ff)
#endif
      {
	case TRAPCODE1:
	  secret_store = ctx->r[C_CTX_REGNO (12)];
	  /* Trash the value */
	  ctx->r[C_CTX_REGNO (12)] = 0;
	  write(1, "Trap 1 done!\n", 13);
	  num_traps += 1;
	  ctx->epc += 4;
	  return;
	case TRAPCODE2:
	  ctx->r[C_CTX_REGNO (12)] = secret_store;
	  write(1, "Trap 2 done!\n", 13);
	  num_traps += 1;
	  ctx->epc += 4;
	  return;
	default:
	  break;
      }
  }

  /* All other exceptions are passed to the default exception handler.  */
  __exception_handle (ctx, exception);
}
