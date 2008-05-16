#include "stdafx.h"
//**#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
//#include <CGAL/Exact_predicates_exact_constructions_kernel_with_sqrt.h>
//#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
//#include <CGAL/Gmpq.h>
//#include <CGAL/Cartesian.h>
//#include <CGAL/Extended_homogeneous.h>

//**#include <CGAL/Polyhedron_3.h>
//**#include <CGAL/Nef_polyhedron_3.h>

//**typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;
//typedef CGAL::Exact_predicates_exact_constructions_kernel_with_sqrt Kernel;
//typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
//typedef CGAL::Cartesian<CGAL::Gmpq> Kernel;
//typedef CGAL::Extended_homogeneous<CGAL::Gmpz>  Kernel;
//**typedef CGAL::Polyhedron_3<Kernel>         Polyhedron;
//**typedef Polyhedron::Plane_3                Plane_3;
//**typedef Polyhedron::Point_3                Point_3;
//**typedef CGAL::Nef_polyhedron_3<Kernel>     Nef_polyhedron;

// from polygon_construction
//**#include <CGAL/IO/Nef_polyhedron_iostream_3.h>
//**#include <CGAL/Nef_3/Polygon_constructor.h>
//typedef Kernel::Point_3 Point_3;
//**typedef Point_3* point_iterator;
//**typedef std::pair<point_iterator,point_iterator> point_range;
//**typedef std::list<point_range> polygon;
//**typedef polygon::const_iterator polygon_iterator;
//**typedef CGAL::Polygon_constructor<Nef_polyhedron, polygon_iterator> Polygon_constructor;

