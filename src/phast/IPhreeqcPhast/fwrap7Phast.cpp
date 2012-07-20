#include "IPhreeqc.h"
#include "fwrapPhast.h"

#if defined(_WIN32) && !defined(_M_AMD64)

#if defined(__cplusplus)
extern "C" {
#endif

//
// Intel Fortran compiler 9.1 /iface:stdref /names:lowercase /assume:underscore
//

IPQ_DLL_EXPORT int  __stdcall createiphreeqcphast_(void)
{
	return CreateIPhreeqcPhastF();
}
IPQ_DLL_EXPORT int  __stdcall destroyiphreeqcphast_(int *id)
{
	return DestroyIPhreeqcPhastF(id);
}

#if defined(__cplusplus)
}
#endif

#endif // _WIN32

