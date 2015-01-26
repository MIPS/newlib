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

#ifndef _MIPS_ASM_H_
#define _MIPS_ASM_H_

/*
 * asm.h: various macros to help assembly language writers
 */

/* ABI specific stack frame layout and manipulation. */
#if _MIPS_SIM==_ABIO32
/* Standard O32 */
#define SZREG		4	/* saved register size */
#define	REG_S		sw	/* store saved register */
#define	REG_L		lw	/* load saved register */
#define SZARG		4	/* argument register size */
#define	NARGSAVE	4	/* arg register space on caller stack */
#define ALSZ		7	/* stack alignment - 1 */
#define ALMASK		(~7)	/* stack alignment mask */
#define LOG2_STACK_ALGN	3	/* log2(8) */
#define SZPTR		4	/* pointer size */
#define LOG2_SZPTR	2	/* log2(4) */
#define PTR_S		sw	/* store pointer */
#define PTR_L		lw	/* load pointer */
#define PTR_SUBU	subu	/* decrement pointer */
#define PTR_ADDU	addu	/* increment pointer */
#define PTR_MFC0	mfc0	/* access CP0 pointer width register */
#define PTR_MTC0	mtc0	/* access CP0 pointer width register */
#define LA		la	/* load an address */
#define PTR		.word	/* pointer type pseudo */                  
#elif _MIPS_SIM==_ABIO64
/* Cygnus O64 */
#define SZREG		8	/* saved register size */		   
#define	REG_S		sd	/* store saved register */		   
#define	REG_L		ld	/* load saved register */		   
#define SZARG		8	/* argument register size */		   
#define	NARGSAVE	4	/* arg register space on caller stack */   
#define ALSZ		7	/* stack alignment - 1 */		   
#define ALMASK		(~7)	/* stack alignment mask */		   
#define LOG2_STACK_ALGN	3	/* log2(8) */
#define SZPTR		4	/* pointer size */			   
#define LOG2_SZPTR	2	/* log2(4) */
#define PTR_S		sw	/* store pointer */			   
#define PTR_L		lw	/* load pointer */			   
#define PTR_SUBU	subu	/* decrement pointer */			   
#define PTR_ADDU	addu	/* increment pointer */			   
#define PTR_MFC0	dmfc0	/* access CP0 pointer width register */
#define PTR_MTC0	mtc0	/* access CP0 pointer width register */
#define LA		la	/* load an address */
#define PTR		.word	/* pointer type pseudo */                  
#elif _MIPS_SIM==_ABIN32
/* Standard N32 */
#define SZREG		8	/* saved register size */		   
#define	REG_S		sd	/* store saved register */		   
#define	REG_L		ld	/* load saved register */		   
#define SZARG		8	/* argument register size */		   
#define	NARGSAVE	0	/* arg register space on caller stack */   
#define ALSZ		15	/* stack alignment - 1 */		   
#define ALMASK		(~15)	/* stack alignment mask */		   
#define LOG2_STACK_ALGN	4	/* log2(16) */
#define SZPTR		4	/* pointer size */			   
#define LOG2_SZPTR	2	/* log2(4) */
#define PTR_S		sw	/* store pointer */			   
#define PTR_L		lw	/* load pointer */			   
#define PTR_SUBU	subu	/* decrement pointer (SGI uses sub) */
#define PTR_ADDU	addu	/* increment pointer (SGI uses add) */
#define PTR_MFC0	mfc0	/* access CP0 pointer width register */
#define PTR_MTC0	mtc0	/* access CP0 pointer width register */
#define LA		la	/* load an address */
#define PTR		.word	/* pointer type pseudo */                  
#elif _MIPS_SIM==_ABI64
/* Standard N64 */
#define SZREG		8	/* saved register size */		   
#define	REG_S		sd	/* store saved register */		   
#define	REG_L		ld	/* load saved register */		   
#define SZARG		8	/* argument register size */		   
#define	NARGSAVE	0	/* arg register space on caller stack */   
#define ALSZ		15	/* stack alignment - 1 */		   
#define ALMASK		(~15)	/* stack alignment mask */		   
#define LOG2_STACK_ALGN	4	/* log2(16) */
#define SZPTR		8	/* pointer size */			   
#define LOG2_SZPTR	3	/* log2(8) */
#define PTR_S		sd	/* store pointer */			   
#define PTR_L		ld	/* load pointer */			   
#define PTR_SUBU	dsubu	/* decrement pointer */			   
#define PTR_ADDU	daddu	/* increment pointer */			   
#define PTR_MFC0	dmfc0	/* access CP0 pointer width register */
#define PTR_MTC0	dmtc0	/* access CP0 pointer width register */
#define LA		dla	/* load an address */
#define PTR		.dword	/* pointer type pseudo */                  
#else
#error Unknown ABI
#endif

/* Concatenate two names. */
#ifdef __STDC__
# define _ASMCONCAT(A, B) A ## B
#else
# define _ASMCONCAT(A, B) A/**/B
#endif

/* Name of reset code section. */
#ifndef _RESET_SECTION
# define _RESET_SECTION .section .reset, "ax", @progbits
#endif

#ifndef _RESET_SECTION_NAMED
/* No function section support for now, since binutils fails to cope with
   external branches. */
# define _RESET_SECTION_NAMED(name) .pushsection .reset, "ax", @progbits
#endif

