#include <ctype.h>   /* isgraph */
#include <stdlib.h>  /* malloc */
#include <memory.h>  /* memcpy */
#include <assert.h>  /* assert */
#include <stdio.h>   /* sprintf */
#include "phrqtype.h"
#include "IPhreeqc.h"
#include "IPhreeqcPhast.h"
#include "fwrapPhast.h"

int
CreateIPhreeqcPhastF(void)
{
	return IPhreeqcPhastLib::CreateIPhreeqcPhast();
}

int
DestroyIPhreeqcPhastF(int *id)
{
	return IPhreeqcPhastLib::DestroyIPhreeqcPhast(*id);
}

#if defined(_WIN32) && !defined(_M_AMD64)

#if defined(__cplusplus)
extern "C" {
#endif

//
// Intel Fortran compiler 9.1 /iface:cvf
//

IPQ_DLL_EXPORT int  __stdcall CREATEIPHREEQCPHAST(void)
{
	return CreateIPhreeqcPhastF();
}
IPQ_DLL_EXPORT int  __stdcall DESTROYIPHREEQCPHAST(int *id)
{
	return DestroyIPhreeqcPhastF(id);
}

#if defined(__cplusplus)
}
#endif

#endif // _WIN32

