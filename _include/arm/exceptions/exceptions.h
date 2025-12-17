#pragma once

#include <lib/stdbool.h>

typedef struct {
	bool fiq;
	bool irq;
	bool serror;
	bool debug;
} EXCEPTION_STATUS;

/// true means enabled
EXCEPTION_STATUS exceptions_get_status();

/// true means enable, false disable
void exceptions_set_status(EXCEPTION_STATUS status);

/// Enables exceptions on true. If a param is false, the current state of the
/// exception will be mantained, not disabled.
void exceptions_enable(bool fiq, bool irq, bool serror, bool debug);

/// Disables exceptions on true. If a param is false, the current state of the
/// exception will be mantained, not enabled.
void exceptions_disable(bool fiq, bool irq, bool serror, bool debug);
