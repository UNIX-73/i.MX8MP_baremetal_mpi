#include <kernel/mm/mm.h>
#include <lib/malloc/xalloc.h>
#include <lib/stdmacros.h>
#include <lib/unit/mem.h>

#include "lib/stdint.h"


static uintptr kmem_start;
static uintptr kmem_end;
static size_t kmem_size;

static const size_t KMEM_BLOCK_SIZE = 2 * MEM_MiB;
_Alignas(8) xalloc_block_metadata kmem_mdt;
xalloc_handle kmem_handle;


static inline size_t get_kmem_blockcount(size_t bytes)
{
    return (bytes + KMEM_BLOCK_SIZE - 1) / KMEM_BLOCK_SIZE;
}

void mm_kmem_init()
{
    // from the linker
    extern uintptr __kernel_mem_start[];
    extern uintptr __kernel_mem_end[];

    kmem_start = (uintptr)__kernel_mem_start;
    kmem_end = (uintptr)__kernel_mem_end;
    kmem_size = kmem_end - kmem_start;

    xalloc_init(&kmem_handle, kmem_start, KMEM_BLOCK_SIZE, kmem_size / KMEM_BLOCK_SIZE, &kmem_mdt);
}


void* kalloc(size_t bytes)
{
    uint16 reg_id;
    // TODO: save the idx

    return xalloc_alloc(&kmem_handle, &reg_id, get_kmem_blockcount(bytes));
}

void* kalloc_tagged(size_t size, const char* mregion_name);

void* kfree(void* adr);
kmem_id kmem_id_get(void* adr);