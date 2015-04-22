/*
 * Copyright 2015, Imagination Technologies Limited and/or its
 *         affiliated group companies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 */

#include <stdio.h>
#include <stdint.h>
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


/* This exception handler emulates register zero style handling
 * but for memory, i.e. writes to page zero are ignored and reads
 * return a zero for select instructions.
 */
void
_mips_handle_exception (struct gpctx *ctx, int exception)
{

  /* In this non-micromips example we are not going to emulate all mips
   * branch instructions for correct return to epc.
   */
  if (CR_BD & mips_getcr () || 0x1 & ctx->epc)
    {
      /* Pass exception */
      __exception_handle (ctx, exception);
    }
  else
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
	      unsigned int destination = ctx->r[store_reg] + offset;
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
	      unsigned int destination = ctx->r[load_reg] + offset;
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
	  /* All other exceptions are passed to the default exception
	  *  handler.
	  */
	  __exception_handle (ctx, exception);
	  break;

	}
    }

}
