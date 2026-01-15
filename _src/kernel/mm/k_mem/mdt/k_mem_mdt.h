#pragma once
#include <kernel/mm/mm.h>
#include <lib/unit/mem.h>

#include "../k_mem.h"

// saves the data of the allocated kernel memory regions such as the name and the idx
typedef struct
{
    kmem_id region_id;      // Id of the xalloc region
    const char* region_tag; // The name of the region
    bool permanent;         // If a region should be never freed
} k_mem_regions_mdt;

#define KMEM_MDT_BLOCK_N 1
#define K_MEM_MDT_ENTRIES ((KMEM_BLOCK_SIZE * KMEM_MDT_BLOCK_N) / sizeof(k_mem_regions_mdt))


void mm_kmem_mdt_init(void* region_addr, kmem_id k_mem_mdt_id);
void mm_kmem_region_mdt_push(kmem_id id, const char* tag, bool permanent);
void mm_kmem_region_mdt_pop(kmem_id id);
bool mm_kmem_region_mdt_read(kmem_id id, k_mem_regions_mdt* mdt);
