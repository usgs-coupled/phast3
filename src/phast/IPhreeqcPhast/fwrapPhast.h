#ifndef __FWRAPPHAST__H
#define __FWRAPPHAST__H
#include "IPhreeqcPhastLib.h"
#if defined(_WINDLL)
#define IPQ_DLL_EXPORT __declspec(dllexport)
#else
#define IPQ_DLL_EXPORT
#endif

#if defined(FC_FUNC)

#define CreateIPhreeqcF                   FC_FUNC (createiphreeqcf,                   CREATEIPHREEQCF)
#define DestroyIPhreeqcF                  FC_FUNC (destroyiphreeqcf,                  DESTROYIPHREEQCF)

#endif /* FC_FUNC */

#if defined(__cplusplus)
extern "C" {
#endif

  int        CreateIPhreeqcPhastF(void);
  int        DestroyIPhreeqcPhastF(int *id);

#if defined(__cplusplus)
}
#endif

#endif  /* __FWRAPPHAST__H */
