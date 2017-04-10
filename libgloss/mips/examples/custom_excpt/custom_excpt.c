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
int
main ()
{
  /* Some pointer setup to access memory address 0*/
  int b = -1;
  int *a = 0;
  /* Write to 0, triggering a TLB store error */
  *a = 0;
  /* Read from 0, triggering a TLB load error */
  b = *a;
  /* Return value should be 0 */
  return b;
}

/*
 * This exception handler emulates register zero style handling but for memory,
 * i.e. writes to page zero are ignored and reads return a zero for select
 * instructions.
 */
void
_mips_handle_exception (struct gpctx *ctx, int exception)
{
  /*
   * This example is designed to work only on MIPS32 and does not handle the
   * case where a memory operation occurs in a branch delay slot.
   */
  if ((mips32_get_c0 (C0_CAUSE) & CR_BD) == 0
      && (ctx->epc & 0x1) == 0)
    {
      unsigned int fault_instruction = 0;
      switch (exception)
	{
	case EXC_TLBS:
	  fault_instruction = *((unsigned int *) (ctx->epc));
	  if ((fault_instruction >> 26) == 0x2b)
	    {
	      /* Store instruction, ensure it went to zero. */
	      unsigned int store_reg = (fault_instruction >> 21) & 0x1f;
	      int16_t offset = fault_instruction & 0xffff;
	      unsigned int destination = ctx->r[C_CTX_REGNO(store_reg)] + offset;

	      if (destination < 4096)
		{
		  write (1, "Handled write to zero page\n", 27);
		  ctx->epc += 4;
		  return;
		}
	    }
	  break;

	case EXC_TLBL:
	  fault_instruction = *((unsigned int *) (ctx->epc));
	  if ((fault_instruction >> 26) == 0x23)
	    {
	      /* Load instruction, ensure it went to zero. */
	      unsigned int load_reg = (fault_instruction >> 21) & 0x1f;
	      int16_t offset = fault_instruction & 0xffff;
	      unsigned int destination = ctx->r[C_CTX_REGNO(load_reg)] + offset;
	      if (destination < 4096)
		{
		  write (1, "Handled read from zero page\n", 28);
		  ctx->epc += 4;
		  unsigned int rt = (fault_instruction >> 16) & 0x1f;
		  ctx->r[rt] = 0;
		  return;
		}
	    }
	  break;

	default:
	  break;
	}
    }

  /* All other exceptions are passed to the default exception handler.  */
  __exception_handle (ctx, exception);
}
