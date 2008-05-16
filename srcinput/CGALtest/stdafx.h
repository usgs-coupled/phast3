// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once


#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
#include <stdio.h>
#include <tchar.h>

// TODO: reference additional headers your program requires here
#include <CGAL/basic.h>
#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
#include <CGAL/Polyhedron_3.h>
#include <CGAL/Nef_polyhedron_3.h>
#include <CGAL/IO/Nef_polyhedron_iostream_3.h>
#include <CGAL/Nef_3/Polygon_constructor.h>

// QT includes
#include <CGAL/IO/Qt_widget_Nef_3.h>
#include <qapplication.h>

// Kernal, suggested for doubles
typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;

// Typedefs
typedef CGAL::Polyhedron_3<Kernel>         Polyhedron;
typedef Polyhedron::Plane_3                Plane_3;
typedef Polyhedron::Point_3                Point_3;
typedef CGAL::Nef_polyhedron_3<Kernel>     Nef_polyhedron;

typedef Point_3* point_iterator;
typedef std::pair<point_iterator,point_iterator> point_range;
typedef std::list<point_range> polygon;
typedef polygon::const_iterator polygon_iterator;
typedef CGAL::Polygon_constructor<Nef_polyhedron, polygon_iterator> Polygon_constructor;
