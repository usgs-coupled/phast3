#
# phasthdf
#
project(phasthdf CXX)

# defines

# include directories

# source
SET(phasthdf_SOURCES
win32/phastexport.cpp
win32/phastexport.h
win32/phastexport.rc
win32/phasthdf_version.h
win32/resource.h
win32/StdAfx.cpp
)

add_executable(phasthdf ${phasthdf_SOURCES})

# link flags
set_target_properties(phasthdf PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS")

# install
install(TARGETS phasthdf DESTINATION ${CMAKE_INSTALL_BINDIR})
