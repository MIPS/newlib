/*
 * Copyright 2015, Imagination Technologies Limited and/or its
 *                 affiliated group companies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
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
