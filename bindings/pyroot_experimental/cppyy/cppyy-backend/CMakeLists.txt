# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(py_sources
  cppyy_backend/__init__.py
  cppyy_backend/_cling_config.py
  cppyy_backend/_cppyy_generator.py
  cppyy_backend/_genreflex.py
  cppyy_backend/_rootcling.py
  cppyy_backend/bindings_utils.py
  cppyy_backend/loader.py
  cppyy_backend/_get_cppflags.py
)

set(cppyy_backendDirName cling/python/cppyy_backend)
file(COPY ${cppyy_backendDirName} DESTINATION ${localruntimedir})

foreach(val RANGE ${how_many_pythons})
  list(GET python_version_strings ${val} python_output_name)
  list(GET python_executables ${val} python_executable)
  list(GET python_major_versions ${val} python_major_version)

  add_library(cppyy_backend${python_output_name} SHARED clingwrapper/src/clingwrapper.cxx)
  target_include_directories(cppyy_backend${python_output_name} PRIVATE clingwrapper/src)
  target_link_libraries(cppyy_backend${python_output_name} Core ${CMAKE_DL_LIBS})

  # cppyy uses ROOT headers from binary directory
  add_dependencies(cppyy_backend${python_output_name} move_headers)
  target_include_directories(cppyy_backend${python_output_name} PRIVATE ${CMAKE_BINARY_DIR}/include)

  set_property(GLOBAL APPEND PROPERTY ROOT_EXPORTED_TARGETS cppyy_backend${python_output_name})

  # Installation
  set(cmake_install_pyrootdir ${CMAKE_INSTALL_PY${python_major_version}ROOTDIR})
  set(CMAKE_INSTALL_LIBDIR ${cmake_install_pyrootdir})
  if(IS_ABSOLUTE ${cmake_install_pyrootdir})
    set(d $ENV{DESTDIR}/${cmake_install_pyrootdir})
  else()
    set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${cmake_install_pyrootdir})
  endif()
  foreach(py_source ${py_sources})
    install(FILES cling/python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy_backend)
    install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
    install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
  endforeach()
  install(TARGETS cppyy_backend${python_output_name} EXPORT ROOTExports DESTINATION ${CMAKE_INSTALL_LIBDIR})

endforeach()
