#pragma once
#include <arm/mmu/mmu.h>
#include <lib/stdint.h>

#include "../malloc/early_kalloc.h"
#include "lib/mem.h"
#include "page.h"


typedef struct {
    uint8 order;
    p_uintptr pa;
    mm_page_data data;
} mm_page;


static inline bool page_is_valid(mm_page p)
{
    return p.order != UINT8_MAX;
}


void page_allocator_init();

/// allocates the early stage memblocks. Returns the start of the first free pa for debugging and
/// checking
p_uintptr page_allocator_update_memblocks(const memblock* mblcks, size_t n);


#ifdef DEBUG
p_uintptr page_allocator_testing_init();

#endif


size_t page_allocator_bytes_to_order(size_t bytes);

mm_page page_malloc(size_t order, mm_page_data p);

void page_free(p_uintptr pa);

/// should not be prioritized over page_free(), the main purpose is to clean non permanent early
/// stage allocations
void page_free_by_tag(const char* tag);


void page_allocator_debug_pages(bool full_print);
void page_allocator_debug();
void page_allocator_validate();