/* Name of boot code section. */
#ifndef _BOOT_SECTION
# define _BOOT_SECTION .section .boot, "ax", @progbits
#endif

#ifndef _BOOT_SECTION_NAMED
/* No function section support for now, since binutils fails to cope with
   external branches. */
# define _BOOT_SECTION_NAMED(name) .pushsection .boot, "ax", @progbits
#endif

/* Name of standard code section. */
#ifndef _NORMAL_SECTION_UNNAMED
# define _NORMAL_SECTION_UNNAMED .section .text, "ax", @progbits
#endif

#ifndef _NORMAL_SECTION_NAMED
# ifdef _FUNCTION_SECTIONS_
#  define _NORMAL_SECTION_NAMED(name) .pushsection .text ##.name, "ax", @progbits
# else
#  define _NORMAL_SECTION_NAMED(name) .pushsection .text, "ax", @progbits
# endif
#endif

/* Default code section. */
#ifndef _TEXT_SECTION_NAMED
# if defined(_RESETCODE)
#  define _TEXT_SECTION_NAMED _RESET_SECTION_NAMED
# elif defined(_BOOTCODE)
#  define _TEXT_SECTION_NAMED _BOOT_SECTION_NAMED
# else
#  define _TEXT_SECTION_NAMED _NORMAL_SECTION_NAMED
# endif
#endif

#ifndef _TEXT_SECTION
# if defined(_RESETCODE)
#  define _TEXT_SECTION _RESET_SECTION
# elif defined(_BOOTCODE)
#  define _TEXT_SECTION _BOOT_SECTION
# else
#  define _TEXT_SECTION _NORMAL_SECTION_UNNAMED
# endif
	_TEXT_SECTION
#endif

/*
 * Leaf functions declarations.
 */

/* Global leaf function. */
#define LEAF(name) 			\
  	_TEXT_SECTION_NAMED(name);	\
  	.globl	name; 			\
  	.ent	name; 			\
name:

/* Static/Local leaf function. */
#define SLEAF(name) 			\
  	_TEXT_SECTION_NAMED(name);	\
  	.ent	name; 			\
name:

/* Weak leaf function. */
#define WLEAF(name) 			\
  	_TEXT_SECTION_NAMED(name);	\
  	.weakext name; 			\
  	.ent	name; 			\
name:

/* Weak alias leaf function. */
#define ALEAF(name,alias) 		\
  	_TEXT_SECTION_NAMED(name);	\
  	.weakext alias,name; 		\
  	.ent	name; 			\
name:

/*
 * Alternative function entrypoints.
 */

/* Global alternative entrypoint. */
#define AENT(name) 			\
  	.globl	name; 			\
  	.aent	name; 			\
name:
#define XLEAF(name)	AENT(name)

/* Local/static alternative entrypoint. */
#define SAENT(name) 			\
  	.aent	name; 			\
name:
#define SXLEAF(name)	SAENT(name)


/*
 * Leaf functions declarations.
 */

/* Global nested function. */
#define NESTED(name, framesz, rareg)	\
  	_TEXT_SECTION_NAMED(name);	\
  	.globl	name; 			\
  	.ent	name; 			\
	.frame	sp, framesz, rareg;	\
name:

/* Static/Local nested function. */
#define SNESTED(name, framesz, rareg)	\
  	_TEXT_SECTION_NAMED(name);	\
  	.ent	name; 			\
	.frame	sp, framesz, rareg;	\
name:

/* Weak nested function. */
#define WNESTED(name, framesz, rareg)	\
  	_TEXT_SECTION_NAMED(name);	\
  	.weakext name; 			\
  	.ent	name; 			\
	.frame	sp, framesz, rareg;	\
name:

/* Weak alias nested function. */
#define ANESTED(name, alias, framesz, rareg) \
  	_TEXT_SECTION_NAMED(name);	\
    	.weakext alias, name;		\
  	.ent	name; 			\
	.frame	sp, framesz, rareg;	\
name:

/*
 * Function termination
 */
#define END(name) 			\
  	.size name,.-name; 		\
  	.end	name;			\
	.popsection

#define SEND(name)	END(name)
#define WEND(name)	END(name)
#define AEND(name,alias) END(name)

/*
 * Global data declaration.
 */
#define EXPORT(name) \
  	.globl name; \
  	.type name,@object; \
name:

/*
 * Global data declaration with size.
 */
#define EXPORTS(name,sz) 		\
  	.globl name; 			\
  	.type name,@object; 		\
  	.size name,sz; 			\
name:

/*
 * Weak data declaration with size.
 */
#define WEXPORT(name,sz) 		\
  	.weakext name; 			\
  	.type name,@object; 		\
  	.size name,sz; 			\
name:

/*
 * Global data reference with size.
 */
#define	IMPORT(name, size) 		\
	.extern	name,size

/*
 * Global zeroed data.
 */
#define BSS(name,size) 			\
  	.type name,@object; 		\
	.comm	name,size

/*
 * Local zeroed data.
 */
#define LBSS(name,size) 		\
  	.lcomm	name,size

/*
 * Insert call to _mcount if profiling.
 */
#ifdef __PROFILING__
#define _MCOUNT 			\
	.set push; 			\
	.set noat; 			\
	move	$1,$31; 		\
	jal	_mcount; 		\
  	.set pop
#else
#define _MCOUNT
#endif

#endif /*_MIPS_ASM_H_*/