void parse_locate(Nef_polyhedron &N1, Point_3 &p);
void triangle_2_to_nef_prism(Nef_polyhedron &N, Point_3 *P, double top, double bottom);
void triangle_3_to_nef_prism(Nef_polyhedron &N, Point_3 *P, double cut, bool fill_up);
void make_tet(Nef_polyhedron &N, Point_3 &min, Point_3 &max);
int main (int argc, char* argv[])
{

  Point_3 p0[4] = {Point_3(0,.5,0), Point_3(1,.5,0),
		   Point_3(1,.5,1), Point_3(0,.5,1)};
  polygon poly;
  poly.push_back(point_range(p0,p0+4));
  Nef_polyhedron Rectangle;
  Polygon_constructor pc(poly.begin(), poly.end());
  Rectangle.delegate(pc,true);

  Nef_polyhedron C;


  //std::cout << N;


  Point_3 p1[3] = {Point_3(0,0,0), Point_3(1,0,0),
		  Point_3(0,1,0)};
  Nef_polyhedron wedge1;
  triangle_2_to_nef_prism(wedge1, p1, 1.0, 0.0);

  Point_3 p2[3] = {Point_3(0,0,0), Point_3(1,0,0),
		  Point_3(1,1,0)};
  Nef_polyhedron wedge2;
  triangle_2_to_nef_prism(wedge2, p2, 1.0, 0.0);

  Nef_polyhedron U = wedge1 + wedge2;
  //std::cout << U;

  Nef_polyhedron R1, R2;
  p1[0] = Point_3(0.0, 0.0, 0.5);
  p1[1] = Point_3(0.5, 0.5, 0.75);
  p1[2] = Point_3(0.0, 1.0, 0.5);
  triangle_3_to_nef_prism(R1, p1, 2.0, true);

  Nef_polyhedron Cut = U - R1;
  //Nef_polyhedron Final = (Cut.intersection(Rectangle)).closure();
  Nef_polyhedron Final = Cut;
  //std::cout << Final;

  //Nef_polyhedron Final;
  //make_tet(Final, Point_3(0, 0, 0), Point_3(1, 1, 1));
  //Final = Final * Rectangle;

  std::cout << Final;
  //parse_locate(wedge, Point_3(.25, .25, .25));
  //parse_locate(wedge, Point_3(-1, -1, -1));

  QApplication a(argc, argv);
  CGAL::Qt_widget_Nef_3<Nef_polyhedron>* w =
    new CGAL::Qt_widget_Nef_3<Nef_polyhedron>(Final);
  a.setMainWidget(w);
  w->show();
  return a.exec();

}
void write_faces(Nef_polyhedron &N)
{

}
void make_tet(Nef_polyhedron &N, Point_3 &min, Point_3 &max)
{
  Point_3 p0[4];
  Polyhedron All;
  Nef_polyhedron f1, f2, f3, f4;

  p0[0] = Point_3(min.x(), min.y(), min.z());
  p0[1] = Point_3(max.x(), min.y(), min.z());
  p0[2] = Point_3(max.x(), max.y(), min.z());
  p0[3] = Point_3(min.x(), min.y(), max.z());
#ifdef SKIP
  //polygon poly;
  //poly.push_back(point_range(p0,p0+3));
  //Polygon_constructor pc1(poly.begin(), poly.end());
  All.make_triangle(p0[1], p0[2], p0[3]);
  //f1.delegate(pc1, true);
  std::cerr << "Added triangle 1" << std::endl;


  Point_3 f[3];
  f[0] = p0[3];
  f[1] = p0[2];
  f[2] = p0[0];
  //poly.clear();
  //poly.push_back(point_range(f,f+3));
  //Polygon_constructor pc2(poly.begin(), poly.end());
  //f2.delegate(pc2, true);
  All.make_triangle(p0[3],p0[2], p0[0]);
  std::cerr << "Added triangle 2" << std::endl;
  All.make_triangle(p0[1], p0[2], p0[3]);

  f[0] = p0[0];
  f[1] = p0[2];
  f[2] = p0[1];
  //poly.clear();
  //poly.push_back(point_range(f,f+3));
  //Polygon_constructor pc3(poly.begin(), poly.end());
  //f3.delegate(pc3, true);
  All.make_triangle(p0[2],p0[1], p0[0]);
  std::cerr << "Added triangle 3" << std::endl;

  f[0] = p0[0];
  f[1] = p0[2];
  f[2] = p0[3];
  //poly.clear();
  //poly.push_back(point_range(f,f+3));
  //Polygon_constructor pc4(poly.begin(), poly.end());
  //f4.delegate(pc4, true);
  //All.make_triangle(f[0],f[1], f[2]);
  std::cerr << "Added triangle 4" << std::endl;
#endif
  All.make_triangle(p0[1], p0[2], p0[3]);
  All.make_triangle(p0[1], p0[2], p0[3]);
  All.make_triangle(p0[1], p0[2], p0[3]);
  std::cerr << "Valid? " << All.is_valid(true, 1) << std::endl;
  std::cerr << "Border valid? " << All.normalized_border_is_valid(true) << std::endl;
  std::cerr << "Closed? " << All.is_closed() << std::endl;

  N.clear();
  std::cerr << "Cleared" << std::endl;
  //Polygon_constructor pc(poly.begin(), poly.end());
  //N.delegate(pc,true);
  Nef_polyhedron NP = Nef_polyhedron(All);
  N = NP;
  std::cerr << "Nef made" << std::endl;

}
void triangle_2_to_nef_prism(Nef_polyhedron &N, Point_3 *P, double top, double bottom)
{

  Point_3 p0 = Point_3(P[0].x(), P[0].y(), bottom);
  Point_3 p1 = Point_3(P[1].x(), P[1].y(), bottom);
  Point_3 p2 = Point_3(P[2].x(), P[2].y(), bottom);
  Point_3 p3 = Point_3(P[0].x(), P[0].y(), top);
  Point_3 p4 = Point_3(P[1].x(), P[1].y(), top);
  Point_3 p5 = Point_3(P[2].x(), P[2].y(), top);

  Polyhedron P1, P2, P3;
  P1.make_tetrahedron(p0, p1, p2, p3);
  P2.make_tetrahedron(p1, p3, p2, p4);
  P3.make_tetrahedron(p3, p2, p4, p5);

  Nef_polyhedron N1(P1), N2(P2), N3(P3);

  N = N1 + N2 + N3;
  N.closure();
  bool tf;
  tf = N.is_simple();
  tf = N.is_valid();
  tf = N.is_empty();
  tf = N.is_space();
  int n = (int) N.number_of_vertices();
}

