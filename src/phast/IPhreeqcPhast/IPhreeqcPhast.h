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
	void Get_cell_from_storage_bin(cxxStorageBin & sb, int i);
	void Put_cell_in_storage_bin(cxxStorageBin & sb, int i);
	Phreeqc * Get_PhreeqcPtr(void) {return PhreeqcPtr;};
	size_t Get_Index() {return (int) this->Index;}
	cxxSolution *Get_solution(int n_user);
	void Set_out_stream(std::ostringstream *s) {this->out_stream = s;}
	void Set_dump_stream(std::ostringstream *s) {this->dump_stream = s;}
	void Set_punch_stream(std::ostringstream *s) {this->punch_stream = s;}	
	std::ostringstream & Get_out_stream(void) {return *this->out_stream;}
	std::ostringstream & Get_dump_stream(void) {return *this->dump_stream;}
	std::ostringstream & Get_punch_stream(void) {return *this->punch_stream;}

protected:
	friend class IPhreeqcPhastLib;
	static std::map<size_t, IPhreeqcPhast*> PhastInstances;
	static size_t PhastInstancesIndex;

	// Data members
	int start_cell;
	int end_cell;
	std::ostringstream * out_stream;
	std::ostringstream * dump_stream;
	std::ostringstream * punch_stream;
	std::vector < std::vector< LDBLE > > punch_vector;
	std::vector<LDBLE> d_values;

};
#endif // !defined(PHAST_IPHREEQC_H_INCLUDED)
