# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(py_sources
  cppyy/_stdcpp_fix.py
  cppyy/__init__.py
  cppyy/_cpython_cppyy.py
  cppyy/_pypy_cppyy.py
  cppyy/_pythonization.py
  cppyy/_typemap.py
  cppyy/_version.py
  cppyy/interactive.py
  cppyy/ll.py
)

set(cppyyDirName python/cppyy)
file(COPY ${cppyyDirName} DESTINATION ${localruntimedir})

foreach(val RANGE ${how_many_pythons})
  list(GET python_executables ${val} python_executable)
  list(GET python_major_versions ${val} python_major_version)

  # Installation
  set(cmake_install_pyrootdir ${CMAKE_INSTALL_PY${python_major_version}ROOTDIR})
  set(CMAKE_INSTALL_LIBDIR ${cmake_install_pyrootdir})
  if(IS_ABSOLUTE ${cmake_install_pyrootdir})
    set(d $ENV{DESTDIR}/${cmake_install_pyrootdir})
  else()
    set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${cmake_install_pyrootdir})
  endif()
  foreach(py_source ${py_sources})
    install(FILES python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy)
    install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
    install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
  endforeach()

  # create egg with cppyy info
  set(cppyy_egg "${CMAKE_CURRENT_BINARY_DIR}/cppyy.egg")
  execute_process(COMMAND bash -c "touch ${cppyy_egg}; cat ${CMAKE_CURRENT_SOURCE_DIR}/python/cppyy/_version.py > ${cppyy_egg}")
endforeach()
