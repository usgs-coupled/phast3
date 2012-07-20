#if !defined(PHAST_IPHREEQC_H_INCLUDED)
#define PHAST_IPHREEQC_H_INCLUDED
#include "PHRQ_base.h"
#include "StorageBin.h"
#include <vector>
#include <list>

class PHRQ_io;
#include "IPhreeqc.hpp"
class IPhreeqcPhast: public IPhreeqc
{
public:
	IPhreeqcPhast(void);
	~IPhreeqcPhast(void);
	double Get_gfw(std::string);
	void Set_cell_volumes(int i, double pore_volume, double f, double v);
	bool Selected_out_to_double(int row, std::vector<double> d);
	void Set_cell(cxxStorageBin & sb, int i);
	void Get_cell(cxxStorageBin & sb, int i);
	Phreeqc * Get_PhreeqcPtr(void) {return PhreeqcPtr;};
	size_t Get_Index() {return (int) this->Index;}

protected:
	friend class IPhreeqcPhastLib;
	static std::map<size_t, IPhreeqcPhast*> PhastInstances;
	static size_t PhastInstancesIndex;
};
#endif // !defined(PHAST_IPHREEQC_H_INCLUDED)
