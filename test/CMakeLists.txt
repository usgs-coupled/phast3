# phrqex11
configure_file(
  "${PROJECT_SOURCE_DIR}/examples/phrqex11/phrqex11.trans.dat"
  "phrqex11.trans.dat"
  COPYONLY
)

configure_file(
  "${PROJECT_SOURCE_DIR}/examples/phrqex11/phrqex11.chem.dat"
  "phrqex11.chem.dat"
  COPYONLY
)

configure_file(
  "${PROJECT_SOURCE_DIR}/examples/phrqex11/phast.dat"
  "phast.dat"
  COPYONLY
)

# phastinput.phrqex11
add_test(NAME phastinput.phrqex11
  COMMAND $<TARGET_FILE:phastinput> phrqex11
)

# phast.phrqex11
add_test(NAME phast.phrqex11
  COMMAND $<TARGET_FILE:phast3>
)
