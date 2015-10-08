/*
 * Copyright 2014, Imagination Technologies Limited and/or its
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
#include <setjmp.h>
#include <mips/hal.h>

jmp_buf context;

void fault_recover ();

int
main ()
{
  int error = setjmp (context);

  if (error)
    {
      printf ("Error handled %d\n", error);
      /* Return success on this return path. */
      return 0;
    }

  /* Initial continuation point from setjmp, cause an memory error. */
  int *a = 0;
  *a = 0;

  /* Return error on this return path. */
  return -1;
}

void
_mips_handle_exception (struct gpctx *ctx, int exception)
{
  /* If we're here due to a TLB Store exception, return to the
     fault_recover function. Otherwise use the stand exception handler. */
  if (exception == EXC_TLBS)
    {
      printf ("exception caught\n");
      ctx->epc = (reg_t)&fault_recover;
    }
  else
    __exception_handle (ctx, exception);
}

void
fault_recover ()
{
  longjmp (context, EXC_TLBS);
}
