/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *                      affiliated group companies.
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

/*
 * Use the macros themselves for idempotency to ease replacement at the OS
 * level.
 */

#if !defined(_mips_intpatch) || !defined(_mips_intmask) || !defined(_mips_intack)
#include <mips/m32c0.h>
#endif

#ifndef _mips_intpatch

#include <mips/endian.h>

#if (BYTE_ORDER==LITTLE_ENDIAN) && defined (__mips_micromips)
#define  _mips_intpatch_isroff1 0x04
#define  _mips_intpatch_isroff2 0x08
#define  _mips_intpatch_isroff3 0x10
#define  _mips_intpatch_isroff4 0x18
#else
#define  _mips_intpatch_isroff1 0x06
#define  _mips_intpatch_isroff2 0x0a
#define  _mips_intpatch_isroff3 0x12
#define  _mips_intpatch_isroff4 0x1a
#endif

#ifdef __mips_micromips
#define _mips_intpatch_clean(ISR) ((ISR) & ~1)
#else
#define _mips_intpatch_clean(ISR) (ISR)
#endif

#if SZPTR==4
#define _mips_intpatch(INT, ISR) __extension__				       \
({									       \
	extern void m32_sync_icache(unsigned kva, size_t n);		       \
	extern void *__isr_vec_space;				               \
	uint16_t *patch;						       \
	uintptr_t handler = _mips_intpatch_clean((ISR));		       \
	uintptr_t isrbase = (uintptr_t) (mips32_getebase() & EBASE_BASE)       \
                + 0x200 + ((INT) * ((uintptr_t) &__isr_vec_space));            \
	handler += (handler & 0x8000) << 1;				       \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff1);	       \
	*patch = (uint16_t) (handler >> 16);			/* %hi */      \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff2);	       \
	*patch = (uint16_t) (handler & 0xffff);			/* %lo */      \
	m32_sync_icache(isrbase, 32);					       \
})
#else
#define _mips_intpatch(INT, ISR) __extension__				       \
({									       \
	extern void m32_sync_icache(unsigned kva, size_t n);		       \
	extern void *__isr_vec_space;				               \
	uint16_t *patch;						       \
	uint16_t *patch;						       \
	uintptr_t handler = _mips_intpatch_clean((ISR));		       \
	uintptr_t isrbase = (uintptr_t) (mips32_getebase() & EBASE_BASE)       \
                + 0x200 + ((INT) * ((uintptr_t) &__isr_vec_space));            \
	handler += (handler & 0x800080008000) << 1;			       \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff1);	       \
	*patch = (uint16_t) (handler >> 48);			/* %highest */ \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff2);	       \
	*patch = (uint16_t) ((handler >> 32) & 0xffff);		/* %higher */  \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff3);	       \
	*patch = (uint16_t) ((handler >> 16) & 0xffff);		/* %hi */      \
	patch = (uint16_t *) (isrbase + _mips_intpatch_isroff4);	       \
	*patch = (uint16_t) (handler & 0xffff);			/* %lo */      \
	m32_sync_icache(isrbase, 64);					       \
})
#endif
#endif				/* _mips_intpatch */

#ifndef _mips_intmask
reg_t _mips_intmask(const reg_t index, const reg_t enable);
#endif				/* _mips_intmask */

#ifndef _mips_intack
reg_t _mips_intack(const reg_t index);
#endif				/* _mips_intack */
