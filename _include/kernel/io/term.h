#pragma once


typedef enum {
    TERM_OUT_RES_OK = 0,
    TERM_OUT_RES_NOT_TAKEN = 1,
} term_out_result;

typedef char (*term_in)(void);
typedef term_out_result (*term_out)(const char c);


void init_term_early(term_out early_out);
void init_term_full();

void term_add_output(term_out out);
void term_remove_output(term_out out);

void term_add_input(term_in in);
void term_remove_input(term_in in);


/*
    Prints
*/
void term_printc(const char c);
void term_prints(const char* s);
void term_printf(const char* s, ...);