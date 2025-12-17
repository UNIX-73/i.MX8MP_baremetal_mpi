#pragma once

#include <lib/stdint.h>

uint64 _currentEL();

#define currentEL() _currentEL()
