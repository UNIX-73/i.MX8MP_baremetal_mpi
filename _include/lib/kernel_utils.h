#pragma once
#include <lib/stdint.h>

extern uint32 _currentEL();
#define currentEL() _currentEL()
