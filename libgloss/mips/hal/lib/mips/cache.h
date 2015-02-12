/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *                      affiliated group companies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 */

/*
 * cache.h: switchable cache support
 */

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

#define SWCACHE(name) 		\
LEAF(_ASMCONCAT(mips_, name));	\
	j	_ASMCONCAT(m32_, name); \
	jr	ra;		\
END(_ASMCONCAT(mips_, name))
