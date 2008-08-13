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
#CCFLAGS=-O2 -Wall -ansi -pedantic 
CFLAGS=-g -Wall -ansi -pedantic -DANSI_DECLARATORS -DTRILIBRARY -DBOOST_UBLAS_UNSUPPORTED_COMPILER=0

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
	Drain.cpp \
	Exterior_cell.cpp \
	Filedata.cpp \
	getopt.c \
	gpc.c \
	main.c \
	message.c \
	PHAST_Transform.cpp \
	PHST_polygon.cpp \
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
	zone.cpp

OBJECTS=\
	accumulate.o \
	check.o \
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
	PHST_polygon.o \
	Point.o \
	Polygon_tree.o \
	Polyhedron.o \
	Prism.o \
	Wedge.o \
	XYZfile.o

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
	KDtree/KDtree.o



ALL_OBJECTS= $(OBJECTS) $(NNI_OBJECTS) $(SHAPE_OBJECTS) $(KDTREE_OBJECTS)

$(PROGRAM): $(ALL_OBJECTS)  
	$(CC) -o $(PROGRAM) $(ALL_OBJECTS) $(LOADFLAGS) 

accumulate.o: accumulate.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h Point.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h time.h \
  inputproto.h message.h Prism.h Data_source.h PHST_polygon.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/../Point.h \
  KDtree/../NNInterpolator/nn.h
check.o: check.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h
getopt.o: getopt.c
gpc.o: gpc.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h message.h
gpc_helper.o: gpc_helper.c message.h gpc.h gpc_helper.h Cell_Face.h \
  Point.h Utilities.h PHST_polygon.h zone.h
main.o: main.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h message.h \
  NNInterpolator/NNInterpolator.h NNInterpolator/../Point.h \
  NNInterpolator/../zone.h NNInterpolator/nn.h KDtree/KDtree.h \
  KDtree/kdtree2.hpp KDtree/../Point.h KDtree/../NNInterpolator/nn.h \
  ArcRaster.h Filedata.h PHAST_Transform.h
message.o: message.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h Point.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h time.h \
  inputproto.h message.h
read.o: read.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h message.h \
  Cube.h Wedge.h Prism.h Data_source.h PHST_polygon.h Polygon_tree.h \
  KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/../Point.h \
  KDtree/../NNInterpolator/nn.h XYZfile.h Filedata.h
rivers.o: rivers.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h message.h
structures.o: structures.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h Point.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h time.h \
  inputproto.h Data_source.h PHST_polygon.h Polygon_tree.h \
  KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/../Point.h \
  KDtree/../NNInterpolator/nn.h
time.o: time.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h
utilities.o: utilities.c message.h hstinpt.h gpc.h gpc_helper.h \
  Cell_Face.h index_range.h zone.h property.h Polyhedron.h Point.h \
  Exterior_cell.h BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h \
  time.h inputproto.h
wells.o: wells.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h
write.o: write.c hstinpt.h gpc.h gpc_helper.h Cell_Face.h index_range.h \
  zone.h property.h Polyhedron.h Point.h Exterior_cell.h BC_info.h Mix.h \
  River.h Drain.h Utilities.h unit_impl.h time.h inputproto.h message.h
unit_impl.o: unit_impl.cxx hstinpt.h gpc.h gpc_helper.h Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h Point.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h time.h \
  inputproto.h
units_impl.o: units_impl.cxx hstinpt.h gpc.h gpc_helper.h Cell_Face.h \
  index_range.h zone.h property.h Polyhedron.h Point.h Exterior_cell.h \
  BC_info.h Mix.h River.h Drain.h Utilities.h unit_impl.h time.h \
  inputproto.h
ArcRaster.o: ArcRaster.cpp ArcRaster.h Filedata.h zone.h gpc.h \
  gpc_helper.h Cell_Face.h message.h Point.h
BC_info.o: BC_info.cpp BC_info.h Mix.h gpc.h gpc_helper.h Cell_Face.h \
  Utilities.h
Cube.o: Cube.cpp Cube.h Polyhedron.h Point.h gpc.h gpc_helper.h \
  Cell_Face.h zone.h index_range.h message.h
Data_source.o: Data_source.cpp zone.h Data_source.h gpc.h gpc_helper.h \
  Cell_Face.h PHST_polygon.h Point.h unit_impl.h Polygon_tree.h \
  KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/../Point.h \
  KDtree/../NNInterpolator/nn.h message.h Utilities.h \
  Shapefiles/Shapefile.h Shapefiles/../Filedata.h Shapefiles/../zone.h \
  Shapefiles/../gpc.h Shapefiles/shapefil.h Shapefiles/../gpc.h \
  ArcRaster.h Filedata.h XYZfile.h NNInterpolator/NNInterpolator.h \
  NNInterpolator/../Point.h NNInterpolator/../zone.h NNInterpolator/nn.h
Drain.o: Drain.cpp Drain.h gpc.h gpc_helper.h Cell_Face.h River.h \
  hstinpt.h index_range.h zone.h property.h Polyhedron.h Point.h \
  Exterior_cell.h BC_info.h Mix.h Utilities.h unit_impl.h time.h \
  inputproto.h message.h
