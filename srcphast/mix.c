#define EXTERNAL extern
#include "StorageBin.h"
#include "phreeqc/global.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/output.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"

extern cxxStorageBin szBin;
extern cxxStorageBin uzBin;

extern int mpi_myself;
static char const svnid[] = "$Id$";

/* ---------------------------------------------------------------------- */
int partition_uz(int iphrq, int ihst, LDBLE new_frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;
	LDBLE s1, s2, uz1, uz2;

	/* 
	 * repartition solids for partially saturated cells
	 */
	
	if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)  return(OK);

	n_user = iphrq;


	if (new_frac >= 1.0) {
		/* put everything in saturated zone */
		uz1 = 0;
		uz2 = 0;
		s1 = 1.0; 
		s2 = 1.0;
	} else if (new_frac <= 1e-10) {
		/* put everything in unsaturated zone */
		uz1 = 1.0;
		uz2 = 1.0;
		s1 = 0.0; 
		s2 = 0.0;
	} else if (new_frac > old_frac[ihst]) {
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac)/(1.0 - old_frac[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	} else {
		/* draining cell */
		s1 = new_frac/old_frac[ihst];
		s2 = 0.0;
		uz1 = 1.0 - s1;
		uz2 = 1.0;
	}
	cxxMix szmix, uzmix;
	szmix.add(0, s1);
	szmix.add(1, s2);
	uzmix.add(0, uz1);
	uzmix.add(1, uz2);
	/*
	 *   Calculate new compositions
	 */

//Exchange
	if (szBin.getExchange(n_user) != NULL) {
	  cxxStorageBin tempBin;
	  tempBin.setExchange(0,szBin.getExchange(n_user));
	  tempBin.setExchange(1,uzBin.getExchange(n_user));
	  cxxExchange newsz(tempBin.getExchangers(), szmix, n_user);
	  cxxExchange newuz(tempBin.getExchangers(), uzmix, n_user);
	  szBin.setExchange(n_user, &newsz);
	  uzBin.setExchange(n_user, &newuz);
	}
//PPassemblage
	if (szBin.getPPassemblage(n_user) != NULL) {
	  cxxStorageBin tempBin;
	  tempBin.setPPassemblage(0,szBin.getPPassemblage(n_user));
	  tempBin.setPPassemblage(1,uzBin.getPPassemblage(n_user));
	  cxxPPassemblage newsz(tempBin.getPPassemblages(), szmix, n_user);
	  cxxPPassemblage newuz(tempBin.getPPassemblages(), uzmix, n_user);
	  szBin.setPPassemblage(n_user, &newsz);
	  uzBin.setPPassemblage(n_user, &newuz);
	}
//Gas_phase
	if (szBin.getGasPhase(n_user) != NULL) {
	  cxxStorageBin tempBin;
	  tempBin.setGasPhase(0,szBin.getGasPhase(n_user));
	  tempBin.setGasPhase(1,uzBin.getGasPhase(n_user));
	  cxxGasPhase newsz(tempBin.getGasPhases(), szmix, n_user);
	  cxxGasPhase newuz(tempBin.getGasPhases(), uzmix, n_user);
	  szBin.setGasPhase(n_user, &newsz);
	  uzBin.setGasPhase(n_user, &newuz);
	}
//SSassemblage
	if (szBin.getSSassemblage(n_user) != NULL) 
	{
	  cxxStorageBin tempBin;
	  tempBin.setSSassemblage(0,szBin.getSSassemblage(n_user));
	  tempBin.setSSassemblage(1,uzBin.getSSassemblage(n_user));
	  cxxSSassemblage newsz(tempBin.getSSassemblages(), szmix, n_user);
	  cxxSSassemblage newuz(tempBin.getSSassemblages(), uzmix, n_user);
	  szBin.setSSassemblage(n_user, &newsz);
	  uzBin.setSSassemblage(n_user, &newuz);
	}
//Kinetics
	if (szBin.getKinetics(n_user) != NULL) 
	{
	  cxxStorageBin tempBin;
	  tempBin.setKinetics(0,szBin.getKinetics(n_user));
	  tempBin.setKinetics(1,uzBin.getKinetics(n_user));
	  cxxKinetics newsz(tempBin.getKinetics(), szmix, n_user);
	  cxxKinetics newuz(tempBin.getKinetics(), uzmix, n_user);
	  szBin.setKinetics(n_user, &newsz);
	  uzBin.setKinetics(n_user, &newuz);
	}
//Surface
	if (szBin.getSurface(n_user) != NULL) 
	{
	  cxxStorageBin tempBin;
	  tempBin.setSurface(0,szBin.getSurface(n_user));
	  tempBin.setSurface(1,uzBin.getSurface(n_user));
	  cxxSurface newsz(tempBin.getSurfaces(), szmix, n_user);
	  cxxSurface newuz(tempBin.getSurfaces(), uzmix, n_user);
	  szBin.setSurface(n_user, &newsz);
	  uzBin.setSurface(n_user, &newuz);
	}
	/*
	 *   Eliminate uz if new fraction 1.0
	 */
	if (new_frac >= 1.0) 
	{
		uzBin.remove(iphrq);
	} 

	old_frac[ihst] = new_frac;
	return(OK);
}
