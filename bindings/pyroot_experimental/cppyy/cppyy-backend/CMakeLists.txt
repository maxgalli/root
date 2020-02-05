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

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_rel_output_dirs ${val} python_output_name)
  list(GET python_executables ${val} python_executable)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  foreach(py_source ${py_sources})
    file(COPY cling/python/${py_source} DESTINATION ${python_output_dir}/cppyy_backend)
  endforeach()

  add_library(cppyy_backend_${python_output_name} SHARED clingwrapper/src/clingwrapper.cxx)
  target_include_directories(cppyy_backend_${python_output_name} PRIVATE clingwrapper/src)
  target_link_libraries(cppyy_backend_${python_output_name} Core ${CMAKE_DL_LIBS})

  set_target_properties(cppyy_backend_${python_output_name} PROPERTIES OUTPUT_NAME "cppyy_backend")

  # cppyy uses ROOT headers from binary directory
  add_dependencies(cppyy_backend_${python_output_name} move_headers)
  target_include_directories(cppyy_backend_${python_output_name} PRIVATE ${CMAKE_BINARY_DIR}/include)

  set_property(GLOBAL APPEND PROPERTY ROOT_EXPORTED_TARGETS cppyy_backend_${python_output_name})

endforeach()

# Installation
if(cmake14 AND DEFINED python_install_dirs)
  # Case 1: we are building PyROOT with two versions (cmake > 3.14) and, since
  # python_install_dirs is defined, CMAKE_INSTALL_PYROOTDIR wasn't defined by
  # the user (see RootInstallDirs)
  # We install each target in the default Python paths related to the Python
  # version it was built with
  # e.g.
  # libcppyy_backend_python2.X -> /usr/lib/python2.X/site-packages
  # libcppyy_backend_python3.Y -> /usr/lib/python3.Y/site-packages
  foreach(val RANGE ${how_many_pythons})
    list(GET python_executables ${val} python_executable)
    list(GET python_install_dirs ${val} python_install_dir)
    list(GET python_rel_output_dirs ${val} python_output_name)
    set(CMAKE_INSTALL_LIBDIR ${python_install_dir})
    if(IS_ABSOLUTE ${python_install_dir})
      set(d $ENV{DESTDIR}/${python_install_dir})
    else()
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${python_install_dir})
    endif()
    install(TARGETS cppyy_backend_${python_output_name} EXPORT ROOTExports DESTINATION ${python_install_dir})
    foreach(py_source ${py_sources})
      install(FILES cling/python/${py_source} DESTINATION ${python_install_dir}/cppyy_backend)
      install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
      install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
    endforeach()
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
  # Case 2: we are still building two versions, but in this case CMAKE_INSTALL_PYROOTDIR
  # was defined by the user; we then install the two libcppyy_backend libraries
  # will end up into subdirectories placed inside CMAKE_INSTALL_PYROOTDIR
  # e.g.
  # libcppyy_backend_python2.X -> CMAKE_INSTALL_PYROOTDIR/python2.X/
  # libcppyy_backend_python3.Y -> CMAKE_INSTALL_PYROOTDIR/python3.Y/
  set(orig_cmake_pyroot_dir ${CMAKE_INSTALL_PYROOTDIR})
  foreach(val RANGE ${how_many_pythons})
    list(GET python_executables ${val} python_executable)
    list(GET python_rel_output_dirs ${val} python_output_name)
    set(CMAKE_INSTALL_PYROOTDIR ${orig_cmake_pyroot_dir}/${python_output_name})
    set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
    if(IS_ABSOLUTE ${CMAKE_INSTALL_PYROOTDIR})
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PYROOTDIR})
    else()
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_PYROOTDIR})
    endif()
    install(TARGETS cppyy_backend_${python_output_name} EXPORT ROOTExports DESTINATION ${CMAKE_INSTALL_LIBDIR})
    foreach(py_source ${py_sources})
      install(FILES cling/python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy_backend)
      install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
      install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
    endforeach()
  endforeach()
else()
  # Case 3: we are building only one version, so the behavior does not change
  list(GET python_rel_output_dirs 0 python_output_name)
  install(TARGETS cppyy_backend_${python_output_name} EXPORT ROOTExports DESTINATION ${CMAKE_INSTALL_LIBDIR})
  foreach(py_source ${py_sources})
    install(FILES cling/python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy_backend)
    install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -m py_compile ${d}/${py_source})")
    install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -O -m py_compile ${d}/${py_source})")
  endforeach()
endif()
