#include "mdt.h"

#include <kernel/mm.h>
#include <kernel/panic.h>
#include <lib/mem.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>

#include "../../malloc/reserve_malloc.h"
#include "lib/math.h"
#include "lib/stdbitfield.h"
#include "lib/stdbool.h"


#define BF_BITS BITFIELD_CAPACITY(mdt_bf)

static vmalloc_mdt_container* container_list;


static inline void init_container(vmalloc_mdt_container* c, vmalloc_mdt_container* prev)
{
    DEBUG_ASSERT(c);
    DEBUG_ASSERT((v_uintptr)c % KPAGE_ALIGN == 0);

    c->hdr.next = NULL;
    c->hdr.prev = prev;

    for (size_t i = 0; i < PA_MDT_CONTAINER_NODES; i++)
        c->entries[i] = (vmalloc_pa_mdt) {0};

    for (size_t i = 0; i < PA_MDT_BF_COUNT; i++)
        c->reserved_entries[i] = 0;

    if (prev) {
        DEBUG_ASSERT(!prev->hdr.next);
        prev->hdr.next = c;
    }
}


void vmalloc_pa_mdt_init()
{
    container_list = mm_kpa_to_kva_ptr(early_kalloc(KPAGE_SIZE, "vmalloc pa mdt", true, false));

    init_container(container_list, NULL);
}


static void pa_mdt_container_free(vmalloc_mdt_container* c)
{
    if (c == container_list)
        return;

    if (c->hdr.prev)
        c->hdr.prev->hdr.next = c->hdr.next;
#ifdef DEBUG
    else
        PANIC("pa_mdt_container_free: prev should only be NULL if the node is the container list, "
              "which cannot be freed");
#endif

    if (c->hdr.next)
        c->hdr.next->hdr.prev = c->hdr.prev;

#ifdef DEBUG
    for (size_t i = 0; i < PA_MDT_BF_COUNT; i++)
        DEBUG_ASSERT(c->reserved_entries[i] == 0);
#endif

    raw_kfree(c);
}


static vmalloc_mdt_container* pa_mdt_container_new(vmalloc_mdt_container* prev)
{
    DEBUG_ASSERT(prev);
    DEBUG_ASSERT(prev->hdr.next == NULL);

    v_uintptr va = reserve_malloc().va;

    DEBUG_ASSERT((va & (KPAGE_SIZE - 1)) == 0);

    vmalloc_mdt_container* c = (vmalloc_mdt_container*)va;

    init_container(c, prev);

    return c;
}


static vmalloc_pa_mdt* node_new()
{
    size_t i, j, k;
    vmalloc_mdt_container *c, *p;
    c = container_list;

find:
    while (c) {
        for (i = 0; i < PA_MDT_CONTAINER_NODES; i++) {
            j = i / BF_BITS;
            k = i % BF_BITS;

            if (!bitfield_get(c->reserved_entries[j], k)) {
                // found free node
                bitfield_set_high(c->reserved_entries[j], k);

                return &c->entries[i];
            }
        }

        p = c;
        c = c->hdr.next;
    }

    c = pa_mdt_container_new(p);

    goto find;
}


static bool mdt_is_valid(rva_node* n)
{
    if (!n->mdt.pa_mdt)
        return true; // no pa assigned

    vmalloc_pa_mdt *c, *p;
    v_uintptr start, end, mdt_start, mdt_end, prev_end;

    start = n->start;
    end = n->start + n->size;

    c = n->mdt.pa_mdt;
    p = NULL;

    while (c) {
        mdt_start = c->va;
        mdt_end = c->va + (power_of2(c->order) * KPAGE_SIZE);

        if (mdt_start < start)
            return false;

        if (mdt_end > end)
            return false;

        if (p && mdt_start < prev_end)
            return false;

        p = c;
        c = c->next;
        prev_end = mdt_end;
    }

    return true;
}


void vmalloc_pa_mdt_push(rva_node* n, size_t o, p_uintptr pa, v_uintptr va)
{
    vmalloc_pa_mdt *cur, *prev, *node;

    DEBUG_ASSERT(n);

    node = node_new();
    *node = (vmalloc_pa_mdt) {
        .next = NULL,
        .order = o,
        .pa = pa,
        .va = va,
    };

    cur = n->mdt.pa_mdt;
    prev = NULL;

    // first node
    if (!cur || va < cur->va) {
        node->next = cur;
        n->mdt.pa_mdt = node;
        return;
    }

    // search pos by va
    while (cur && cur->va <= va) {
        prev = cur;
        cur = cur->next;
    }

    DEBUG_ASSERT(prev);
    node->next = cur;
    prev->next = node;

#ifdef DEBUG
    DEBUG_ASSERT(mdt_is_valid(n), "vmalloc_pa_mdt_push: pa mdt is not coherent");
#endif
}


void vmalloc_pa_mdt_pop(rva_node* n)
{
    DEBUG_ASSERT(n);

    vmalloc_pa_mdt *cur, *prev;

    cur = n->mdt.pa_mdt;

    while (cur) {
        

        prev = cur;
        cur = cur->next;
    }
}