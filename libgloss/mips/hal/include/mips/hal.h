/*
 * Copyright (c) 2015, Imagination Technologies Ltd.
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

#ifndef _HAL_H
#define _HAL_H

#include <mips/asm.h>
#include <mips/m32c0.h>

#define CTX_REG(REGNO)	((SZREG)*((REGNO)-1))

#define CTX_AT		((SZREG)*0)
#define CTX_V0		((SZREG)*1)
#define CTX_V1		((SZREG)*2)
#define CTX_A0		((SZREG)*3)
#define CTX_A1		((SZREG)*4)
#define CTX_A2		((SZREG)*5)
#define CTX_A3		((SZREG)*6)
#if _MIPS_SIM==_ABIN32 || _MIPS_SIM==_ABI64 || _MIPS_SIM==_ABIEABI
# define CTX_A4		((SZREG)*7)
# define CTX_A5		((SZREG)*8)
# define CTX_A6		((SZREG)*9)
# define CTX_A7		((SZREG)*10)
# define CTX_T0		((SZREG)*11)
# define CTX_T1		((SZREG)*12)
# define CTX_T2		((SZREG)*13)
# define CTX_T3		((SZREG)*14)
#else
# define CTX_T0		((SZREG)*7)
# define CTX_T1		((SZREG)*8)
# define CTX_T2		((SZREG)*9)
# define CTX_T3		((SZREG)*10)
# define CTX_T4		((SZREG)*11)
# define CTX_T5		((SZREG)*12)
# define CTX_T6		((SZREG)*13)
# define CTX_T7		((SZREG)*14)
#endif
#define CTX_S0		((SZREG)*15)
#define CTX_S1		((SZREG)*16)
#define CTX_S2		((SZREG)*17)
#define CTX_S3		((SZREG)*18)
#define CTX_S4		((SZREG)*19)
#define CTX_S5		((SZREG)*20)
#define CTX_S6		((SZREG)*21)
#define CTX_S7		((SZREG)*22)
#define CTX_T8		((SZREG)*23)
#define CTX_T9		((SZREG)*24)
#define CTX_K0		((SZREG)*25)
#define CTX_K1		((SZREG)*26)
#define CTX_GP		((SZREG)*27)
#define CTX_SP		((SZREG)*28)
#define CTX_FP		((SZREG)*29)
#define CTX_RA		((SZREG)*30)
#define CTX_EPC		((SZREG)*31)
#define CTX_BADVADDR	((SZREG)*32)
#define CTX_HI0		((SZREG)*33)
#define CTX_LO0		((SZREG)*34)
#define CTX_LINK	((SZREG)*35)
#define CTX_STATUS	(((SZREG)*35)+SZPTR)
#define CTX_CAUSE	(((SZREG)*35)+SZPTR+4)
#define CTX_BADINSTR	(((SZREG)*35)+SZPTR+8)
#define CTX_BADPINSTR	(((SZREG)*35)+SZPTR+12)
#define CTX_SIZE	(((SZREG)*35)+SZPTR+16)

#ifndef __ASSEMBLER__

#include <stdint.h>

struct gpctx
{
  union
  {
    struct
    {
      reg_t at;
      reg_t v[2];
# if _MIPS_SIM==_ABIN32 || _MIPS_SIM==_ABI64 || _MIPS_SIM==_ABIEABI
      reg_t a[8];
      reg_t t[4];
# else
      reg_t a[4];
      reg_t t[8];
# endif
      reg_t s[8];
      reg_t t2[2];
      reg_t k[2];
      reg_t gp;
      reg_t sp;
      reg_t fp;
      reg_t ra;
    };
    reg_t r[31];
  };

  reg_t epc;
  reg_t badvaddr;
  reg_t hi;
  reg_t lo;
  /* This field is for future extension */
  void *link;
  /* Status at the point of the exception.  This may not be restored
     on return from exception if running under an RTOS */
  uint32_t status;
  /* These fields should be considered read-only */
  uint32_t cause;
  uint32_t badinstr;
  uint32_t badpinstr;
};

#if _MIPS_SIM == _ABIO32
#define UHI_ABI 0
#elif _MIPS_SIM == _ABIN32
#define UHI_ABI 1
#elif _MIPS_SIM == _ABI64
#define UHI_ABI 2
#else
#error "UHI context structure is not defined for current ABI"
#endif

/* Fall back exception handlers:
   _mips_handle_exception - May be implemented by a user but is aliased
			    to __exception_handle by default.
   __exception_handle	  - Toolchain provided fallback handler.
*/
extern void _mips_handle_exception (struct gpctx *ctx, int exception);
extern void __exception_handle (struct gpctx *ctx, int exception);

/* Obtain the largest available region of RAM */
extern void _get_ram_range (void **ram_base, void **ram_extent)

/* Invoke a UHI operation via SDBBP using the provided context */
extern int __uhi_indirect (struct gpctx *);

/* Report an unhandled exception */
extern int32_t __uhi_exception (struct gpctx *, int32_t);

/* Print a message to a logger.  Minimal formatting support for one
   integer argument.  */
extern int32_t __plog (int8_t *, int32_t);

/* Boot context support functions */
extern int __get_startup_BEV (void) __attribute__((weak));
extern int __chain_uhi_excpt (struct gpctx *) __attribute__((weak));

/* Emergency exit, use it when unrecoverable errors occur */
extern int __exit (int);

#endif
#endif // _HAL_H
