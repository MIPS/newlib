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

#ifndef _M64C0_H_
#define _M64C0_H_

/*
 * Define macros for accessing the MIPS coprocessor 0 registers which are
 * 64 bits wide.
 * Most apart from "set" return the original register value.
 */

#define _m64c0_mfc0(selreg) \
__extension__ ({ \
  register unsigned long __r; \
  __asm__ __volatile ("dmfc0 %0,$%1,%2" \
		      : "=d" (__r) \
      		      : "JK" (selreg & 0x1F), "JK" (selreg>>8)); \
  __r; \
})

#define _m64c0_mtc0(selreg, val) \
do { \
    __asm__ __volatile (".set push \n"\
			".set noreorder\n"\
			"dmtc0 %z0,$%1,%2\n"\
			"ehb\n" \
			".set pop" \
			: \
			: "dJ" ((reg64_t)(val)), "JK" (selreg & 0x1F),\
			"JK" (selreg>>8) \
			: "memory"); \
} while (0)

#define _m64c0_mxc0(selreg, val) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0 (selreg); \
    _m64c0_mtc0 (selreg, val); \
    __o; \
})

#define _m64c0_bcc0(selreg, clr) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0 (selreg); \
    _m64c0_mtc0 (selreg, __o & ~(clr)); \
    __o; \
})

#define _m64c0_bsc0(selreg, set) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0 (selreg); \
    _m64c0_mtc0 (selreg, __o | (set)); \
    __o; \
})

#define _m64c0_bcsc0(selreg, clr, set) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0 (selreg); \
    _m64c0_mtc0 (selreg, (__o & ~(clr)) | (set)); \
    __o; \
})

/* MIPS64 TagLo register */
#define mips64_getitaglo()	_m64c0_mfc0(C0_TAGLO)	/* alias define */
#define mips64_setitaglo(x)	_m64c0_mtc0(C0_TAGLO,x)	/* alias define */
#define mips64_xchitaglo(x)	_m64c0_mxc0(C0_TAGLO,x)	/* alias define */
#define mips64_getdtaglo()	_m64c0_mfc0((C0_TAGLO+(2<<8)))
#define mips64_setdtaglo(x)	_m64c0_mtc0((C0_TAGLO+(2<<8)),x)
#define mips64_xchdtaglo(x)	_m64c0_mxc0((C0_TAGLO+(2<<8)),x)
#define mips64_gettaglo2()	_m64c0_mfc0((C0_TAGLO+(4<<8)))
#define mips64_settaglo2(x)	_m64c0_mtc0((C0_TAGLO+(4<<8)),x)
#define mips64_xchtaglo2(x)	_m64c0_mxc0((C0_TAGLO+(4<<8)),x)

/* MIPS64 DataLo register */
#define mips64_getdatalo()	_m64c0_mfc0((C0_TAGLO+(1<<8)))
#define mips64_setdatalo(x)	_m64c0_mtc0((C0_TAGLO+(1<<8)),x)
#define mips64_xchdatalo(x)	_m64c0_mxc0((C0_TAGLO+(1<<8)),x)
#define mips64_getidatalo()	mips64_getdatalo()	/* alias define */
#define mips64_setidatalo(x)	mips64_setdatalo(x)	/* alias define */
#define mips64_xchidatalo(x)	mips64_xchdatalo(x)	/* alias define */
#define mips64_getddatalo()	_m64c0_mfc0((C0_TAGLO+(3<<8)))
#define mips64_setddatalo(x)	_m64c0_mtc0((C0_TAGLO+(3<<8)),x)
#define mips64_xchddatalo(x)	_m64c0_mxc0((C0_TAGLO+(3<<8)),x)
#define mips64_getdatalo2()	_m64c0_mfc0((C0_TAGLO+(5<<8)))
#define mips64_setdatalo2(x)	_m64c0_mtc0((C0_TAGLO+(5<<8)),x)
#define mips64_xchdatalo2(x)	_m64c0_mxc0((C0_TAGLO+(5<<8)),x)

#ifdef C0_TAGHI
/* CP0 TagHi register */
#define mips64_gettaghi()	_m64c0_mfc0(C0_TAGHI)
#define mips64_settaghi(x)	_m64c0_mtc0(C0_TAGHI, x)
#define mips64_xchtaghi(x)	_m64c0_mxc0(C0_TAGHI, x)
#endif

#ifdef C0_WATCHLO
/* CP0 WatchLo register */
#define mips64_getwatchlo()	_m64c0_mfc0(C0_WATCHLO)
#define mips64_setwatchlo(x)	_m64c0_mtc0(C0_WATCHLO, x)
#define mips64_xchwatchlo(x)	_m64c0_mxc0(C0_WATCHLO, x)
#endif

#define _m64c0_mfc0_generic(reg, sel) \
__extension__ ({ \
  register unsigned long __r; \
  __asm__ __volatile ("dmfc0 %0,$%1,%2" \
		      : "=d" (__r) \
      		      : "JK" (reg), "JK" (sel)); \
  __r; \
})

#define _m64c0_mtc0_generic(reg, sel, val) \
do { \
    __asm__ __volatile (".set push \n"\
			".set noreorder\n"\
			"dmtc0 %z0,$%1,%2\n"\
			"ehb\n" \
			".set pop" \
			: \
			: "dJ" ((reg64_t)(val)), "JK" (reg), "JK" (sel) \
			: "memory"); \
} while (0)

#define _m64c0_mxc0_generic(reg, sel, val) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0_generic (reg, sel); \
    _m64c0_mtc0_generic (reg, sel, val); \
    __o; \
})

#define _m64c0_bcc0_generic(reg, sel, clr) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0_generic (reg, sel); \
    _m64c0_mtc0_generic (reg, sel, __o & ~(clr)); \
    __o; \
})

#define _m64c0_bsc0_generic(reg, sel, set) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0_generic (reg, sel); \
    _m64c0_mtc0_generic (reg, sel, __o | (set)); \
    __o; \
})

#define _m64c0_bcsc0_generic(reg, sel, clr, set) \
__extension__ ({ \
    register reg64_t __o; \
    __o = _m64c0_mfc0_generic (reg, sel); \
    _m64c0_mtc0_generic (reg, sel, (__o & ~(clr)) | (set)); \
    __o; \
})

/* Superset of MIPS32 */
#include <mips/m32c0.h>

/* Define MIPS64 user-level intrinsics */
#include <mips/mips64.h>

/* MIPS64-specific MMU interface */
#include <mips/m64tlb.h>

#endif /* _M64C0_H_ */
