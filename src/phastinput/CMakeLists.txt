#
# phastinput
#
project(phastinput CXX)

# setup include directories
include_directories(${Boost_INCLUDE_DIRS})
include_directories("${CMAKE_SOURCE_DIR}/src/phastinput/common")
include_directories("${CMAKE_SOURCE_DIR}/src/phastinput/PhastKeywords")
include_directories("${CMAKE_SOURCE_DIR}/src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp")

# source
SET(phastinput_SOURCES
accumulate.cpp
ArcRaster.cpp
ArcRaster.h
BC_info.cpp
BC_info.h
check.cpp
common/Parser.cxx
common/Parser.h
common/PHRQ_base.cxx
common/PHRQ_base.h
common/PHRQ_io.cpp
common/PHRQ_io.h
common/phrqtype.h
common/Utils.cxx
common/Utils.h
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

# defines
target_compile_definitions(phastinput 
  PRIVATE
    ANSI_DECLARATORS
    PHRQ_IO_INPUT
    USE_GZ
)
if(NOT WIN32)
  # TRILIBRARY is set in config.h for windows
  target_compile_definitions(phastinput 
    PRIVATE
      TRILIBRARY
  )
endif()

# install
install(TARGETS phastinput DESTINATION ${CMAKE_INSTALL_BINDIR})
