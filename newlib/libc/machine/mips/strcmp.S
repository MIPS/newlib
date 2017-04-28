/*
 * Copyright (c) 2014
 *      Imagination Technologies Limited.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MIPS Technologies, Inc., nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY IMAGINATION TECHNOLOGIES LIMITED ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL IMAGINATION TECHNOLOGIES LIMITED BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifdef ANDROID_CHANGES
# include "machine/asm.h"
# include "machine/regdef.h"
#elif _LIBC
# include <sysdep.h>
# include <regdef.h>
# include <sys/asm.h>
#elif _COMPILING_NEWLIB
# include "machine/asm.h"
# include "machine/regdef.h"
#else
# include <regdef.h>
# include <sys/asm.h>
#endif

/* Testing on a little endian machine showed using CLZ was a
   performance loss, so we are not turning it on by default.  */
#if defined(__mips_xlp) || (defined(ENABLE_CLZ) && (__mips_isa_rev > 1))
# define USE_CLZ
#endif

/* Some asm.h files do not have the L macro definition.  */
#ifndef L
# if _MIPS_SIM == _ABIO32
#  define L(label) $L ## label
# else
#  define L(label) .L ## label
# endif
#endif

/* Some asm.h files do not have the PTR_ADDIU macro definition.  */
#ifndef PTR_ADDIU
# ifdef USE_DOUBLE
#  define PTR_ADDIU       daddiu
# else
#  define PTR_ADDIU       addiu
# endif
#endif

/* Allow the routine to be named something else if desired.  */
#ifndef STRCMP_NAME
# define STRCMP_NAME strcmp
#endif

#ifdef ANDROID_CHANGES
LEAF(STRCMP_NAME, 0)
#else
LEAF(STRCMP_NAME)
#endif
	.set	nomips16

	or	t0, a0, a1
	andi	t0, t0, 0x3
	bnec	t0, zero, L(byteloop)

/* Both strings are 4 byte aligned at this point.  */

	li	t8, 0x01010101
	li	t9, 0x7f7f7f7f

#define STRCMP32(OFFSET) \
	lw	v0, OFFSET(a0); \
	lw	v1, OFFSET(a1); \
	subu	t0, v0, t8; \
	nor	t1, v0, t9; \
	bnec	v0, v1, L(worddiff); \
	and	t0, t0, t1; \
	bnec	t0, zero, L(returnzero)

L(wordloop):
	STRCMP32(0)
	STRCMP32(4)
	STRCMP32(8)
	STRCMP32(12)
	STRCMP32(16)
	STRCMP32(20)
	STRCMP32(24)
	lw	v0, 28(a0)
	lw	v1, 28(a1)
	subu	t0, v0, t8
	nor	t1, v0, t9
	bnec	v0, v1, L(worddiff)
	and	t0, t0, t1
	PTR_ADDIU a0, a0, 32
	bnec	t0, zero, L(returnzero)
	PTR_ADDIU a1, a1, 32
	bc 	L(wordloop)

L(returnzero):
	move	rv0, zero
	jrc	ra

L(worddiff):
#ifdef USE_CLZ
	subu	t0, v0, t8
	nor	t1, v0, t9
	and	t1, t0, t1
	xor	t0, v0, v1
	or	t0, t0, t1
# if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	wsbh	t0, t0
	rotr	t0, t0, 16
# endif
	clz	t1, t0
	and	t1, 0xf8
# if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
	neg	t1
	addu	t1, 24
# endif
	rotrv	v0, v0, t1
	rotrv	v1, v1, t1
	and	v0, v0, 0xff
	and	v1, v1, 0xff
	subu	rv0, v0, v1
	jrc	ra
#else /* USE_CLZ */
# if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	andi	t0, v0, 0xff
	andi	t1, v1, 0xff
	beqc	t0, zero, L(wexit01)
	srl	t8, v0, 8
	bnec	t0, t1, L(wexit01)

	srl	t9, v1, 8
	andi	t8, t8, 0xff
	andi	t9, t9, 0xff
	beqc	t8, zero, L(wexit89)
	srl	t0, v0, 16
	bnec	t8, t9, L(wexit89)

	srl	t1, v1, 16
	andi	t0, t0, 0xff
	andi	t1, t1, 0xff
	beqc	t0, zero, L(wexit01)
	srl	t8, v0, 24
	bnec	t0, t1, L(wexit01)

	srl	t9, v1, 24
# else /* __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ */
	srl	t0, v0, 24
	srl	t1, v1, 24
	beqc	t0, zero, L(wexit01)
	srl	t8, v0, 16
	bnec	t0, t1, L(wexit01)

	srl	t9, v1, 16
	andi	t8, t8, 0xff
	andi	t9, t9, 0xff
	beqc	t8, zero, L(wexit89)
	srl	t0, v0, 8
	bnec	t8, t9, L(wexit89)

	srl	t1, v1, 8
	andi	t0, t0, 0xff
	andi	t1, t1, 0xff
	beqc	t0, zero, L(wexit01)
	andi	t8, v0, 0xff
	bnec	t0, t1, L(wexit01)

	andi	t9, v1, 0xff
# endif /* __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ */

L(wexit89):
	subu	rv0, t8, t9
	jrc	ra
L(wexit01):
	subu	rv0, t0, t1
	jrc	ra
#endif /* USE_CLZ */

/* It might seem better to do the 'beqc' instruction between the two 'lbu'
   instructions so that the nop is not needed but testing showed that this
   code is actually faster (based on glibc strcmp test).  */
#define BYTECMP01(OFFSET) \
	lbu	v1, OFFSET(a1); \
	nop; \
	beqc	v0, zero, L(bexit01); \
	lbu	t8, OFFSET+1(a0); \
	bnec	v0, v1, L(bexit01)

#define BYTECMP89(OFFSET) \
	lbu	t9, OFFSET(a1); \
	nop;	\
	beqc	t8, zero, L(bexit89); \
	lbu	v0, OFFSET+1(a0); \
	bnec	t8, t9, L(bexit89)

L(byteloop):
	lbu	v0, 0(a0)
	BYTECMP01(0)
	BYTECMP89(1)
	BYTECMP01(2)
	BYTECMP89(3)
	BYTECMP01(4)
	BYTECMP89(5)
	BYTECMP01(6)
	lbu	t9, 7(a1)
	nop
	beqc	t8, zero, L(bexit89)
	PTR_ADDIU a0, a0, 8
	bnec	t8, t9, L(bexit89)
	PTR_ADDIU a1, a1, 8
	bc	L(byteloop)

L(bexit01):
	subu	rv0, v0, v1
	jrc	ra
L(bexit89):
	subu	rv0, t8, t9
	jrc	ra

	.set	at

END(STRCMP_NAME)
#ifndef ANDROID_CHANGES
# ifdef _LIBC
libc_hidden_builtin_def (STRCMP_NAME)
# endif
#endif
