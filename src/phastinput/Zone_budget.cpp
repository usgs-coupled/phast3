#include "Zone_budget.h"
#include "message.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

std::map < int,
Zone_budget * >
	Zone_budget::zone_budget_map;
Zone_budget::Zone_budget(void)
{
	this->n_user = 0;
	this->polyh = NULL;
	this->write_heads = false;
}

Zone_budget::Zone_budget(const Zone_budget& src)
: n_user(src.n_user)
, description(src.description)
, polyh(0)
, combo(src.combo)
, write_heads(src.write_heads)
, filename_heads(src.filename_heads)
{
	if (src.polyh)
	{
		this->polyh = src.polyh->clone();
	}
}

Zone_budget& Zone_budget::operator=(const Zone_budget& rhs)
{
	if (this != &rhs)
	{
		this->n_user = rhs.n_user;
		this->description = rhs.description;
		delete this->polyh;
		this->polyh = 0;
		if (rhs.polyh)
		{
			this->polyh = rhs.polyh->clone();
		}
		this->combo = rhs.combo;
		this->write_heads = rhs.write_heads;
		this->filename_heads = rhs.filename_heads;
	}
	return *this;
}

Zone_budget::~Zone_budget(void)
{
	delete this->polyh;
}

bool Zone_budget::Add_cells(std::vector < bool > &cells_in_budget, zone * z,
							int nxyz, std::vector < Point > *cell_xyz)
{

	if (this->polyh != NULL)
	{

		// Update zone
		std::vector < Point > p;
		if (z->zone_defined)
		{
			p.push_back(Point(z->x1, z->y1, z->z1));
			p.push_back(Point(z->x2, z->y2, z->z2));
		}
		else
		{
			z->zone_defined = 1;
		}

		zone
		z1(this->polyh->Get_bounding_box());
		p.push_back(Point(z1.x1, z1.y1, z1.z1));
		p.push_back(Point(z1.x2, z1.y2, z1.z2));
		Point
		min(p.begin(), p.end(), Point::MIN);
		Point
		max(p.begin(), p.end(), Point::MAX);
		z->x1 = min.x();
		z->y1 = min.y();
		z->z1 = min.z();
		z->x2 = max.x();
		z->y2 = max.y();
		z->z2 = max.z();

		// Put all cells in list, avoids having to include range definitions from hstinpt.h
		// Some cells should be eliminated easily by zone check in Points_in_polyhedron
		std::list < int >
			list_of_cells;
		int
			i;
		for (i = 0; i < nxyz; i++)
		{
			list_of_cells.push_back(i);
		}

		// Find cells in polyhedron
		this->polyh->Points_in_polyhedron(list_of_cells, *cell_xyz);
		if (list_of_cells.size() == 0)
		{
			error_msg("Bad zone or wedge definition for Zone_budget",
					  EA_CONTINUE);
			return (false);
		}

		// Put cells in master list
		std::list < int >::iterator
			lit;
		for (lit = list_of_cells.begin(); lit != list_of_cells.end(); lit++)
		{
			cells_in_budget[*lit] = 1;
		}
	}
	if (this->combo.size() > 0)
	{
		std::vector < int >::iterator
			it;
		for (it = this->combo.begin(); it != this->combo.end(); it++)
		{
			std::map < int,
			Zone_budget * >::iterator
				zbit;
			zbit = Zone_budget::zone_budget_map.find(*it);
			if (zbit != Zone_budget::zone_budget_map.end())
			{
				zbit->second->Add_cells(cells_in_budget, z, nxyz, cell_xyz);
			}
			else
			{
				std::ostringstream estring;
				estring << "Could not find budget zone " << *it <<
					" included in budget zone " << this->n_user << std::endl;
				error_msg(estring.str().c_str(), EA_CONTINUE);
				return false;
			}
		}
	}
	return true;
}

std::ostream& operator<< (std::ostream &os, const Zone_budget &a)
{
	os << "ZONE_FLOW_RATES " << a.n_user << " " << a.description << "\n";
	if (a.combo.size())
	{
		os << "\t-combination";
		std::vector<int>::const_iterator cit = a.combo.begin();
		for (; cit != a.combo.end(); ++cit)
		{
			os << "    " << (*cit);
		}
		os << "\n";
	}
	os << *a.polyh;
	return os;
}
