#ifndef __wphast_h__
#define __wphast_h__

#if defined(__WPHAST__) && !defined(_DEBUG)
#include "../phqalloc.h"
#else
#ifdef _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
#endif
#endif

#endif /* __wphast_h__ */
