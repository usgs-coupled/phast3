#include "IPhreeqc.h"
#include "fwrapPhast.h"

#if defined(_WIN32) && !defined(_M_AMD64)

#if defined(__cplusplus)
extern "C" {
#endif

//
// Intel Fortran compiler 9.1 /iface:cvf
// Intel Fortran compiler 9.1 /iface:stdref /names:uppercase /assume:underscore
//

IPQ_DLL_EXPORT int  __stdcall CREATEIPHREEQCPHAST_(void)
{
	return CreateIPhreeqcPhastF();
}
IPQ_DLL_EXPORT int  __stdcall DESTROYIPHREEQCPHAST_(int *id)
{
	return DestroyIPhreeqcPhastF(id);
}

#if defined(__cplusplus)
}
#endif

#endif // _WIN32

