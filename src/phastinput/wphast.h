#ifndef __wphast_h__
#define __wphast_h__

#if defined(__WPHAST__) && !defined(_DEBUG)
#include "../phqalloc.h"
#else
#ifdef _DEBUG
// COMMENT: {8/13/2015 9:04:12 PM}#define _CRTDBG_MAP_ALLOC (SET IN PROJECT SETTINGS)
#include <crtdbg.h>
#endif
#endif

#endif /* __wphast_h__ */
