# 
# Make file for PHASTINPUT
#
PROGRAM=phastinput
.SUFFIXES : .o .c .cxx .cpp
.cpp.o :
	${CXX} ${CFLAGS} -c -o $@ $<
.cxx.o :
	${CXX} ${CFLAGS} -c -o $@ $<
.c.o :
	${CXX} ${CFLAGS} -c -o $@ $<

#.SILENT:

# Linux
#CC=gcc
CC=g++
CFLAGS=-O2 -Wall -ansi -pedantic -DANSI_DECLARATORS -DTRILIBRARY
#CFLAGS=-g -Wall -ansi -pedantic -DANSI_DECLARATORS -DTRILIBRARY # -DBOOST_UBLAS_UNSUPPORTED_COMPILER=0

# RS6000
#CC=cc
#CCFLAGS=-langlvl=ansi -O2

# Dec Alpha
#CC=cc
#CCFLAGS=-ansi -O2

#Solaris
#CC=/opt/SUNWspro/bin/cc
#CCFLAGS=-fast

LOADFLAGS= -lm 
LOADFLAGS+=$(call ld-option, -Wl$(comma)--hash-style=sysv)
#LOADFLAGS+= -lefence

FILES=\
	accumulate.c \
	ArcRaster.cpp \
	BC_info.cpp \
	check.c \
	Cube.cpp \
	Data_source.cpp \
	Domain.cpp \
	Drain.cpp \
	Exterior_cell.cpp \
	Filedata.cpp \
	getopt.c \
	gpc.c \
	main.c \
	message.c \
	PHAST_Transform.cpp \
	PHAST_polygon.cpp \
	Point.cpp \
	Polygon_tree.cpp \
	Polyhedron.cpp \
	Prism.cpp \
	read.c \
	rivers.c \
	structures.c \
	time.c \
	unit_impl.cxx \
	units_impl.cxx \
	utilities.c \
	Wedge.cpp \
	wells.c \
	write.c  \
	XYZfile.cpp \
	XYZTfile.cpp \
	zone.cpp \
	Zone_budget.cpp

OBJECTS=\
	accumulate.o \
	check.o \
	Domain.o \
	getopt.o \
	gpc.o \
	gpc_helper.o \
	main.o \
	message.o \
	read.o \
	rivers.o \
	structures.o \
	time.o \
	unit_impl.o \
	units_impl.o \
	utilities.o \
	wells.o \
	write.o \
	zone.o \
	ArcRaster.o \
	BC_info.o \
	Cube.o \
	Data_source.o \
	Drain.o \
	Exterior_cell.o \
	Filedata.o \
	PHAST_Transform.o \
	PHAST_polygon.o \
	Polygon_tree.o \
	Polyhedron.o \
	Prism.o \
	Wedge.o \
	XYZfile.o \
	XYZTfile.o \
	Zone_budget.o

NNI_OBJECTS= \
	NNInterpolator/delaunay.o \
	NNInterpolator/hash.o \
	NNInterpolator/istack.o \
	NNInterpolator/lpi.o \
	NNInterpolator/minell.o \
	NNInterpolator/nnai.o \
	NNInterpolator/nncommon.o \
	NNInterpolator/nncommon-vulnerable.o \
	NNInterpolator/NNInterpolator.o \
	NNInterpolator/nnpi.o \
	NNInterpolator/preader.o \
	NNInterpolator/triangle.o 

SHAPE_OBJECTS= \
	Shapefiles/dbfopen.o \
	Shapefiles/Shapefile.o \
	Shapefiles/shpopen.o \
	Shapefiles/shptree.o 

KDTREE_OBJECTS= \
	KDtree/kdtree2.o \
	KDtree/KDtree.o \
	KDtree/Point.o



	ALL_OBJECTS= $(OBJECTS) $(NNI_OBJECTS) $(SHAPE_OBJECTS) $(KDTREE_OBJECTS)

$(PROGRAM): $(ALL_OBJECTS)  
	$(CC) -o $(PROGRAM) $(ALL_OBJECTS) $(LOADFLAGS) 

accumulate.o: accumulate.c hstinpt.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h index_range.h zone.h property.h Polyhedron.h \
  KDtree/Point.h KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h timepi.h \
  inputproto.h wphast.h message.h Prism.h Data_source.h PHAST_polygon.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h Cube.h \
  Wedge.h Domain.h Zone_budget.h Filedata.h XYZTfile.h
