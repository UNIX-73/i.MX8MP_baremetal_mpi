#pragma once

#include <lib/stdint.h>

void mm_init();

/// kernel memory region id
typedef struct
{
    uint64 i;
} kmem_id;


/// Allocates a memory region for the kernel. A name (tag) should be provided for debugging. If
/// allocated as permanent, the region should never be freed, it will panic if attempted to be
/// freed. It provides the kernel memory region id. This is the base allocator of the kernel, other
/// more fine tuned allocators may use this allocator to request a big memory area for themselves.
/// It provides memory regions multiple of 2MiB.
void* kalloc(size_t bytes, const char* tag, bool permanent, kmem_id* id);

void kfree(void* addr);
void kfree_kmem_id(kmem_id id);

bool kmem_id_get(void* addr, kmem_id* id);

const char* mm_get_kmem_tag(kmem_id id);