Exterior_cell.o: Exterior_cell.cpp Exterior_cell.h gpc.h gpc_helper.h \
  Cell_Face.h message.h Utilities.h
Filedata.o: Filedata.cpp Point.h gpc.h gpc_helper.h Cell_Face.h \
  NNInterpolator/NNInterpolator.h NNInterpolator/../Point.h \
  NNInterpolator/../zone.h NNInterpolator/nn.h Filedata.h zone.h
PHAST_Transform.o: PHAST_Transform.cpp PHAST_Transform.h Point.h gpc.h \
  gpc_helper.h Cell_Face.h
PHST_polygon.o: PHST_polygon.cpp PHST_polygon.h Point.h gpc.h \
  gpc_helper.h Cell_Face.h zone.h message.h
Point.o: Point.cpp Point.h gpc.h gpc_helper.h Cell_Face.h message.h
Polygon_tree.o: Polygon_tree.cpp Polygon_tree.h gpc.h gpc_helper.h \
  Cell_Face.h zone.h PHST_polygon.h Point.h
Polyhedron.o: Polyhedron.cpp Polyhedron.h Point.h gpc.h gpc_helper.h \
  Cell_Face.h zone.h
Prism.o: Prism.cpp Prism.h Polyhedron.h Point.h gpc.h gpc_helper.h \
  Cell_Face.h zone.h Data_source.h PHST_polygon.h unit_impl.h \
  Polygon_tree.h KDtree/KDtree.h KDtree/kdtree2.hpp KDtree/../Point.h \
  KDtree/../NNInterpolator/nn.h Cube.h message.h Utilities.h
Wedge.o: Wedge.cpp Wedge.h Cube.h Polyhedron.h Point.h gpc.h gpc_helper.h \
  Cell_Face.h zone.h message.h Utilities.h
XYZfile.o: XYZfile.cpp XYZfile.h Filedata.h zone.h gpc.h gpc_helper.h \
  Cell_Face.h message.h Point.h PHST_polygon.h
zone.o: zone.cpp zone.h Point.h gpc.h gpc_helper.h Cell_Face.h
delaunay.o: NNInterpolator/delaunay.c NNInterpolator/triangle.h \
  NNInterpolator/istack.h NNInterpolator/nan.h NNInterpolator/delaunay.h \
  NNInterpolator/nn.h NNInterpolator/nn_internal.h \
  NNInterpolator/config.h
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
  NNInterpolator/delaunay.h NNInterpolator/nn.h NNInterpolator/nan.h \
  NNInterpolator/nn_internal.h NNInterpolator/config.h
nnpi.o: NNInterpolator/nnpi.c NNInterpolator/nan.h NNInterpolator/hash.h \
  NNInterpolator/istack.h NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h NNInterpolator/config.h
preader.o: NNInterpolator/preader.c NNInterpolator/config.h \
  NNInterpolator/nan.h NNInterpolator/delaunay.h NNInterpolator/nn.h \
  NNInterpolator/nn_internal.h NNInterpolator/preader.h
triangle.o: NNInterpolator/triangle.c NNInterpolator/config.h
NNInterpolator.o: NNInterpolator/NNInterpolator.cpp \
  NNInterpolator/../Point.h NNInterpolator/../gpc.h \
  NNInterpolator/../gpc_helper.h NNInterpolator/../Cell_Face.h \
  NNInterpolator/config.h NNInterpolator/nan.h \
  NNInterpolator/../KDtree/KDtree.h NNInterpolator/../KDtree/kdtree2.hpp \
  NNInterpolator/../KDtree/../Point.h \
  NNInterpolator/../KDtree/../NNInterpolator/nn.h \
  NNInterpolator/NNInterpolator.h NNInterpolator/../zone.h \
  NNInterpolator/nn.h
dbfopen.o: Shapefiles/dbfopen.c Shapefiles/shapefil.h
shpopen.o: Shapefiles/shpopen.c Shapefiles/shapefil.h
shptree.o: Shapefiles/shptree.c Shapefiles/shapefil.h
Shapefile.o: Shapefiles/Shapefile.cpp Shapefiles/../zone.h \
  Shapefiles/Shapefile.h Shapefiles/../Filedata.h Shapefiles/../zone.h \
  Shapefiles/../gpc.h Shapefiles/../gpc_helper.h \
  Shapefiles/../Cell_Face.h Shapefiles/shapefil.h Shapefiles/../gpc.h \
  Shapefiles/../Point.h Shapefiles/../message.h Shapefiles/../Utilities.h \
  Shapefiles/../PHST_polygon.h Shapefiles/../Point.h
kdtree2.o: KDtree/kdtree2.cpp KDtree/kdtree2.hpp
KDtree.o: KDtree/KDtree.cpp KDtree/KDtree.h KDtree/kdtree2.hpp \
  KDtree/../Point.h KDtree/../gpc.h KDtree/../gpc_helper.h \
  KDtree/../Cell_Face.h KDtree/../NNInterpolator/nn.h

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
