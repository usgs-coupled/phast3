#if !defined(ZONE_BUDGET_H_INCLUDED)
#define ZONE_BUDGET_H_INCLUDED
#include "Polyhedron.h"
#include <map>

#if defined(__WPHAST__)
class CArchive;
#include <hdf5.h>
#endif

class Zone_budget
{
  public:
	Zone_budget(void);
	Zone_budget(const Zone_budget& src);
  public:
	  virtual ~ Zone_budget(void);

	Zone_budget& operator=(const Zone_budget& rhs); 

	void Set_n_user(int i)
	{
		this->n_user = i;
	};
	int Get_n_user(void)const
	{
		return this->n_user;
	};

	void Set_description(const char *desc)
	{
		this->description = desc;
	};
	std::string Get_description(void)const
	{
		return this->description;
	}

	void Set_polyh(Polyhedron * p)
	{
		delete this->polyh;
		this->polyh = p;
	};
	Polyhedron *Get_polyh(void)
	{
		return this->polyh;
	};

	std::vector < int >&Get_combo(void)
	{
		return this->combo;
	};
	bool Get_write_heads(void)const
	{
		return this->write_heads;
	};
	void Set_write_heads(const bool tf)
	{
		this->write_heads = tf;
	};
	std::string Get_filename_heads(void)
	{
		return this->filename_heads;
	};
	void Set_filename_heads(const std::string t)
	{
		this->filename_heads = t;
	};

	//bool               Add_cells(std::vector<int> &cells_in_budget, int nxyz, std::vector<Point> *cell_xyz);
	bool Add_cells(std::vector < bool > &cells_in_budget, zone * z, int nxyz,
				   std::vector < Point > *cell_xyz) const;

	friend std::ostream& operator<< (std::ostream &os, const Zone_budget &a);

  protected:
	int n_user;
	std::string description;
	Polyhedron *polyh;
	std::vector < int >combo;
	bool write_heads;
	std::string filename_heads;

  public:
	static std::map < int, Zone_budget * >zone_budget_map;

#if defined(__WPHAST__)
	friend class CZoneFlowRateZoneActor;
	friend class CPropertyTreeControlBar;
	static unsigned short clipFormat;
	void Serialize(CArchive& ar);
	void Serialize(bool bStoring, hid_t loc_id);
#endif
};
#endif // !defined(ZONE_BUDGET_H_INCLUDED)
