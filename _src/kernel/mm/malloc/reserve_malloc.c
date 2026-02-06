#include "reserve_malloc.h"

#include <kernel/panic.h>
#include <lib/mem.h>
#include <lib/stdbitfield.h>

#include "early_kalloc.h"
#include "kernel/mm.h"
#include "lib/stdbool.h"


static reserve_allocator reserve_alloc;

static pv_ptr reserved_addr[RESERVE_MALLOC_SIZE];
static bitfield32 reserved_pages;


static pv_ptr reserve_malloc_early_allocator()
{
    p_uintptr pa = early_kalloc(KPAGE_SIZE, "reserve_allocator_page", false, false);
    v_uintptr va = mm_kpa_to_kva(pa); // works because all the memblocks are assured to be mapped
                                      // with the kernel physmap offset

    return pv_ptr_new(pa, va);
}


void reserve_malloc_init()
{
    ASSERT(RESERVE_MALLOC_SIZE <= bitfield_bit_size(reserved_pages));

    reserve_alloc = reserve_malloc_early_allocator;
    reserved_pages = 0;

    reserve_malloc_fill();
}


void reserve_malloc_reconfig_allocator(reserve_allocator allocator)
{
    reserve_alloc = allocator;
}


pv_ptr reserve_malloc()
{
    for (size_t i = 0; i < RESERVE_MALLOC_SIZE; i++) {
        if (bitfield_get(reserved_pages, i)) {
            pv_ptr pmap = reserved_addr[i];
            bitfield_clear(reserved_pages, i);

            DEBUG_ASSERT(ptrs_are_kmapped(pmap));

            return pmap;
        }
    }

    PANIC("reserve_malloc: no more reserved pages available");
}


void reserve_malloc_fill()
{
    if (reserved_pages == (typeof(reserved_pages))((1ULL << RESERVE_MALLOC_SIZE) - 1))
        return;

    for (size_t i = 0; i < RESERVE_MALLOC_SIZE; i++) {
        if (!bitfield_get(reserved_pages, i)) {
            pv_ptr pv = reserve_alloc();

            ASSERT(pv.pa != 0 && ptrs_are_kmapped(pv));
            reserved_addr[i] = pv;

            bitfield_set_high(reserved_pages, i);
        }
    }
}