
/*****************************************************************************
*
*               file : $File$
*  date last revised : $Date$
*
*          copyright : 2013 - 2014 by Imagination Technologies.
*                      All rights reserved.
*                      No part of this software, either material or conceptual
*                      may be copied or distributed, transmitted, transcribed,
*                      stored in a retrieval system or translated into any
*                      human or computer language in any form by any means,
*                      electronic, mechanical, manual or otherwise, or
*                      disclosed to third parties without the express written
*                      permission of:
*                        Imagination Technologies, Home Park Estate,
*                        Kings Langley, Hertfordshire, WD4 8LZ, U.K.
*
*        description : MIPS exception handler
*
*****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mips/cpu.h>
#include "excpt.h"
#include "uhi_syscalls.h"

int __get_startup_BEV (void);
int __chain_uhi_excpt (struct gpctx *ctx);
int _mips_handle_exception (struct gpctx *ctx, int exception)
	__attribute__((weak));

/* Defined in .ld file */
extern char __use_excpt_boot[];

/* Handle syscall exception */
int _excpt_syscall (struct gpctx *ctx)
{
	register regtype arg1 asm ("$4") = ctx->a[0];
	register regtype arg2 asm ("$5") = ctx->a[1];
	register regtype arg3 asm ("$6") = ctx->a[2];
	register regtype arg4 asm ("$7") = ctx->a[3];
	register regtype op asm ("$25") = ctx->t2[1];
	register regtype ret3 asm ("$24") = ctx->t2[0];
	register regtype ret1 asm ("$2") = __MIPS_UHI_SYSCALL_NUM;
	register regtype ret2 asm ("$3");

	__asm__ __volatile__(" # UHI indirect\n"
                       SYSCALL (__MIPS_UHI_SYSCALL_NUM)
                       : "+r" (ret1), "=r" (ret2), "+r" (arg1), "+r" (arg2)
                       : "r" (arg3), "r" (arg4), "r" (op));

	ctx->v[0] = ret1;
	ctx->v[1] = ret2;
	ctx->a[0] = arg1;
	ctx->a[1] = arg2;

	return 1;	/* exception handled */
}

int _mips_handle_exception (struct gpctx *ctx, int exception)
{
	/* We know the C library will want these */
	switch (exception) {
	case EXC_FPE:
		break;
	case EXC_OVF:
		break;
	case EXC_TRAP:
		break;
	case EXC_SYS:
		{
		  /* 
		   * __use_excpt_boot has following values
		   * 0 = Do not use exception handler present in boot
		   * 1 = Use exception handler present in boot if BEV 
		         is 0 at startup
		   * 2 = Always use exception handler present in boot
		  */
		  if (((long) __use_excpt_boot == 2) ||
		      (long) __use_excpt_boot == 1 && __get_startup_BEV () == 0)
		    return __chain_uhi_excpt (ctx);
		  else
		    return _excpt_syscall (ctx);
		}
	default:
		break;
	}

	return 0;
}

/*
 * Write a string, a formatted number, then a string. Avoid printf to prevent
 * cascading exceptions.
 */
static void putsns (const char *pre, regtype value, unsigned int digits,
	    const char *post)
{
	regtype mask, bit = 0xf;
	uint32_t shift;
	fputs (pre, stdout);
	for (shift = ((digits - 1) * 4), mask = bit << shift; mask;
	     mask >>= 4, shift -= 4) {
		putchar ("0123456789ABCDEF"[(value & mask) >> shift]);
	}
	puts (post);
}

