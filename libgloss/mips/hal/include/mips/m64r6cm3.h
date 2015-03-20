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
 * m64r6cm3.h : MIPS64R6 CM3 definitions
 */

#ifndef _M64R6CM3_H_
#define _M64R6CM3_H_

#ifdef __cplusplus
extern "C" {
#endif

#define CMGCR_BASE_ADDR_SHIFT	11

/* Offsets of memory-mapped registers */
#define GCR_L2_CONFIG		0x130
#define GCR_TAG_ADDR		0x600
#define GCR_TAG_STATE		0x608
#define GCR_TAG_DATA		0x610

#ifdef __cplusplus
}
#endif

#endif /* _M64R6CM3_H_ */
