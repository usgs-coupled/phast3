#include <cassert>
#include <iostream>
#include <map>

#include "IPhreeqc.h"
#include "IPhreeqc.hpp"
#include "IPhreeqcPhast.h"
#include "IPhreeqcPhastLib.h"
//#define CreateIPhreeqcPhast          createiphreeqcphast
//class IPhreeqcPhastLib
//{
//public:
//	static int CreateIPhreeqcPhast(void);
//	static IPQ_RESULT DestroyIPhreeqcPhast(int n);
//	static IPhreeqcPhast* GetInstance(int n);
//};


// helper functions
//

int
IPhreeqcPhastLib::CreateIPhreeqcPhast(void)
{
	int n = IPQ_OUTOFMEMORY;
	IPhreeqcPhast* IPhreeqcPhastPtr;
	try
	{
		#pragma omp critical(IPhreeqcPhastLib)
		{
			IPhreeqcPhastPtr = new IPhreeqcPhast;
		}
		n = IPhreeqcPhastPtr->Index;
	}
	catch(...)
	{
		return IPQ_OUTOFMEMORY;
	}
	
	return n;
}

IPQ_RESULT
IPhreeqcPhastLib::DestroyIPhreeqcPhast(int id)
{
	IPQ_RESULT retval = IPQ_BADINSTANCE;
	if (id >= 0)
	{
		if (IPhreeqc *ptr = IPhreeqcPhastLib::GetInstance(id))
		{
			#pragma omp critical(IPhreeqcPhastLib)
			{
				delete ptr;
			}
				retval = IPQ_OK;
		}
	}
	return retval;
}

IPhreeqcPhast*
IPhreeqcPhastLib::GetInstance(int id)
{
	std::map<size_t, IPhreeqcPhast*>::iterator it;
	bool found=false;
	#pragma omp critical(IPhreeqcLib)
	{
		it = IPhreeqcPhast::PhastInstances.find(size_t(id));
		found = (it != IPhreeqcPhast::PhastInstances.end());
	}
	if (found)
	{
		return (*it).second;
	}
	return 0;
}
