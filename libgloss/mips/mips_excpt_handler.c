/*
 * Copyright (c) 2014, Imagination Technologies Ltd.
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

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <mips/cpu.h>
#include <mips/fpa.h>
#include "excpt.h"
#include "uhi_syscalls.h"

int __get_startup_BEV (void) __attribute__((weak));
int __chain_uhi_excpt (struct gpctx *) __attribute__((weak));
int32_t __uhi_exception (struct gpctx *);

/* Defined in .ld file */
extern char __use_excpt_boot[];
extern char __attribute__((weak)) __flush_to_zero[];

/* Handle syscall exception.  */
int
__excpt_uhi_sdbbp (struct gpctx *ctx)
{
  register regtype arg1 asm ("$4") = ctx->a[0];
  register regtype arg2 asm ("$5") = ctx->a[1];
  register regtype arg3 asm ("$6") = ctx->a[2];
  register regtype arg4 asm ("$7") = ctx->a[3];
  register regtype op asm ("$25") = ctx->t2[1];
  register regtype ret1 asm ("$2") = 1;
  register regtype ret2 asm ("$3");

  __asm__ __volatile__(" # UHI indirect\n"
		       "\tsdbbp 1"
		       : "+r" (ret1), "=r" (ret2), "+r" (arg1), "+r" (arg2)
		       : "r" (arg3), "r" (arg4), "r" (op));

  ctx->v[0] = ret1;
  ctx->v[1] = ret2;
  ctx->a[0] = arg1;
  ctx->a[1] = arg2;
  /* Handled, move on.  SYSCALL is 4-bytes in all ISAs.  */
  ctx->epc += 4;

  return 1; /* exception handled */
}

#define WRITE(MSG) write (1, (MSG), strlen (MSG))

/*
 * Write a string, a formatted number, then a string.
 */
static void
putsnds (const char *pre, regtype value, int digits, const char *post)
{
  char buf[digits];
  int shift;
  int idx = 0;

  if (pre != NULL)
    write (1, pre, strlen (pre));

  for (shift = ((digits - 1) * 4) ; shift >= 0 ; shift -= 4)
    buf[idx++] = "0123456789ABCDEF"[(value >> shift) & 0xf];
  write (1, buf, digits);

  if (post != NULL)
    write (1, post, strlen (post));
}

static void
putsns (const char *pre, regtype value, const char *post)
{
  putsnds (pre, value, sizeof (regtype) * 2, post);
}

