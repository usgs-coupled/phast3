#
# phastinput
#
project(phastinput CXX)

# defines
ADD_DEFINITIONS(-DANSI_DECLARATORS)
#ADD_DEFINITIONS(-DTRILIBRARY) set in config.h
ADD_DEFINITIONS(-DPHRQ_IO_INPUT)
ADD_DEFINITIONS(-DUSE_GZ)

# setup include directories
include_directories(${Boost_INCLUDE_DIRS})
include_directories("${CMAKE_SOURCE_DIR}/src/phastinput/PhastKeywords")
include_directories("${CMAKE_SOURCE_DIR}/src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp")

# source
SET(phastinput_SOURCES
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.cxx
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.h
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.cxx
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.h
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.cpp
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.h
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/phrqtype.h
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.cxx
../phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.h
accumulate.cpp
ArcRaster.cpp
ArcRaster.h
BC_info.cpp
BC_info.h
check.cpp
Cube.cpp
Cube.h
Data_source.cpp
Data_source.h
Domain.cpp
Domain.h
Drain.cpp
Drain.h
Exterior_cell.cpp
Exterior_cell.h
Filedata.cpp
Filedata.h
getopt.cpp
getopt.h
gpc.cpp
gpc.h
gpc_helper.cpp
gpc_helper.h
hstinpt.h
index_range.h
inputproto.h
KDtree/KDtree.cpp
KDtree/KDtree.h
KDtree/kdtree2.cpp
KDtree/kdtree2.hpp
KDtree/Point.cpp
KDtree/Point.h
main.cpp
message.cpp
message.h
Mix.h
NNInterpolator/config.h
NNInterpolator/delaunay.c
NNInterpolator/delaunay.h
NNInterpolator/hash.c
NNInterpolator/hash.h
NNInterpolator/istack.c
NNInterpolator/istack.h
NNInterpolator/lpi.c
NNInterpolator/minell.c
NNInterpolator/minell.h
NNInterpolator/nan.h
NNInterpolator/nn.h
NNInterpolator/nn_internal.h
NNInterpolator/nnai.c
NNInterpolator/nncommon-vulnerable.c
NNInterpolator/nncommon.c
NNInterpolator/NNInterpolator.cpp
NNInterpolator/NNInterpolator.h
NNInterpolator/nnpi.c
NNInterpolator/preader.c
NNInterpolator/preader.h
NNInterpolator/triangle.c
NNInterpolator/triangle.h
NNInterpolator/version.h
PHAST_polygon.cpp
PHAST_polygon.h
PHAST_Transform.cpp
PHAST_Transform.h
PhastKeywords/Keywords.cpp
PhastKeywords/Keywords.h
Polygon_tree.cpp
Polygon_tree.h
Polyhedron.cpp
Polyhedron.h
Prism.cpp
Prism.h
property.h
read.cpp
River.h
rivers.cpp
Shapefiles/dbfopen.c
Shapefiles/shapefil.h
Shapefiles/Shapefile.cpp
Shapefiles/Shapefile.h
Shapefiles/shpopen.c
Shapefiles/shptree.c
structures.cpp
tailor.h
time.cpp
timepi.h
UniqueMap.h
unit_impl.cxx
unit_impl.h
units_impl.cxx
utilities.cpp
Utilities.h
Wedge.cpp
Wedge.h
wells.cpp
wphast.h
write.cpp
XYZfile.cpp
XYZfile.h
XYZTfile.cpp
XYZTfile.h
zone.cpp
zone.h
Zone_budget.cpp
Zone_budget.h
)

if (MSVC)
  set(phastinput_SOURCES ${phastinput_SOURCES} phastinput.rc)
  set(phastinput_SOURCES ${phastinput_SOURCES} phastinput_version.h)
  set(phastinput_SOURCES ${phastinput_SOURCES} resource.h)
endif()


# compile .c files as CXX
SET(C_FILES
NNInterpolator/delaunay.c
NNInterpolator/hash.c
NNInterpolator/istack.c
NNInterpolator/lpi.c
NNInterpolator/minell.c
NNInterpolator/nnai.c
NNInterpolator/nncommon-vulnerable.c
NNInterpolator/nncommon.c
NNInterpolator/nnpi.c
NNInterpolator/preader.c
NNInterpolator/triangle.c
Shapefiles/dbfopen.c
Shapefiles/shpopen.c
Shapefiles/shptree.c
)
SET_SOURCE_FILES_PROPERTIES(${C_FILES} PROPERTIES LANGUAGE CXX)

add_executable(phastinput ${phastinput_SOURCES})

# install
install(TARGETS phastinput DESTINATION ${CMAKE_INSTALL_BINDIR})
##if (BUILD_CLR_LIBS)
##  install(FILES "${PROJECT_SOURCE_DIR}/src/phreeqcpp/ZedGraph.dll" DESTINATION ${CMAKE_INSTALL_LIBDIR})
##endif()


### tests
##enable_testing()
##
##add_subdirectory(Tests)
