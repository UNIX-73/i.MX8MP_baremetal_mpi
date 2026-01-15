#include "k_mem_mdt.h"

#include <boot/panic.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>


/*
    This files purpose is to save the metadata of the kernel allocated regions. It should not be
    confused with the metadata of the allocator blocks itself
*/


#define K_MEM_MDT_NULL_REGION_ID \
    (kmem_id)                    \
    {                            \
        .i = UINT64_MAX          \
    }
#define K_MEM_MDT_NULL_ENTRY                                                           \
    (k_mem_regions_mdt)                                                                \
    {                                                                                  \
        .region_id = K_MEM_MDT_NULL_REGION_ID, .region_tag = NULL, .permanent = false, \
    }


static k_mem_regions_mdt* k_mem_mdt_buf;


// if not found returns -1. Not thread safe by itself
static isize_t k_mem_mdt_find_region_idx(kmem_id region_id)
{
    isize_t idx = -1;
    for (size_t i = 0; i < K_MEM_MDT_ENTRIES; i++)
        if (k_mem_mdt_buf[i].region_id.i == region_id.i)
        {
            idx = i;
            break;
        }

    return idx;
}


void mm_kmem_mdt_init(void* region_addr, kmem_id k_mem_mdt_id)
{
    if (!region_addr)
        PANIC("mm_kmem_mdt_init: invalid block address provided");

    if ((uintptr)region_addr % _Alignof(k_mem_regions_mdt) != 0)
        PANIC("mm_kmem_mdt_init: region block not aligned!");

    if (k_mem_mdt_id.i != 0)
        PANIC("k_mem_mdt_init: expected region_id 0 for mdt self region");


    k_mem_mdt_buf = (k_mem_regions_mdt*)region_addr;

    for (size_t i = 0; i < K_MEM_MDT_ENTRIES; i++)
        k_mem_mdt_buf[i] = K_MEM_MDT_NULL_ENTRY;


    // the first entry is the k_mem_mdt region itself
    mm_kmem_region_mdt_push(k_mem_mdt_id, "k_mem_metadata", true);
}


void mm_kmem_region_mdt_push(kmem_id id, const char* tag, bool permanent)
{
    // search for first empty entry
    isize_t idx = k_mem_mdt_find_region_idx(K_MEM_MDT_NULL_REGION_ID);

    if (idx == -1)
        PANIC("k_mem_region_mdt: full");


    k_mem_mdt_buf[idx] = (k_mem_regions_mdt) {
        .region_id = id,
        .region_tag = tag ? tag : "unnamed_kernel_memory_region",
        .permanent = permanent,
    };
}


void mm_kmem_region_mdt_pop(kmem_id id)
{
    isize_t idx = k_mem_mdt_find_region_idx(id);

    if (idx == -1)
        PANIC("mm_kmem_region_mdt_pop: region not found");

    if (k_mem_mdt_buf[idx].permanent)
        PANIC("mm_kmem_region_mdt_pop: attempted to pop a permanent kernel memory region");

    k_mem_mdt_buf[idx] = K_MEM_MDT_NULL_ENTRY;
}


bool mm_kmem_region_mdt_read(kmem_id id, k_mem_regions_mdt* mdt)
{
    isize_t idx = k_mem_mdt_find_region_idx(id);

    if (idx == -1)
        return false;

    *mdt = k_mem_mdt_buf[idx];
    
    return true;
}