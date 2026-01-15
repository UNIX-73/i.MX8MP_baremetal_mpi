#include <kernel/mm/mm.h>
#include <lib/stdmacros.h>

#include "./k_mem/k_mem.h"
#include "./mmu/mm_mmu.h"
#include "k_mem/mdt/k_mem_mdt.h"


void mm_init()
{
    mm_kmem_init();
    mm_mmu_init();
}


void* kalloc(size_t bytes, const char* tag, bool permanent, kmem_id* id)
{
    return mm_kmem_alloc(bytes, tag, permanent, id);
}


void kfree(void* addr)
{
    mm_kmem_free(addr);
}


void kfree_kmem_id(kmem_id id)
{
    mm_kmem_free_id(id);
}


bool kmem_id_get(void* addr, kmem_id* id)
{
    return mm_kmem_get_id(addr, id);
}


const char* mm_get_kmem_tag(kmem_id id)
{
    k_mem_regions_mdt mdt;
    bool r = mm_kmem_region_mdt_read(id, &mdt);

    return r ? mdt.region_tag : NULL;
}