/*
 * Copyright (c) 2014, Imagination Technologies LLC and Imagination
 * Technologies Limited.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 *
 */


/*
 * cache.h: switchable cache support for MIPS kit
 */

#define _BOOTCODE
#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/prid.h>

/*
 * The function of this module is to support boards which can handle
 * multiple MIPS cpus with different cache architectures.
 */

#define DECL(x, val)		\
	.sdata;			\
	EXPORTS(x, 4);		\
	.word	val




# define GETPRID

# define SWTEST(prid,dest) 	\
	b	dest;

#define R54SWITCH(x)



/* MIPS32/64 can be determined by any non-zero value in PrID bits 16:23 */
#if 1 /*#cache(m32)*/
# if defined(MULTICACHE)
#  define MIPS32SWITCH(x)	\
	srl	t2,t1,16; 	\
	and	t2,0xff; 	\
	bnez	t2,_ASMCONCAT(m32_, x);
# else
#  define MIPS32SWITCH(x)	\
	b	_ASMCONCAT(m32_, x);
# endif
#else
# define MIPS32SWITCH(x)
#endif







#define SWCACHE(name) 		\
LEAF(_ASMCONCAT(mips_, name));	\
	GETPRID			\
	MIPS32SWITCH(name)	\
	j	ra;		\
END(_ASMCONCAT(mips_, name))
