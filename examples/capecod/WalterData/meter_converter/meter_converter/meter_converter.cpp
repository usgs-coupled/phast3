// meter_converter.cpp : Defines the entry point for the console application.
//
#include <stdio>
#include "stdafx.h"
#include <iostream>				// std::cout std::cerr
//#include <strstream>
#include <sstream>
#include <fstream>

int _tmain(int argc, _TCHAR* argv[])
{
	double xmin, xmax, ymin, ymax;
	xmin = 275000;
	xmax = 285000;
	ymin = 810000;
	ymax = 830000;


	// process heads
	{
		std::ifstream walter("../heads.walter");
		std::ifstream phast("../heads.phast");
		std::ofstream ostrm("../heads.diff");
		std::cerr << "\nStart processing heads." << std::endl;
		double x_walter, y_walter, z_walter, t_walter, v_walter;
		double x_phast, y_phast, z_phast, t_phast, v_phast;
		int flag_walter, flag_phast;
		std::string(line);

		std::getline(walter, line);
		std::getline(phast, line);


		while (walter >> x_walter && phast >> x_phast)
		{
			walter >> y_walter;
			walter >> z_walter;
			walter >> t_walter;
			walter >> flag_walter;
			if (flag_walter > 0) walter>> v_walter;

			phast >> y_phast;
			phast >> z_phast;
			phast >> t_phast;
			phast >> flag_phast;

			if (flag_phast > 0) phast>> v_phast;

			if (x_walter != x_phast || y_walter != y_phast || z_walter != z_phast)
			{
				std::cerr << "x, y, and z not equal." << std::endl;
				std::cerr << "\twalter: " << x_walter << "\t" << y_walter << "\t"  << x_walter << std::endl;
				std::cerr << "\tphast : " << x_phast << "\t" << y_phast << "\t"  << x_phast << std::endl;
				exit(4);
			}
			if (flag_walter > 0 && flag_phast > 0)
			{
				double d;
				d = v_walter - v_phast;
				ostrm << x_walter << "\t" << y_walter << "\t" << z_walter << "\t"  << d << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing heads." << std::endl;
	}
	exit(0);




	// process bedrock_pts 
	{
		std::ifstream istrm("bedrock_pts");
		std::ofstream ostrm("bedrock_meters");
		std::cerr << "\nStart processing bedrock_pts." << std::endl;
		double x, y, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != -99.90) 
			{
				ostrm << x << "\t" << y << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing bedrock_pts." << std::endl;
	}
	// process drains_pts 
	{
		std::ifstream istrm("drains_pts");
		std::ofstream ostrm("drains_meters");
		std::cerr << "\nStart processing drains_pts." << std::endl;
		double x, y, v, dummy;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> v;
			istrm >> dummy;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			ostrm << x << "\t" << y << "\t" << 0 << "\t" << v*0.3048 << std::endl;
		}
		ostrm.close();
		std::cerr << "Finished processing drains_pts." << std::endl;
	}
	// process head_all_pts 
	{
		std::ifstream istrm("head_all_pts");
		std::ofstream ostrm("head_all_meters");
		std::cerr << "\nStart processing head_all_pts." << std::endl;
		double x, y, z, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> z;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != 888.00)
			{
				ostrm << x << "\t" << y << "\t" << z*0.3048 << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing head_all_pts." << std::endl;
	}
	// process head_pts 
	{
		std::ifstream istrm("head_pts");
		std::ofstream ostrm("head_meters");
		std::cerr << "\nStart processing head_pts." << std::endl;
		double x, y, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != 888.00)
			{
				ostrm << x << "\t" << y << "\t" << 0 << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing head_pts." << std::endl;
	}
	// process kh_points 
	{
		std::ifstream istrm("kh_points");
		std::ofstream ostrm("kh_meters");
		std::cerr << "\nStart processing kh_points." << std::endl;
		double x, y, z, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> z;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			// remove low K for pond bottoms
			if (v > 10.0 && v < 10.1 && z > -20)
			{
				v = 100.1;
			}
			if (v != 0.00 && v < 1000.)
			{
				ostrm << x << "\t" << y << "\t" << z*0.3048 << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing kh_points." << std::endl;
	}
	// process kz_points 
	{
		std::ifstream istrm("kz_points");
		std::ofstream ostrm("kz_meters");
		std::cerr << "\nStart processing kz_points." << std::endl;
		double x, y, z, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> z;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != 0.00 && v < 1000.)
			{

				ostrm << x << "\t" << y << "\t" << z*0.3048 << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing kz_points." << std::endl;
	}
	// process recharge_pts 
	{
		std::ifstream istrm("recharge_pts");
		std::ofstream ostrm("recharge_meters");
		std::cerr << "\nStart processing recharge_pts." << std::endl;
		double x, y, v;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> v;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != 0.0)
			{
				ostrm << x << "\t" << y << "\t" << 0 << "\t" << -v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing recharge_pts." << std::endl;
	}
	// process stream_pts 
	{
		std::ifstream istrm("streams_pts");
		std::ofstream ostrm("streams_meters");
		std::cerr << "\nStart processing streams_pts." << std::endl;
		double x, y, v, dummy;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> v;
			istrm >> dummy;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			if (v != 0.0)
			{
				ostrm << x << "\t" << y << "\t" << 0 << "\t" << v*0.3048 << std::endl;
			}
		}
		ostrm.close();
		std::cerr << "Finished processing streams_pts." << std::endl;
	}
	// process well_pts 
	{
		std::ifstream istrm("wells_pts");
		std::ofstream ostrm("wells_meters");
		std::cerr << "\nStart processing wells_pts." << std::endl;
		double x, y, z, v;
		double half_length = 10; // ft
		double diameter = 1; // ft 
		int i = 0;
		while (istrm >> x)
		{
			istrm >> y;
			istrm >> z;
			istrm >> v;
			i++;
			if (x < xmin || x > xmax ||	y < ymin || y > ymax) continue;
			ostrm << "Well " << i << std::endl;
			ostrm << "\t" << x << "\t" << y << std::endl;
			ostrm << "\t" << "-diameter\t" << diameter*.3048 << std::endl;
			ostrm << "\t" << "-solution\t" << std::endl;
			ostrm << "\t\t0\t1" << std::endl;
			ostrm << "\t" << "-elevation\t" << (z-half_length)*0.3048 << "\t" << (z+half_length)*0.3048 << std::endl;
			ostrm << "\t" << "-pumping_rate" << std::endl;
			ostrm << "\t\t" << 0 << "\t" << -v*0.3048*0.3048*0.3048 << std::endl; // NOTE: m^3/d
		}
		ostrm.close();
		std::cerr << "Finished processing wells_pts." << std::endl;
	}

	return 0;
}

