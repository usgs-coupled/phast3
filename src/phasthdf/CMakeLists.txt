if (MSVC)
  add_subdirectory(win32)
endif()

SET(phasthdf_jars
dist-lib64/jhdf.jar
dist-lib64/jhdf5.jar
dist-lib64/jhdf5obj.jar
dist-lib64/jhdfobj.jar
dist-lib64/phast.jar
)

install(FILES ${phasthdf_jars} DESTINATION ${CMAKE_INSTALL_LIBDIR})

if (WIN32)
  SET(phasthdf_dlls
  dist-lib64/Win32/jhdf.dll
  dist-lib64/Win32/jhdf5.dll
  )
  
  install(FILES ${phasthdf_dlls} DESTINATION ${CMAKE_INSTALL_LIBDIR}/Win32)
endif()

if ("${CMAKE_SYSTEM}" MATCHES "Linux")
  SET(phasthdf_dlls
  dist-lib64/Linux/libjhdf.so
  dist-lib64/Linux/libjhdf5.so
  )
  
  install(FILES ${phasthdf_dlls} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif()