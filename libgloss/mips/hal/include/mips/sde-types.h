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
 * sde-types.h : define SDE specific system types
 */


#ifndef __SYS_TYPES_H
#ifdef __cplusplus
extern "C" {
#endif
#define __SYS_TYPES_H

#ifndef __ASSEMBLER__

#include <stdint.h>	/* get compiler types */
#include <sys/types.h>
#include <machine/ansi.h>
#include <machine/types.h>
#include <machine/endian.h>

/* --- Types --- */
#ifdef _TIME_T_		/* also in time.h */
typedef _TIME_T_ time_t;
#undef _TIME_T_
#endif

#ifdef _SIZE_T_		/* also in stddef.h */
typedef _SIZE_T_ size_t;
#undef _SIZE_T_
#endif

#ifdef _SSIZE_T_
typedef _SSIZE_T_ ssize_t;
#undef _SSIZE_T_
#endif

#ifdef _OFF_T_
typedef _OFF_T_ off_t;
#undef _OFF_T_
#endif

#ifdef	_CLOCKID_T_
typedef	_CLOCKID_T_	clockid_t;
#undef	_CLOCKID_T_
#endif

#ifdef	_TIMER_T_
typedef	_TIMER_T_	timer_t;
#undef	_TIMER_T_
#endif

#if !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
typedef	unsigned char	u_char;
typedef	unsigned short	u_short;
typedef	unsigned int	u_int;
typedef	unsigned long	u_long;

typedef unsigned char	unchar;		/* Sys V compatibility */
typedef	unsigned short	ushort;		/* Sys V compatibility */
typedef	unsigned int	uint;		/* Sys V compatibility */
typedef unsigned long	ulong;		/* Sys V compatibility */
#endif

/* BSD internals */
typedef	uint64_t	u_quad_t;	/* quads */
typedef	int64_t		quad_t;
typedef	quad_t *	qaddr_t;

typedef	char *		caddr_t;	/* core address */
typedef	int32_t		daddr_t;	/* disk address */
typedef	uint16_t	dev_t;		/* device number */
typedef	uint32_t	fixpt_t;	/* fixed point number */
typedef	uint16_t	gid_t;		/* group id */
typedef	uint16_t	ino_t;		/* inode number */
typedef	long		key_t;		/* IPC key (for Sys V IPC) */
typedef	uint16_t	mode_t;		/* permissions */
typedef	uint16_t	nlink_t;	/* link count */
typedef	int16_t		pid_t;		/* process id */
typedef	uint16_t	uid_t;		/* user id */
typedef quad_t		rlim_t;		/* resource limit */
typedef	uint32_t	useconds_t;	/* microseconds */
typedef	int32_t		suseconds_t;	/* microseconds (signed) */

/*
 * XPG4.2 states that inclusion of <netinet/in.h> must pull these
 * in and that inclusion of <sys/socket.h> must pull in sa_family_t.
 * We put there here because there are other headers that require
 * these types and <sys/socket.h> and <netinet/in.h> will indirectly
 * include <sys/types.h>.  Thus we are compliant without too many hoops.
 */
typedef uint32_t	in_addr_t;	/* base type for internet address */
typedef uint16_t	in_port_t;	/* IP port type */
typedef uint8_t	sa_family_t;	/* sockaddr address family type */
typedef uint32_t	socklen_t;	/* length type for network syscalls */

#if !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)

#ifndef _KERNEL
/* required by some network header files */
#include <sys/cdefs.h>
#endif

#define	NBBY	8		/* number of bits in a byte */

/*
 * Select uses bit masks of file descriptors in longs.  These macros
 * manipulate such bit fields (the filesystem macros use chars).
 * FD_SETSIZE may be defined by the user, but the default here should
 * be enough for most uses.
 */
#ifndef	FD_SETSIZE
#define	FD_SETSIZE	64
#endif

typedef int32_t	fd_mask;
#define NFDBITS	(sizeof(fd_mask) * NBBY)	/* bits per mask */

#ifndef howmany
#define	howmany(x, y)	(((x) + ((y) - 1)) / (y))
#endif


typedef	struct fd_set {
	fd_mask	fds_bits[howmany(FD_SETSIZE, NFDBITS)];
} fd_set;

#define	FD_SET(n, p)	((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define	FD_CLR(n, p)	((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
#define	FD_ISSET(n, p)	((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
#define	FD_COPY(f, t)	memcpy(t, f, sizeof(*(f)))
#define	FD_ZERO(p)	memset(p, 0, sizeof(*(p)))
#endif /* !defined(_POSIX_SOURCE) ... */

#endif /* __ASSEMBLER__ */

#ifdef __cplusplus
}
#endif
#endif /* !__SYS_TYPES_H */

