/*
 * Copyright 2015, Imagination Technologies Limited and/or its
 *                 affiliated group companies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 */

#define __MIPS_UHI_EXIT        1
#define __MIPS_UHI_OPEN        2
#define __MIPS_UHI_CLOSE       3
#define __MIPS_UHI_READ        4
#define __MIPS_UHI_WRITE       5
#define __MIPS_UHI_LSEEK       6
#define __MIPS_UHI_UNLINK      7
#define __MIPS_UHI_FSTAT       8
#define __MIPS_UHI_ARGC        9
#define __MIPS_UHI_ARGLEN      10
#define __MIPS_UHI_ARGN        11
#define __MIPS_UHI_RAMRANGE    12
#define __MIPS_UHI_LOG         13
#define __MIPS_UHI_ASSERT      14
#define __MIPS_UHI_EXCEPTION   15
#define __MIPS_UHI_FINDFIRST   16
#define __MIPS_UHI_FINDNEXT    17
#define __MIPS_UHI_FINDCLOSE   18
#define __MIPS_UHI_PREAD       19
#define __MIPS_UHI_PWRITE      20
#define __MIPS_UHI_YIELD       21
#define __MIPS_UHI_LINK        22

#define __xstr(s) __str(s)
#define __str(s) #s
#define __MIPS_UHI_SYSCALL_NUM 1

#ifdef __MIPS_SDBBP__
	#define SYSCALL(NUM) "\tsdbbp " __xstr (NUM)
	#define ASM_SYSCALL(NUM) sdbbp NUM
#else
	#define SYSCALL(NUM) "\tsyscall " __xstr (NUM)
	#define ASM_SYSCALL(NUM) syscall NUM
#endif