check.o: check.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h
getopt.o: getopt.c
gpc.o: gpc.c gpc.h gpc_helper.h KDtree/Cell_Face.h wphast.h
gpc_helper.o: gpc_helper.c message.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h KDtree/Point.h KDtree/Cell_Face.h Utilities.h \
  PHAST_polygon.h zone.h PHAST_Transform.h wphast.h
main.o: main.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  message.h NNInterpolator/NNInterpolator.h \
  NNInterpolator/../KDtree/Point.h NNInterpolator/../zone.h \
  NNInterpolator/../PHAST_Transform.h NNInterpolator/../UniqueMap.h \
  NNInterpolator/nn.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h \
  ArcRaster.h Filedata.h Data_source.h PHAST_polygon.h Polygon_tree.h \
  Zone_budget.h
message.o: message.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  message.h
read.o: read.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  message.h Cube.h Wedge.h Prism.h Data_source.h PHAST_polygon.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h \
  XYZfile.h Filedata.h Zone_budget.h
rivers.o: rivers.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  message.h
structures.o: structures.c hstinpt.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h index_range.h zone.h property.h Polyhedron.h \
  KDtree/Point.h KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h timepi.h \
  inputproto.h wphast.h Data_source.h PHAST_polygon.h Polygon_tree.h \
  KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h
time.o: time.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  Filedata.h Data_source.h PHAST_polygon.h Polygon_tree.h KDtree/KDtree.h \
  KDtree/kdtree2.hpp KDtree/Point.h XYZTfile.h
utilities.o: utilities.c message.h hstinpt.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h index_range.h zone.h property.h Polyhedron.h \
  KDtree/Point.h KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h timepi.h \
  inputproto.h wphast.h
wells.o: wells.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h
write.o: write.c hstinpt.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h \
  message.h Zone_budget.h
unit_impl.o: unit_impl.cxx hstinpt.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h index_range.h zone.h property.h Polyhedron.h \
  KDtree/Point.h KDtree/Cell_Face.h PHAST_Transform.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h timepi.h \
  inputproto.h wphast.h
ArcRaster.o: ArcRaster.cpp ArcRaster.h Filedata.h zone.h gpc.h \
  gpc_helper.h KDtree/Cell_Face.h PHAST_Transform.h KDtree/Point.h \
  KDtree/Cell_Face.h Data_source.h PHAST_polygon.h unit_impl.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h \
  message.h
BC_info.o: BC_info.cpp BC_info.h Mix.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h Utilities.h
Cube.o: Cube.cpp Cube.h Polyhedron.h KDtree/Point.h KDtree/Cell_Face.h \
  gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h PHAST_Transform.h \
  index_range.h message.h
Data_source.o: Data_source.cpp zone.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h Data_source.h PHAST_polygon.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h unit_impl.h Polygon_tree.h \
  KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h message.h Utilities.h \
  Shapefiles/Shapefile.h Shapefiles/../Filedata.h Shapefiles/../zone.h \
  Shapefiles/../gpc.h Shapefiles/../PHAST_Transform.h \
  Shapefiles/../Data_source.h Shapefiles/shapefil.h Shapefiles/../gpc.h \
  ArcRaster.h Filedata.h XYZfile.h XYZTfile.h \
  NNInterpolator/NNInterpolator.h NNInterpolator/../KDtree/Point.h \
  NNInterpolator/../zone.h NNInterpolator/../PHAST_Transform.h \
  NNInterpolator/../UniqueMap.h NNInterpolator/nn.h UniqueMap.h
Domain.o: Domain.cpp Domain.h Cube.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h \
  PHAST_Transform.h
Drain.o: Drain.cpp Drain.h gpc.h gpc_helper.h KDtree/Cell_Face.h River.h \
  PHAST_Transform.h KDtree/Point.h KDtree/Cell_Face.h hstinpt.h \
  index_range.h zone.h property.h Polyhedron.h Exterior_cell.h BC_info.h \
  Mix.h Utilities.h unit_impl.h timepi.h inputproto.h wphast.h message.h
