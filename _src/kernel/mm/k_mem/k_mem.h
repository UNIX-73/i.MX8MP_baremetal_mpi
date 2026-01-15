#pragma once
#include <kernel/mm/mm.h>
#include <lib/stdbool.h>
#include <lib/stdint.h>

#define KMEM_BLOCK_SIZE (2 * MEM_MiB)

void mm_kmem_init();

/// Allocates the region with xalloc and saves the metadata of the region. Returns the asigned id
void* mm_kmem_alloc(size_t bytes, const char* tag, bool permanent, kmem_id* id);

/// Frees the region and the metadata
void mm_kmem_free(void* addr);

/// Same as mm_kmem_free but with id input instead of the address. It is slower than by address
void mm_kmem_free_id(kmem_id id);

/// Gets the id of a memory address. false if not found
bool mm_kmem_get_id(void* addr, kmem_id* id);