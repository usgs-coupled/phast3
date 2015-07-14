#
# phasthdf
#
project(phasthdf CXX)

# defines

# include directories

# source
SET(phasthdf_SOURCES
phastexport.cpp
phastexport.h
phastexport.ico
phastexport.rc
phasthdf_version.h
resource.h
small.ico
StdAfx.cpp
StdAfx.h
)

add_executable(phasthdf ${phasthdf_SOURCES})

# link flags
set_target_properties(phasthdf PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS")

# install
install(TARGETS phasthdf DESTINATION ${CMAKE_INSTALL_BINDIR})