void triangle_3_to_nef_prism(Nef_polyhedron &N, Point_3 *P, double cut, bool fill_up)
{

  Point_3 p0 = P[0];
  Point_3 p1 = P[1];
  Point_3 p2 = P[2];

  Point_3 c(cut,cut,cut);
  int i;
  if (fill_up)
  {
    for (i = 0; i < 3; i++)
    {
      // don't know how to convert to double
      if (P[i].z() > c.z()) c = Point_3(P[i].z(), P[i].z(), P[i].z());
    }
  } else
  {
    for (i = 0; i < 3; i++)
    {
      // don't know how to convert to double
      if (P[i].z() < c.z()) c = Point_3(P[i].z(), P[i].z(), P[i].z());
    }
  }

  Point_3 p3 = Point_3(P[0].x(), P[0].y(), c.z());
  Point_3 p4 = Point_3(P[1].x(), P[1].y(), c.z());
  Point_3 p5 = Point_3(P[2].x(), P[2].y(), c.z());

  Polyhedron P1, P2, P3;
  P1.make_tetrahedron(p0, p1, p2, p3);
  P2.make_tetrahedron(p1, p3, p2, p4);
  P3.make_tetrahedron(p3, p2, p4, p5);

  Nef_polyhedron N1(P1), N2(P2), N3(P3);

  N = N1 + N2 + N3;
  N.closure();
  bool tf;
  tf = N.is_simple();
  tf = N.is_valid();
  tf = N.is_empty();
  tf = N.is_space();
  int n = (int) N.number_of_vertices();
}
void parse_locate(Nef_polyhedron &N1, Point_3 &p)
{
   Nef_polyhedron::Object_handle n = N1.locate(p);
   Nef_polyhedron::Vertex_const_handle v_handle;
   Nef_polyhedron::Halfedge_const_handle e_handle;
   Nef_polyhedron::Halffacet_const_handle f_handle;
   Nef_polyhedron::Volume_const_handle vol_handle_1, vol_handle_2;
   bool type;
   if (type =  assign(v_handle, n))
   {
     std::cout << "Point is a vertex." << std::endl;
   } else if (type =  assign(e_handle, n))
   {
     std::cout << "Point is on an edge." << std::endl;
   } else if (type =  assign(f_handle, n))
   {
     std::cout << "Point is on a facet." << std::endl;
   } else if (type =  assign(vol_handle_1, n))
   {
     std::cout << "Point is in a volume." << std::endl;
   } else
   {
     std::cout << "Error locating point." << std::endl;
   }
}

#ifdef SKIP
void make_polygon(Polygon_2& polygon)
{
   polygon.push_back(Point_2(0.0, 0.0));
   polygon.push_back(Point_2(1.0, 0.0));
   polygon.push_back(Point_2(1.0, 1.0));
   polygon.push_back(Point_2(0.5, 0.5));
   polygon.push_back(Point_2(0.0, 1.0));
}
//#define CGAL_NEF3_USE_SIMPLE_CARTESIAN

// Headers
//#include <CGAL/basic.h>
//#include <CGAL/Gmpz.h>
//#include <CGAL/gmpq.h>
//#include <CGAL/Homogeneous.h>
//#include <CGAL/Extended_homogeneous.h>

//#include <CGAL/double.h>
//#include <CGAL/Simple_cartesian.h>
#include <CGAL/Cartesian.h>
#include <CGAL/Convex_hull_d.h>
#include <CGAL/Convex_hull_d_traits_3.h>
#include <CGAL/Convex_hull_d_to_polyhedron_3.h>
#include <CGAL/Polyhedron_3.h>
#include <CGAL/Gmpq.h>
#include <CGAL/Nef_polyhedron_3.h>

// Kernels
//typedef CGAL::Homogeneous<CGAL::Gmpz>  Kernel;
//typedef CGAL::Homogeneous<CGAL::Gmpq>  Kernel;
//typedef CGAL::Extended_homogeneous<CGAL::Gmpz>  Kernel;

