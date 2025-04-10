/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * OpenRISC vmlinux.lds.S
 *
 * Linux architectural port borrowing liberally from similar works of
 * others.  All original copyrights apply as per the original source
 * declaration.
 *
 * Modifications for the OpenRISC architecture:
 * Copyright (C) 2003 Matjaz Breskvar <phoenix@bsemi.com>
 * Copyright (C) 2010-2011 Jonas Bonn <jonas@southpole.se>
 *
 * ld script for OpenRISC architecture
 */

/* TODO
 *		- clean up __offset & stuff
 *		- change all 8192 alignment to PAGE !!!
 *		- recheck if all alignments are really needed
 */

#  define LOAD_OFFSET  PAGE_OFFSET
#  define LOAD_BASE    PAGE_OFFSET

#include <asm/page.h>
#include <asm/cache.h>
#include <asm/thread_info.h>
#include <asm-generic/vmlinux.lds.h>

#ifdef __OR1K__
#define __OUTPUT_FORMAT        "elf32-or1k"
#else
#define __OUTPUT_FORMAT        "elf32-or32"
#endif

OUTPUT_FORMAT(__OUTPUT_FORMAT, __OUTPUT_FORMAT, __OUTPUT_FORMAT)
jiffies = jiffies_64 + 4;

SECTIONS
{
        /* Read-only sections, merged into text segment: */
        . = LOAD_BASE ;

	_text = .;

	/* _s_kernel_ro must be page aligned */
	. = ALIGN(PAGE_SIZE);
	_s_kernel_ro = .;

        .text                   : AT(ADDR(.text) - LOAD_OFFSET)
	{
          _stext = .;
	  HEAD_TEXT
	  TEXT_TEXT
	  SCHED_TEXT
	  LOCK_TEXT
	  KPROBES_TEXT
	  IRQENTRY_TEXT
	  SOFTIRQENTRY_TEXT
	  *(.fixup)
	  *(.text.__*)
	  _etext = .;
	}
	/* TODO: Check if fixup and text.__* are really necessary
	 * fixup is definitely necessary
	 */

	_sdata = .;

	/* Page alignment required for RO_DATA */
	RO_DATA(PAGE_SIZE)
	_e_kernel_ro = .;

	/* Whatever comes after _e_kernel_ro had better be page-aligend, too */

	/* 32 here is cacheline size... recheck this */
	RW_DATA(32, PAGE_SIZE, PAGE_SIZE)

        _edata  =  .;

	EXCEPTION_TABLE(4)

	/* Init code and data */
	. = ALIGN(PAGE_SIZE);
	__init_begin = .;

	/* Page aligned */
	INIT_TEXT_SECTION(PAGE_SIZE)

	/* Align __setup_start on 16 byte boundary */
	INIT_DATA_SECTION(16)

	PERCPU_SECTION(L1_CACHE_BYTES)

        __init_end = .;

	BSS_SECTION(0, 0, 0x20)

        _end = .;

	/* Throw in the debugging sections */
	STABS_DEBUG
	DWARF_DEBUG
	ELF_DETAILS

        /* Sections to be discarded -- must be last */
	DISCARDS
}
