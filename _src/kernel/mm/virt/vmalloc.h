#pragma once

#include <lib/mem.h>
#include <lib/stdint.h>

#include "../malloc/early_kalloc.h"


void vmalloc_init();
v_uintptr vmalloc_update_memblocks(const memblock* mblcks, size_t n);


typedef struct {
    struct {
        bool use_kmap;
        p_uintptr kmap_pa;
    } kmap;
    bool assing_pa;
    bool device_mem;
    bool permanent;
} vmalloc_cfg;

typedef struct {
    const char* tag;
    bool kmapped;
    bool pa_assigned;
    bool device_mem;
    bool permanent;
} vmalloc_allocated_area_mdt;

v_uintptr vmalloc(size_t pages, const char* tag, vmalloc_cfg cfg);

/// frees an allocated area, returns the byte count of the area. If provided a not null info, also
/// provides the freed area info
size_t vfree(v_uintptr va, vmalloc_allocated_area_mdt* info);

typedef enum {
    VMALLOC_VA_INFO_FREE,
    VMALLOC_VA_INFO_RESERVED,
    VMALLOC_VA_UNREGISTERED,
} vmalloc_va_info_state;


struct vmalloc_pa_mdt; // forward decl

typedef struct {
    vmalloc_allocated_area_mdt info;
    struct vmalloc_pa_mdt* pa_mdt;
} vmalloc_mdt;

typedef struct {
    vmalloc_va_info_state state;
    union {
        struct {
            v_uintptr free_start;
            size_t free_size;
        } free;

        struct {
            v_uintptr reserved_start;
            size_t reserved_size;
            vmalloc_mdt mdt;
        } reserved;
    } state_info;
} vmalloc_va_info;


const char* vmalloc_update_tag(void* addr, const char* new_tag);

vmalloc_va_info vmalloc_get_addr_info(void* addr);

void vmalloc_debug_free();
void vmalloc_debug_reserved();

size_t vmalloc_get_free_bytes();
size_t vmalloc_get_reserved_bytes();
