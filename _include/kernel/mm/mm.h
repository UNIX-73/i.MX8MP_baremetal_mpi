#pragma once

#include <lib/stdint.h>


void mm_init();

/// kernel memory region id
typedef struct
{
    uint16 i;
} kmem_id;


void* kalloc(size_t bytes);
void* kalloc_tagged(size_t bytes, const char* mregion_name);

void* kfree(void* adr);
kmem_id kmem_id_get(void* adr);