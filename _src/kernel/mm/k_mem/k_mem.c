
#include "k_mem.h"

#include <kernel/mm/mm.h>
#include <lib/lock/spinlock.h>
#include <lib/malloc/xalloc.h>
#include <lib/stdmacros.h>

#include "./mdt/k_mem_mdt.h"
#include "boot/panic.h"
#include "lib/lock/_lock_types.h"
#include "lib/stdint.h"


static uintptr kmem_start;
static uintptr kmem_end;
static size_t kmem_size;

/// It is the metadata of the allocator blocks itself, not the metadata of the kernel regions. The
/// kernel regions metadata lives in the first block of the xallocator memory
xalloc_block_metadata kmem_mdt_xalloc_mdt[K_MEM_MDT_ENTRIES];
xalloc_handle kmem_handle;

static spinlock_t k_mem_lock;

void mm_kmem_init()
{
    // from the linker
    spinlock_init(&k_mem_lock);

    extern uintptr __kernel_mem_start[];
    extern uintptr __kernel_mem_end[];

    kmem_start = (uintptr)__kernel_mem_start;
    kmem_end = (uintptr)__kernel_mem_end;
    kmem_size = kmem_end - kmem_start;

    bool result = xalloc_init(&kmem_handle, kmem_start, KMEM_BLOCK_SIZE,
                              kmem_size / KMEM_BLOCK_SIZE, kmem_mdt_xalloc_mdt);
    if (!result)
        PANIC("mm_kmem_init: cannot init the xallocator");


    /*
        Initialize the kernel region metadata block. It is a memory block that saves the kernel
        blocks metadata itself such as the xalloc id, name and if it should be permanent. It is not
        the allocator blocks metadata itself although they share the ids
    */
    uint64 kmem_mdt_id;
    void* kmem_mdt_addr = xalloc_alloc(&kmem_handle, &kmem_mdt_id, KMEM_MDT_BLOCK_N);

    mm_kmem_mdt_init(kmem_mdt_addr, (kmem_id) {.i = kmem_mdt_id});
}


void* mm_kmem_alloc(size_t bytes, const char* tag, bool permanent, kmem_id* id)
{
    if (bytes == 0)
        return NULL;

    size_t block_n = (bytes + (KMEM_BLOCK_SIZE - 1)) / KMEM_BLOCK_SIZE;

    uint64 reg_id;
    void* addr = xalloc_alloc(&kmem_handle, &reg_id, block_n);

    if (!addr)
        return addr;

    kmem_id memid = (kmem_id) {.i = reg_id};
    if (id)
        *id = memid;

    mm_kmem_region_mdt_push(memid, tag, permanent);

    return addr;
}


void mm_kmem_free(void* addr)
{
    kmem_id id;
    bool result = xalloc_get_region_id(&kmem_handle, addr, &id.i);

    if (!result)
        PANIC("mm_kmem_free: double free");

    // free by address because it should be faster than looking for the id
    xalloc_free(&kmem_handle, addr);

    // remove the metadata
    mm_kmem_region_mdt_pop(id);
}

void mm_kmem_free_id(kmem_id id)
{
    xalloc_free_id(&kmem_handle, id.i);
    mm_kmem_region_mdt_pop(id);
}


bool mm_kmem_get_id(void* addr, kmem_id* id)
{
    if (id)
        return xalloc_get_region_id(&kmem_handle, addr, &id->i);

    return false;
}
