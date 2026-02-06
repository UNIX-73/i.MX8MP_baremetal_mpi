#include "containers.h"

#include <lib/stdbitfield.h>

#include "../../../malloc/reserve_malloc.h"
#include "kernel/mm.h"
#include "kernel/panic.h"
#include "lib/mem.h"
#include "lib/stdmacros.h"


static inline bool container_is_empty(vmalloc_node_container* c)
{
    ASSERT(c);

    for (size_t i = 0; i < BF_COUNT; i++) {
        if (c->data.reserved[i] != 0)
            return false;
    }

    return true;
}


static inline vmalloc_node_container* alloc_container(vmalloc_node_container* last)
{
    ASSERT(last->next == NULL);


    v_uintptr va = reserve_malloc().va;

    DEBUG_ASSERT((va & (KPAGE_SIZE - 1)) == 0);

    last->next = (vmalloc_node_container*)va;

    vmalloc_container_init_null(last->next);

    return last->next;
}


vmalloc_node* vmalloc_node_get_new(vmalloc_node_container* first)
{
#ifdef DEBUG
    size_t x = 0;
#endif

    ASSERT(first);

    vmalloc_node_container* cur = first;
    vmalloc_node_container* prev = NULL;

find_empty:
    while (cur) {
        for (size_t i = 0; i < NODE_COUNT; i++) {
            size_t j = i / BITFIELD_CAPACITY(bf);
            size_t k = i % BITFIELD_CAPACITY(bf);

            if (!bitfield_get(cur->data.reserved[j], k)) {
                // found an empty space
                bitfield_set_high(cur->data.reserved[j], k);

                return &cur->data.nodes[i];
            }
        }

        prev = cur;
        cur = cur->next;
    }

#ifdef DEBUG
    DEBUG_ASSERT(x++ == 0);
#endif

    cur = alloc_container(prev); // it updates prev->next inside

    goto find_empty;
}


void vmalloc_node_free(vmalloc_node_container* first, vmalloc_node* node)
{
    // get container by aligning down to 4096
    vmalloc_node_container* c = (vmalloc_node_container*)((v_uintptr)node & ~(KPAGE_SIZE - 1ULL));


    vmalloc_node* base = &c->data.nodes[0];
    size_t i = (size_t)(node - base);

    ASSERT(i < NODE_COUNT);

    size_t j = i / BITFIELD_CAPACITY(bf);
    size_t k = i % BITFIELD_CAPACITY(bf);


    DEBUG_ASSERT(bitfield_get(c->data.reserved[j], k), "vmalloc_node_free: double free");
    bitfield_clear(c->data.reserved[j], k);


    /* Node freed, the next step is to watch if the container can be freed */
    if (!container_is_empty(c))
        return;


    vmalloc_node_container* cur = first;
    while (cur) {
        if (cur->next == c) {
            cur->next = c->next;

            raw_kfree(c, &RAW_KMALLOC_DEFAULT_CFG);
            return;
        }

        cur = cur->next;
    }

    PANIC();
}
