#include "IPhreeqcPhast.h"
#define protected public
#include "Phreeqc.h"
#undef protected

#include <assert.h>
std::map<size_t, IPhreeqcPhast*> IPhreeqcPhast::PhastInstances;
size_t IPhreeqcPhast::PhastInstancesIndex = 0;

IPhreeqcPhast::IPhreeqcPhast(void)
{
	std::map<size_t, IPhreeqcPhast*>::value_type instance(this->Index, this);
	//std::pair<std::map<size_t, IPhreeqcPhast*>::iterator, bool> pr = IPhreeqcPhast::PhastInstances.insert(instance);
	IPhreeqcPhast::PhastInstances.insert(instance);
}
IPhreeqcPhast::~IPhreeqcPhast(void)
{
}
/* ---------------------------------------------------------------------- */
double
IPhreeqcPhast::Get_gfw(std::string formula)
/* ---------------------------------------------------------------------- */
{
	double gfw;
	this->Get_PhreeqcPtr()->compute_gfw(formula.c_str(), &gfw);
	return gfw;
}
/* ---------------------------------------------------------------------- */
void
IPhreeqcPhast::Set_cell_volumes(int i, double pore_volume, double f, double v)
/* ---------------------------------------------------------------------- */
{
	Phreeqc * phreeqc_ptr = this->Get_PhreeqcPtr();

	phreeqc_ptr->cell_no = i;
	phreeqc_ptr->cell_pore_volume = pore_volume * 1000.0 * f;
	phreeqc_ptr->cell_volume = v * 1000.;
	phreeqc_ptr->cell_porosity = phreeqc_ptr->cell_pore_volume /phreeqc_ptr-> cell_volume;
	phreeqc_ptr->cell_saturation = f;
}
/* ---------------------------------------------------------------------- */
bool
IPhreeqcPhast::Selected_out_to_double(int row, std::vector<double> d)
/* ---------------------------------------------------------------------- */
{
	int rows = this->GetSelectedOutputRowCount();
	bool rv = false;
	if (row < rows)
	{
		rv = true;
		int columns = this->GetSelectedOutputColumnCount();
		int column;
		for (column = 0; column != columns; column++)
		{
			VAR v;
			if (this->GetSelectedOutputValue((int) row, column, &v))
			{
				switch (v.type)
				{
				case TT_LONG:
					d.push_back(v.lVal);
					break;
				case TT_DOUBLE:
					d.push_back(v.dVal);
					break;
				default:
					d.push_back(0.0);
					break;
				}
			}
			else
			{
				d.push_back(0.0);
				rv = false;
			}
		}
	}
	return rv;
}
/* ---------------------------------------------------------------------- */
void
IPhreeqcPhast::Set_cell(cxxStorageBin & sb, int i)
/* ---------------------------------------------------------------------- */
{
	Phreeqc * phreeqc_ptr = this->Get_PhreeqcPtr();
	phreeqc_ptr->cxxStorageBin2phreeqc(sb, i);
}
/* ---------------------------------------------------------------------- */
void
IPhreeqcPhast::Get_cell(cxxStorageBin & sb, int i)
/* ---------------------------------------------------------------------- */
{
	//Phreeqc * phreeqc_ptr = this->Get_PhreeqcPtr();
	Phreeqc * phreeqc_ptr = this->PhreeqcPtr;
	phreeqc_ptr->phreeqc2cxxStorageBin(sb, i);
}
