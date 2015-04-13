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
#include <setjmp.h>
#include <mips/hal.h>

jmp_buf context;

void fault_recover ();

int
main ()
{
  int error = 0;
  error = setjmp (context);
  if (error)
    {

      printf ("Error handled %d\n", error);
      return 0;
    }

  // Initial return from setjmp, cause an memory error.

  int *a = 0;
  *a = 0;

  return -1;

}

void __exception_handle (struct gpctx *ctx, int exception);


void
_mips_handle_exception (struct gpctx *ctx, int exception)
{

  if (exception == EXC_TLBS)
    {
      printf ("exception caught\n");
      ctx->epc = (reg_t)&fault_recover;
    }
  else
    {
      __exception_handle (ctx, exception);
    }

}

void
fault_recover ()
{
  longjmp (context, EXC_TLBS);
}
