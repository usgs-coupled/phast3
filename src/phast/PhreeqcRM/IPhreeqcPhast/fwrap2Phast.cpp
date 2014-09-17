#include "IPhreeqc.h"
#include "fwrapPhast.h"

#if defined(_WIN32)


#if defined(__cplusplus)
extern "C" {
#endif

//
// Intel Fortran compiler 9.1 /iface:cvf
//

IPQ_DLL_EXPORT int  CREATEIPHREEQCPHAST(void)
{
	return CreateIPhreeqcPhastF();
}
IPQ_DLL_EXPORT int  DESTROYIPHREEQCPHAST(int *id)
{
	return DestroyIPhreeqcPhastF(id);
}

#if defined(__cplusplus)
}
#endif

#endif