/* Handle an exception */
void __exception (struct gpctx *ctx, int exception)
{
	unsigned int digits = sizeof (regtype) * 2;

	/* We know the C library will want these */
	switch (exception) {
	case EXC_FPE:
	case EXC_OVF:
	case EXC_TRAP:
	case EXC_SYS:
		if (_mips_handle_exception (ctx, exception))
			return;
		break;
	default:
		break;
	}

	/* Otherwise, report the exception */
	switch (exception) {
	case EXC_MOD:
		puts ("TLB modification exception\n");
		break;
	case EXC_TLBL:
		putsns ("TLB error on load from 0x",
		       (uint32_t) _m32c0_mfc0(C0_BADVADDR, 0), 8, "");
		putsns ("@0x", ctx->epc, digits, "\n");
		break;
	case EXC_TLBS:
		putsns ("TLB error on store to 0x",
		       (uint32_t) _m32c0_mfc0(C0_BADVADDR, 0), 8, "");
		putsns ("@0x", ctx->epc, digits, "\n");
		break;
	case EXC_ADEL:
		putsns ("Address error on load from 0x",
		       (uint32_t) _m32c0_mfc0(C0_BADVADDR, 0), 8, "");
		putsns ("@0x", ctx->epc, digits, "\n");
		break;
	case EXC_ADES:
		putsns ("Address error on store to 0x",
		       (uint32_t) _m32c0_mfc0(C0_BADVADDR, 0), 8, "");
		putsns ("@0x", ctx->epc, digits, "\n");
		break;
	case EXC_IBE:
		puts ("Instruction bus error\n");
		break;
	case EXC_DBE:
		puts ("Data bus error\n");
		break;
	case EXC_SYS:
		puts ("Unexpected syscall\n");
		break;
	case EXC_BP:
		putsns ("Breakpoint @0x", ctx->epc, digits, "\n");
		break;
	case EXC_RI:
		putsns ("Illegal instruction @0x", ctx->epc, digits, "\n");
		break;
	case EXC_CPU:
		puts ("Coprocessor unusable\n");
		break;
	case EXC_OVF:
		puts ("Overflow\n");
		break;
	case EXC_TRAP:
		puts ("Trap\n");
		break;
	case EXC_FPE:
		puts ("Floating point error\n");
		break;
	case EXC_IS1:
		puts ("Coprocessor 2 implementation specific exception\n");
		break;
	case EXC_IS2:
		puts ("CorExtend unusable\n");
		break;
	case EXC_C2E:
		puts ("Precise Coprocessor 2 exception\n");
		break;
	case EXC_RES19:
		puts ("TLB read inhibit exception\n");
		break;
	case EXC_RES20:
		puts ("TLB execute inhibit exception\n");
		break;
	case EXC_MDMX:
		putsns ("MDMX exception @0x", ctx->epc, digits, "\n");
		break;
	case EXC_WATCH:
		putsns ("Watchpoint @0x", ctx->epc, digits, "\n");
		break;
	case EXC_MCHECK:
		puts ("Machine check error\n");
		break;
	case EXC_THREAD:
		puts ("Thread exception\n");
		break;
	case EXC_DSPU:
		puts ("DSP availability exception\n");
		break;
	case EXC_RES30:
		puts ("Cache error\n");
		break;
	default:
		putsns ("Unhandled exception ", exception, 2, "\n");
	}

	/* Dump registers */
	putsns (" 0:\t", 0, digits, "\t");
	putsns ("at:\t", ctx->at, digits, "\t");
	putsns ("v0:\t", ctx->v[0], digits, "\t");
	putsns ("v1:\t", ctx->v[1], digits, "\n");

	putsns ("a0:\t", ctx->a[0], digits, "\t");
	putsns ("a1:\t", ctx->a[1], digits, "\t");
	putsns ("a2:\t", ctx->a[2], digits, "\t");
	putsns ("a3:\t", ctx->a[3], digits, "\n");

	putsns ("t0:\t", ctx->t[0], digits, "\t");
	putsns ("t1:\t", ctx->t[1], digits, "\t");
	putsns ("t2:\t", ctx->t[2], digits, "\t");
	putsns ("t3:\t", ctx->t[3], digits, "\n");

	putsns ("t4:\t", ctx->t[4], digits, "\t");
	putsns ("t5:\t", ctx->t[5], digits, "\t");
	putsns ("t6:\t", ctx->t[6], digits, "\t");
	putsns ("t7:\t", ctx->t[7], digits, "\n");

	putsns ("s0:\t", ctx->s[0], digits, "\t");
	putsns ("s1:\t", ctx->s[1], digits, "\t");
	putsns ("s2:\t", ctx->s[2], digits, "\t");
	putsns ("s3:\t", ctx->s[3], digits, "\n");

	putsns ("s4:\t", ctx->s[4], digits, "\t");
	putsns ("s5:\t", ctx->s[5], digits, "\t");
	putsns ("s6:\t", ctx->s[6], digits, "\t");
	putsns ("s7:\t", ctx->s[7], digits, "\n");

	putsns ("t8:\t", ctx->t2[0], digits, "\t");
	putsns ("t9:\t", ctx->t2[1], digits, "\t");
	putsns ("k0:\t", ctx->k[0], digits, "\t");
	putsns ("k1:\t", ctx->k[1], digits, "\n");

	putsns ("gp:\t", ctx->gp, digits, "\t");
	putsns ("sp:\t", ctx->sp, digits, "\t");
	putsns ("fp:\t", ctx->fp, digits, "\t");
	putsns ("ra:\t", ctx->ra, digits, "\n");

#if __mips_isa_rev < 6
	putsns ("hi:\t", (uint32_t) ctx->acc[0].hi, 8, "\t");
	putsns ("lo:\t", (uint32_t) ctx->acc[0].lo, 8, "\t");
#endif
	putsns ("epc:\t", ctx->epc, digits, "\t");
	putsns ("BadVAddr:\t", (uint32_t) _m32c0_mfc0(C0_BADVADDR, 0), 8, "\n");

	abort ();
	return;
}

