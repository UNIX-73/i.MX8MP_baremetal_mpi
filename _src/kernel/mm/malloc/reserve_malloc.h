#pragma once

#include <lib/mem.h>

/*
    Reserve allocator that reserves allocated pages (that must be mapped with KERNEL_BASE relation).
    The main use case is for when the raw_allocator needs a page for its internal components, as it
    cannot reallocate itself, it requests the reserve to give him a prereserved page. After
    finishing the initial allocation, it must allocate new pages for refilling the reserve.
*/


#define RESERVE_MALLOC_SIZE 32


/// must provide exactly one page of virtual memory mapped to a phys address
typedef pv_ptr (*reserve_allocator)(void);

void reserve_malloc_init();

void reserve_malloc_reconfig_allocator(reserve_allocator allocator);

pv_ptr reserve_malloc();

void reserve_malloc_fill();