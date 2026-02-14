#include "tests.h"

#ifdef DEBUG

#    include "kernel/panic.h"
#    include "page_allocator.h"

#    define TEST_ASSERT(cond, msg) \
        do {                       \
            if (!(cond))           \
                PANIC(msg);        \
        } while (0)

#    define RUN_TEST(fn)                       \
        do {                                   \
            term_prints("[TEST] " #fn "\n\r"); \
            fn();                              \
            page_allocator_validate();         \
            term_prints("[ OK ] " #fn "\n\r"); \
        } while (0)


void test_single_alloc_free(void)
{
    mm_page p = page_malloc(0, UNINIT_PAGE);
    TEST_ASSERT(p.order == 0, "alloc order 0 failed");

    page_free(p.pa);
}

void test_split_to_zero(void)
{
    mm_page p = page_malloc(0, UNINIT_PAGE);
    TEST_ASSERT(p.order == 0, "split to order 0 failed");

    page_free(p.pa);
}

void test_many_small_allocs(void)
{
    mm_page pages[8];

    for (size_t i = 0; i < 8; i++) {
        pages[i] = page_malloc(0, UNINIT_PAGE);
        TEST_ASSERT(pages[i].order == 0, "small alloc failed");
    }

    for (size_t i = 0; i < 8; i++)
        page_free(pages[i].pa);
}

void test_mixed_orders(void)
{
    mm_page big = page_malloc(4, UNINIT_PAGE);
    TEST_ASSERT(big.order == 4, "big alloc failed");

    mm_page a = page_malloc(0, UNINIT_PAGE);
    mm_page b = page_malloc(0, UNINIT_PAGE);

    page_free(a.pa);
    page_free(b.pa);
    page_free(big.pa);
}

void test_full_merge(void)
{
    mm_page pages[64];

    for (size_t i = 0; i < 64; i++)
        pages[i] = page_malloc(0, UNINIT_PAGE);

    for (size_t i = 0; i < 64; i++)
        page_free(pages[i].pa);

    mm_page p = page_malloc(PAGE_ALLOCATOR_DEBUG_MAX_ORDER, UNINIT_PAGE);
    TEST_ASSERT(p.order == PAGE_ALLOCATOR_DEBUG_MAX_ORDER, "full merge failed");

    page_free(p.pa);
}


void test_stress_pattern(void)
{
    mm_page a[16];

    for (size_t i = 0; i < 16; i++)
        a[i] = page_malloc(i % 3, UNINIT_PAGE);

    for (size_t i = 0; i < 16; i += 2)
        page_free(a[i].pa);

    for (size_t i = 1; i < 16; i += 2)
        page_free(a[i].pa);
}


void run_page_allocator_tests(void)
{
    RUN_TEST(test_single_alloc_free);
    RUN_TEST(test_split_to_zero);
    RUN_TEST(test_many_small_allocs);
    RUN_TEST(test_mixed_orders);
    RUN_TEST(test_full_merge);
    RUN_TEST(test_stress_pattern);
}

#endif