/* Handle an exception */
void
__exception_handle (struct gpctx *ctx, int exception)
{
  switch (exception)
    {
   case EXC_MOD:
      WRITE ("TLB modification exception\n");
      break;
    case EXC_TLBL:
      putsns ("TLB error on load from 0x", ctx->badvaddr, NULL);
      putsns (" @0x", ctx->epc, "\n");
      break;
    case EXC_TLBS:
      putsns ("TLB error on store to 0x", ctx->badvaddr, NULL);
      putsns (" @0x", ctx->epc, "\n");
      break;
    case EXC_ADEL:
      putsns ("Address error on load from 0x", ctx->badvaddr, NULL);
      putsns (" @0x", ctx->epc, "\n");
      break;
    case EXC_ADES:
      putsns ("Address error on store to 0x", ctx->badvaddr, NULL);
      putsns (" @0x", ctx->epc, "\n");
      break;
    case EXC_IBE:
      WRITE ("Instruction bus error\n");
      break;
    case EXC_DBE:
      WRITE ("Data bus error\n");
      break;
    case EXC_SYS:
      /* Process a UHI SYSCALL, all other SYSCALLs should have been processed
         by our caller.  __use_excpt_boot has following values:
	 0 = Do not use exception handler present in boot.
	 1 = Use exception handler present in boot if BEV
	     is 0 at startup.
	 2 = Always use exception handler present in boot.   */

      if (((long) __use_excpt_boot == 2
	   || ((long) __use_excpt_boot == 1
	       && __get_startup_BEV
	       && __get_startup_BEV () == 0))
	  && __chain_uhi_excpt)
        /* This will not return.  */
        __chain_uhi_excpt (ctx);
      else
        __excpt_uhi_sdbbp (ctx);
      return;
    case EXC_BP:
      putsns ("Breakpoint @0x", ctx->epc, "\n");
      break;
    case EXC_RI:
      putsns ("Illegal instruction @0x", ctx->epc, "\n");
      break;
    case EXC_CPU:
      putsns ("Coprocessor unusable @0x", ctx->epc, "\n");
      break;
    case EXC_OVF:
      WRITE ("Overflow\n");
      break;
    case EXC_TRAP:
      WRITE ("Trap\n");
      break;
    case EXC_MSAFPE:
      WRITE ("MSA Floating point error\n");
      break;
    case EXC_FPE:
      /* Turn on flush to zero the first time we hit an unimplemented
         operation.  If we hit it again then stop.  */
      WRITE ("Floating point error\n");
      if (__flush_to_zero
	  && (fpa_getsr () & FPA_CSR_UNI_X)
	  && (fpa_getsr () & FPA_CSR_FS) == 0)
	{
	  fpa_bissr (FPA_CSR_FS);

	  if (msaen)
	    msacr(fs)
	  return;
	}
      WRITE ("Floating point error\n");
      break;
    case EXC_IS1:
      WRITE ("Implementation specific exception (16)\n");
      break;
    case EXC_IS2:
      WRITE ("Implementation specific exception (17)\n");
      break;
    case EXC_C2E:
      WRITE ("Precise Coprocessor 2 exception\n");
      break;
    case EXC_RES19:
      WRITE ("TLB read inhibit exception\n");
      break;
    case EXC_RES20:
      WRITE ("TLB execute inhibit exception\n");
      break;
    case EXC_MSAU:
      putsns ("MSA unusable @0x", ctx->epc, "\n");
      break;
    case EXC_MDMX:
      putsns ("MDMX exception @0x", ctx->epc, "\n");
      break;
    case EXC_WATCH:
      putsns ("Watchpoint @0x", ctx->epc, "\n");
      break;
    case EXC_MCHECK:
      WRITE ("Machine check error\n");
      break;
    case EXC_THREAD:
      WRITE ("Thread exception\n");
      break;
    case EXC_DSPU:
      WRITE ("DSP unusable\n");
      break;
    case EXC_RES30:
      WRITE ("Cache error\n");
      break;
    default:
      putsns ("Unhandled exception ", exception, "\n");
    }

  /* Dump registers */
  putsns (" 0:\t", 0, "\t");
  putsns ("at:\t", ctx->at, "\t");
  putsns ("v0:\t", ctx->v[0], "\t");
  putsns ("v1:\t", ctx->v[1], "\n");

  putsns ("a0:\t", ctx->a[0], "\t");
  putsns ("a1:\t", ctx->a[1], "\t");
  putsns ("a2:\t", ctx->a[2], "\t");
  putsns ("a3:\t", ctx->a[3], "\n");

  putsns ("t0:\t", ctx->t[0], "\t");
  putsns ("t1:\t", ctx->t[1], "\t");
  putsns ("t2:\t", ctx->t[2], "\t");
  putsns ("t3:\t", ctx->t[3], "\n");

  putsns ("t4:\t", ctx->t[4], "\t");
  putsns ("t5:\t", ctx->t[5], "\t");
  putsns ("t6:\t", ctx->t[6], "\t");
  putsns ("t7:\t", ctx->t[7], "\n");

  putsns ("s0:\t", ctx->s[0], "\t");
  putsns ("s1:\t", ctx->s[1], "\t");
  putsns ("s2:\t", ctx->s[2], "\t");
  putsns ("s3:\t", ctx->s[3], "\n");

  putsns ("s4:\t", ctx->s[4], "\t");
  putsns ("s5:\t", ctx->s[5], "\t");
  putsns ("s6:\t", ctx->s[6], "\t");
  putsns ("s7:\t", ctx->s[7], "\n");

  putsns ("t8:\t", ctx->t2[0], "\t");
  putsns ("t9:\t", ctx->t2[1], "\t");
  putsns ("k0:\t", ctx->k[0], "\t");
  putsns ("k1:\t", ctx->k[1], "\n");

  putsns ("gp:\t", ctx->gp, "\t");
  putsns ("sp:\t", ctx->sp, "\t");
  putsns ("fp:\t", ctx->fp, "\t");
  putsns ("ra:\t", ctx->ra, "\n");

#if __mips_isa_rev < 6
  putsns ("hi:\t", ctx->hi, "\t");
  putsns ("lo:\t", ctx->lo, "\n");
#endif

  putsns ("epc:     \t", ctx->epc, "\n");
  putsns ("BadVAddr:\t", ctx->badvaddr, "\n");

  putsnds ("Status:   \t", ctx->status, 8, "\n");
  putsnds ("Cause:    \t", ctx->cause, 8, "\n");
  putsnds ("BadInstr: \t", ctx->badinstr, 8, "\n");
  putsnds ("BadPInstr:\t", ctx->badpinstr, 8, "\n");

  /* Raise UHI exception which may or may not return.  */
  __uhi_exception (ctx);

  /* Temporary until __uhi_exception is handled correctly in all
     environments.  */
  _exit (2);
}

/* Provide _mips_handle_exception allowing a user to intercept and then fall
   back to __exception_handle.  */

int _mips_handle_exception (struct gpctx *, int)
    __attribute__ ((weak, alias ("__exception_handle")));