Exterior_cell.o: Exterior_cell.cpp Exterior_cell.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h message.h Utilities.h
Filedata.o: Filedata.cpp KDtree/Point.h KDtree/Cell_Face.h \
  NNInterpolator/NNInterpolator.h NNInterpolator/../KDtree/Point.h \
  NNInterpolator/../zone.h NNInterpolator/../gpc.h \
  NNInterpolator/../gpc_helper.h NNInterpolator/../KDtree/Cell_Face.h \
  NNInterpolator/../PHAST_Transform.h NNInterpolator/../KDtree/Point.h \
  NNInterpolator/../UniqueMap.h NNInterpolator/nn.h Filedata.h zone.h \
  gpc.h PHAST_Transform.h Data_source.h PHAST_polygon.h unit_impl.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/Point.h \
  message.h NNInterpolator/nan.h
PHAST_polygon.o: PHAST_polygon.cpp PHAST_polygon.h KDtree/Point.h \
  KDtree/Cell_Face.h gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h \
  PHAST_Transform.h message.h
PHAST_Transform.o: PHAST_Transform.cpp PHAST_Transform.h KDtree/Point.h \
  KDtree/Cell_Face.h message.h
Point.o: KDtree/Point.cpp KDtree/Point.h KDtree/Cell_Face.h
Polygon_tree.o: Polygon_tree.cpp Polygon_tree.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h zone.h PHAST_polygon.h KDtree/Point.h \
  KDtree/Cell_Face.h PHAST_Transform.h
Polyhedron.o: Polyhedron.cpp Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h \
  PHAST_Transform.h
Prism.o: Prism.cpp Prism.h Polyhedron.h KDtree/Point.h KDtree/Cell_Face.h \
  gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h PHAST_Transform.h \
  Data_source.h PHAST_polygon.h unit_impl.h Polygon_tree.h KDtree/KDtree.h \
  KDtree/kdtree2.hpp KDtree/Point.h Cube.h Wedge.h message.h Utilities.h
Wedge.o: Wedge.cpp Wedge.h Cube.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h \
  PHAST_Transform.h message.h Utilities.h PHAST_polygon.h
XYZfile.o: XYZfile.cpp XYZfile.h Filedata.h zone.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h PHAST_Transform.h KDtree/Point.h KDtree/Cell_Face.h \
  Data_source.h PHAST_polygon.h unit_impl.h Polygon_tree.h KDtree/KDtree.h \
  KDtree/kdtree2.hpp KDtree/Point.h message.h
XYZTfile.o: XYZTfile.cpp XYZTfile.h Filedata.h zone.h gpc.h gpc_helper.h \
  KDtree/Cell_Face.h PHAST_Transform.h KDtree/Point.h KDtree/Cell_Face.h \
  Data_source.h PHAST_polygon.h unit_impl.h Polygon_tree.h KDtree/KDtree.h \
  KDtree/kdtree2.hpp KDtree/Point.h message.h
Zone_budget.o: Zone_budget.cpp Zone_budget.h Polyhedron.h KDtree/Point.h \
  KDtree/Cell_Face.h gpc.h gpc_helper.h KDtree/Cell_Face.h zone.h \
  PHAST_Transform.h message.h
zone.o: zone.cpp zone.h gpc.h gpc_helper.h KDtree/Cell_Face.h \
  KDtree/Point.h KDtree/Cell_Face.h
delaunay.o: NNInterpolator/delaunay.c NNInterpolator/triangle.h \
  NNInterpolator/istack.h NNInterpolator/nan.h NNInterpolator/delaunay.h \
  NNInterpolator/nn.h NNInterpolator/nn_internal.h NNInterpolator/config.h
hash.o: NNInterpolator/hash.c NNInterpolator/hash.h \
  NNInterpolator/config.h
istack.o: NNInterpolator/istack.c NNInterpolator/istack.h
lpi.o: NNInterpolator/lpi.c NNInterpolator/nan.h \
  NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h
minell.o: NNInterpolator/minell.c NNInterpolator/config.h \
  NNInterpolator/nan.h NNInterpolator/minell.h
nnai.o: NNInterpolator/nnai.c NNInterpolator/nan.h \
  NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h
