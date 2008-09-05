#if !defined(ZONE_BUDGET_H_INCLUDED)
#define ZONE_BUDGET_H_INCLUDED
#include "Polyhedron.h"
#include <map>

class Zone_budget
{
public:
	Zone_budget(void);
public:
	virtual ~Zone_budget(void);

	void              Set_n_user(int i) {this->n_user = i;};
	int               Get_n_user(void)  {return this->n_user;};

	void              Set_description(char *desc) {this->description.clear(); this->description.append(desc);};
	std::string &     Get_description(void)       {return this->description;}

	void              Set_polyh(Polyhedron *p)    {this->polyh = p;};
	Polyhedron *      Get_polyh(void)             {return this->polyh;};

	std::vector<int> & Get_combo(void)            {return this->combo;};

	//bool               Add_cells(std::vector<int> &cells_in_budget, int nxyz, std::vector<Point> *cell_xyz);
	bool               Add_cells(std::vector<int> &cells_in_budget, zone *z, int nxyz, std::vector<Point> *cell_xyz);

protected:
	int               n_user;
	std::string       description;
	Polyhedron *      polyh;
	std::vector<int>  combo;

public:
	static std::map<int, Zone_budget *> zone_budget_map;
};
#endif // !defined(ZONE_BUDGET_H_INCLUDED)