//typedef CGAL::Homogeneous<float>  Kernel;
//typedef CGAL::Simple_cartesian<double>     Kernel;
//typedef CGAL::Cartesian<CGAL::Gmpz>     Kernel;
typedef CGAL::Cartesian<CGAL::Gmpq> K;
typedef CGAL::Cartesian<CGAL::Gmpq> Kernel;


//typedef CGAL::Homogeneous<double>              K;
typedef K::Point_3                             Point_3;
typedef CGAL::Polyhedron_3< K>                 Polyhedron_3;
typedef CGAL::Convex_hull_d_traits_3<K>        Hull_traits_3;
typedef CGAL::Convex_hull_d< Hull_traits_3 >   Convex_hull_3;
typedef K::Segment_3                           Segment_3;

typedef CGAL::Polyhedron_3<Kernel>         Polyhedron;
typedef Polyhedron::Plane_3                Plane_3;
typedef Polyhedron::Point_3                Point_3;
typedef CGAL::Nef_polyhedron_3<Kernel>     Nef_polyhedron;
//typedef Nef_polyhedron::Point_3            Point_3;
//typedef Nef_polyhedron::Plane_3            Plane_3;
//typedef Polyhedron::Vertex_iterator        Vertex_iterator;

  //typedef Nef_polyhedron::Vertex_const_handle Vertex_const_handle;
  //typedef Nef_polyhedron::Halfedge_const_handle Halfedge_const_handle;
  //typedef Nef_polyhedron::Halffacet_const_handle Halffacet_const_handle;
  //typedef Nef_polyhedron::Volume_const_handle Volume_const_handle;
  //typedef Nef_polyhedron::Object_handle Object_handle;
// Polygon headers
#include <CGAL/basic.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Partition_traits_2.h>
#include <CGAL/Partition_is_valid_traits_2.h>
#include <CGAL/polygon_function_objects.h>
#include <CGAL/partition_2.h>
//#include <CGAL/point_generators_2.h>
//#include <CGAL/random_polygon_2.h>
#include <cassert>
#include <list>


//typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef CGAL::Partition_traits_2<K>                         Traits;
typedef CGAL::Is_convex_2<Traits>                           Is_convex_2;
typedef Traits::Polygon_2                                   Polygon_2;
typedef Traits::Point_2                                     Point_2;
typedef Polygon_2::Vertex_const_iterator                    Vertex_iterator;
typedef std::list<Polygon_2>                                Polygon_list;
typedef CGAL::Partition_is_valid_traits_2<Traits, Is_convex_2>
                                                            Validity_traits;
//typedef CGAL::Creator_uniform_2<int, Point_2>               Creator;
//typedef CGAL::Random_points_in_square_2<Point_2, Creator>   Point_generator;

