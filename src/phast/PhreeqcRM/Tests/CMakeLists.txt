# tests

# Tests/advect.pqi
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/advect.pqi.in"
  "${PROJECT_BINARY_DIR}/Tests/advect.pqi"
  )

# Tests/phreeqc.dat
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/phreeqc.dat.in"
  "${PROJECT_BINARY_DIR}/Tests/phreeqc.dat"
  )

# Tests/units.pqi
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/units.pqi.in"
  "${PROJECT_BINARY_DIR}/Tests/units.pqi"
  )

SET(testrm_SOURCES
  advection_c.c
  advection_cpp.cpp
  main.cpp
  species_c.c
  species_cpp.cpp
)

add_executable(testrm ${testrm_SOURCES})
SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM)
include_directories ("${PROJECT_SOURCE_DIR}")
target_link_libraries(testrm ${EXTRA_LIBS})

add_test(CompileAndRun testrm)
