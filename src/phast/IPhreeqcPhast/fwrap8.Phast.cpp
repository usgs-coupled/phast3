#include "IPhreeqc.h"
#include "fwrapPhast.h"

#if defined(_WIN32) && !defined(_M_AMD64)

#if defined(__cplusplus)
extern "C" {
#endif

//
// Intel Fortran compiler 9.1 /iface:stdref /names:lowercase
//

IPQ_DLL_EXPORT int  __stdcall createiphreeqcphast(void)
{
	return CreateIPhreeqcPhastF();
}
IPQ_DLL_EXPORT int  __stdcall destroyiphreeqcphast(int *id)
{
	return DestroyIPhreeqcPhastF(id);
}

#if defined(__cplusplus)
}
#endif

#endif // _WIN32