int main() {
  std::vector <Point_3> p, p1;
  // define points for wedge
  p.push_back(Point_3( 0.0, 0.0, 0.0));
  p.push_back(Point_3( 1.0, 0.0, 0.0));
  p.push_back(Point_3( 1.0, 1.0, 0.0));
  p.push_back(Point_3( 0.0, 1.0, 0.0));
  p.push_back(Point_3( 0.0, 0.0, 1.0));
  p.push_back(Point_3( 0.0, 1.0, 1.0));
  Point_3 p7(1.25,.25,.25);

  Convex_hull_3 CH(3);
  for (std::vector<Point_3>::iterator it = p.begin(); it != p.end(); it++)
  {
    CH.insert(*it);
  }
  assert(CH.is_valid());

  Convex_hull_3::Vertex_handle vh, v;
  bool point_in_hull=false;

  // Check if point is a vertex
  forall_ch_vertices(v,CH)
  {
    if (v->point() == p7)
    {
      std::cerr << "Point is a vertex of polyhedron." << std::endl;
      point_in_hull = true;
      break;
    }
  }

  // If not a vertex, see if a new vertex is added to the convex hull
  if (!point_in_hull)
  {
    vh = CH.insert(p7);
    if (vh == NULL)
    {
      std::cerr << "Point is in polyhedron, but not a vertex." << std::endl;
      point_in_hull = true;
    } else
    {
      std::cout << vh->point() << "\n";
      std::cerr << "Point is outside polyhedron." << std::endl;
      point_in_hull = false;
    }
  }

  return 0;
}   // Make nef polyhedron of prism

   std::list<Polygon_2>::const_iterator poly_it;
   Nef_polyhedron nef_poly(Nef_polyhedron::EMPTY);

   Polyhedron P;

      // Iterate over convex polygons
   for (poly_it = partition_polys.begin(); poly_it != partition_polys.end(); poly_it++)
   {
     // Put vertices into list
     Vertex_iterator v_it;
     std::list<Point_3> pts;
     for (v_it = poly_it->vertices_begin(); v_it != poly_it->vertices_end(); v_it++)
     {
       pts.push_back(Point_3(v_it->cartesian(0), v_it->cartesian(1), 1.0));
     }
     for (v_it = poly_it->vertices_begin(); v_it != poly_it->vertices_end(); v_it++)
     {
       pts.push_back(Point_3(v_it->cartesian(0), v_it->cartesian(1), 0.0));
     }
     // Make nef polyhedron of convex polygon and add to cumulative nef polyhedron
     nef_poly.join(Nef_polyhedron(pts.begin(), pts.end(), Nef_polyhedron::INCLUDED));
   }

   Nef_polyhedron::Object_handle n = nef_poly.locate(Point_3(0.5, 0.5, 0.5));
   bool type;

   type = nef_poly.is_empty();
   type = nef_poly.is_space();
   type = nef_poly.is_simple();
   type = nef_poly.is_valid();
   Nef_polyhedron::Vertex_const_handle v_handle;
   Nef_polyhedron::Halfedge_const_handle e_handle;
   Nef_polyhedron::Halffacet_const_handle f_handle;
   Nef_polyhedron::Volume_const_handle vol_handle_1, vol_handle_2;
   type =  assign(v_handle, n);
   type =  assign(e_handle, n);
   type =  assign(f_handle, n);
   type =  assign(vol_handle_1, n);

   //type = nef_poly.contains(n);

   n = nef_poly.locate(Point_3(10., 10.0, 10.));
   type =  assign(v_handle, n);
   type =  assign(e_handle, n);
   type =  assign(f_handle, n);
   type =  assign(vol_handle_2, n);


   // Make polyhedron

   // Add it to nef polyhedron



  std::vector <Point_3> p, p1;
  // define points for wedge
  p.push_back(Point_3( 0.0, 0.0, 0.0));
  p.push_back(Point_3( 1.0, 0.0, 0.0));
  p.push_back(Point_3( 1.0, 1.0, 0.0));
  p.push_back(Point_3( 0.0, 1.0, 0.0));
  p.push_back(Point_3( 0.0, 0.0, 1.0));
  p.push_back(Point_3( 0.0, 1.0, 1.0));
  Point_3 p7(1.25,.25,.25);

  Convex_hull_3 CH(3);
  for (std::vector<Point_3>::iterator it = p.begin(); it != p.end(); it++)
  {
    CH.insert(*it);
  }
  assert(CH.is_valid());

  Convex_hull_3::Vertex_handle vh, v;
  bool point_in_hull=false;

  // Check if point is a vertex
  forall_ch_vertices(v,CH)
  {
    if (v->point() == p7)
    {
      std::cerr << "Point is a vertex of polyhedron." << std::endl;
      point_in_hull = true;
      break;
    }
  }

  // If not a vertex, see if a new vertex is added to the convex hull
  if (!point_in_hull)
  {
    vh = CH.insert(p7);
    if (vh == NULL)
    {
      std::cerr << "Point is in polyhedron, but not a vertex." << std::endl;
      point_in_hull = true;
    } else
    {
      std::cout << vh->point() << "\n";
      std::cerr << "Point is outside polyhedron." << std::endl;
      point_in_hull = false;
    }
  }
#endif
