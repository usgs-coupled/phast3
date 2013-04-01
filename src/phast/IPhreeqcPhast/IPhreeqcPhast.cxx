#include "IPhreeqcPhast.h"
#include "Phreeqc.h"
#include "Solution.h"
#include "SelectedOutput.hxx"       // CSelectedOutput

#include <assert.h>
std::map<size_t, IPhreeqcPhast*> IPhreeqcPhast::PhastInstances;
size_t IPhreeqcPhast::PhastInstancesIndex = 0;

IPhreeqcPhast::IPhreeqcPhast(void)
{
	std::map<size_t, IPhreeqcPhast*>::value_type instance(this->Index, this);
	//std::pair<std::map<size_t, IPhreeqcPhast*>::iterator, bool> pr = IPhreeqcPhast::PhastInstances.insert(instance);
	IPhreeqcPhast::PhastInstances.insert(instance);
	//this->Get_PhreeqcPtr()->phast = true;
	
	//static size_t PhastInstancesIndex;
	//start_cell;
	//int end_cell;
	out_stream = NULL;
	punch_stream = NULL;
	this->thread_clock_time = 0;
	this->standard_clock_time = 1;
}
IPhreeqcPhast::~IPhreeqcPhast(void)
{
	std::map<size_t, IPhreeqcPhast*>::iterator it = IPhreeqcPhast::PhastInstances.find(this->Index);
	if (it != IPhreeqcPhast::PhastInstances.end())
	{
		IPhreeqcPhast::PhastInstances.erase(it);
	}
}
/* ---------------------------------------------------------------------- */
double
IPhreeqcPhast::Get_gfw(std::string formula)
/* ---------------------------------------------------------------------- */
{
	LDBLE gfw;
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
void
IPhreeqcPhast::Selected_out_to_double()
/* ---------------------------------------------------------------------- */
{
	const float INACTIVE_CELL_VALUE = 1.0e30f;

	int rows = this->GetSelectedOutputRowCount();
	int columns = this->GetSelectedOutputColumnCount();
	std::vector<LDBLE> d;

	if (rows >= 2) 
	{
		int row = 1;
		d.reserve(columns);
		for (int column = 0; column < columns; column++)
		{
			VAR v;
			VarInit(&v);
			//if (this->GetSelectedOutputValue(row, column, &v) == VR_OK)
			// following is much faster
			if (this->SelectedOutput->Get(row, column, &v) == VR_OK)
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
					d.push_back(INACTIVE_CELL_VALUE);
					break;
				}
			}
			else
			{
				d.push_back(INACTIVE_CELL_VALUE);
			}
		}
	}
	this->punch_vector.insert(punch_vector.end(),d.begin(),d.end());
}
/* ---------------------------------------------------------------------- */
void
IPhreeqcPhast::Get_cell_from_storage_bin(cxxStorageBin & sb, int i)
/* ---------------------------------------------------------------------- */
{
	Phreeqc * phreeqc_ptr = this->Get_PhreeqcPtr();
	phreeqc_ptr->cxxStorageBin2phreeqc(sb, i);
}
/* ---------------------------------------------------------------------- */
void
IPhreeqcPhast::Put_cell_in_storage_bin(cxxStorageBin & sb, int i)
/* ---------------------------------------------------------------------- */
{
	Phreeqc * phreeqc_ptr = this->PhreeqcPtr;
	phreeqc_ptr->phreeqc2cxxStorageBin(sb, i);
}
/* ---------------------------------------------------------------------- */
cxxSolution *
IPhreeqcPhast::Get_solution(int i)
/* ---------------------------------------------------------------------- */
{
	return Utilities::Rxn_find(this->PhreeqcPtr->Rxn_solution_map, i);
}