nncommon.o: NNInterpolator/nncommon.c NNInterpolator/config.h \
  NNInterpolator/delaunay.h NNInterpolator/nn.h NNInterpolator/nan.h \
  NNInterpolator/nn_internal.h NNInterpolator/version.h
nncommon-vulnerable.o: NNInterpolator/nncommon-vulnerable.c \
  NNInterpolator/nn.h NNInterpolator/delaunay.h NNInterpolator/nan.h \
  NNInterpolator/nn_internal.h NNInterpolator/config.h
nnpi.o: NNInterpolator/nnpi.c NNInterpolator/nan.h NNInterpolator/hash.h \
  NNInterpolator/istack.h NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h NNInterpolator/config.h
preader.o: NNInterpolator/preader.c NNInterpolator/config.h \
  NNInterpolator/nan.h NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h NNInterpolator/preader.h
triangle.o: NNInterpolator/triangle.c NNInterpolator/config.h
NNInterpolator.o: NNInterpolator/NNInterpolator.cpp \
  NNInterpolator/../KDtree/Point.h NNInterpolator/../KDtree/Cell_Face.h \
  NNInterpolator/config.h NNInterpolator/nan.h NNInterpolator/../message.h \
  NNInterpolator/../KDtree/KDtree.h NNInterpolator/../KDtree/kdtree2.hpp \
  NNInterpolator/../KDtree/Point.h NNInterpolator/NNInterpolator.h \
  NNInterpolator/../zone.h NNInterpolator/../gpc.h \
  NNInterpolator/../gpc_helper.h NNInterpolator/../KDtree/Cell_Face.h \
  NNInterpolator/../PHAST_Transform.h NNInterpolator/../KDtree/Point.h \
  NNInterpolator/../UniqueMap.h NNInterpolator/nn.h
dbfopen.o: Shapefiles/dbfopen.c Shapefiles/shapefil.h
shpopen.o: Shapefiles/shpopen.c Shapefiles/shapefil.h
shptree.o: Shapefiles/shptree.c Shapefiles/shapefil.h
Shapefile.o: Shapefiles/Shapefile.cpp Shapefiles/../zone.h \
  Shapefiles/../gpc.h Shapefiles/../gpc_helper.h \
  Shapefiles/../KDtree/Cell_Face.h Shapefiles/Shapefile.h \
  Shapefiles/../Filedata.h Shapefiles/../zone.h \
  Shapefiles/../PHAST_Transform.h Shapefiles/../KDtree/Point.h \
  Shapefiles/../KDtree/Cell_Face.h Shapefiles/../Data_source.h \
  Shapefiles/../PHAST_polygon.h Shapefiles/../unit_impl.h \
  Shapefiles/../Polygon_tree.h Shapefiles/../KDtree/KDtree.h \
  Shapefiles/../KDtree/kdtree2.hpp Shapefiles/../KDtree/Point.h \
  Shapefiles/shapefil.h Shapefiles/../gpc.h Shapefiles/../KDtree/Point.h \
  Shapefiles/../message.h Shapefiles/../Utilities.h \
  Shapefiles/../PHAST_polygon.h
kdtree2.o: KDtree/kdtree2.cpp KDtree/kdtree2.hpp
KDtree.o: KDtree/KDtree.cpp KDtree/KDtree.h KDtree/kdtree2.hpp \
  KDtree/Point.h KDtree/Cell_Face.h

diff: 
	for FILE in $(FILES); do rcsdiff $$FILE ; done

clean:
	rm -f $(PROGRAM) *.o NNInterpolator/*.o Shapefiles/*.o KDtree/*.o
	echo Removed files generated by srcinput/Makefile."\n"

#ld-option
# Usage: ldflags += $(call ld-option, -Wl$(comma)--hash-style=sysv)
comma=,
ld-option = $(shell if $(CC) $(1) \
              -nostdlib -o /dev/null -xc /dev/null \
              > /dev/null 2>&1 ; then echo "$(1)" ; else echo "$(2)"; fi)

depends:
	gcc -MM -DBOOST_UBLAS_UNSUPPORTED_COMPILER=0 *.c *.cxx *.cpp \
	./NNInterpolator/*.c ./NNInterpolator/*.cpp \
        ./Shapefiles/*.c ./Shapefiles/*.cpp \
        ./KDtree/*.cpp \
	> dependencies
