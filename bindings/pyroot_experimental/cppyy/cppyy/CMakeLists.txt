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

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_executables ${val} python_executable)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  foreach(py_source ${py_sources})
    file(COPY python/${py_source} DESTINATION ${python_output_dir}/cppyy)
  endforeach()

  # create egg with cppyy info
  set(cppyy_egg "${CMAKE_CURRENT_BINARY_DIR}/cppyy.egg")
  execute_process(COMMAND bash -c "touch ${cppyy_egg}; cat ${CMAKE_CURRENT_SOURCE_DIR}/python/cppyy/_version.py > ${cppyy_egg}")
endforeach()

# installation
if(cmake14 AND DEFINED python_install_dirs)
  foreach(val RANGE ${how_many_pythons})
    list(GET python_executables ${val} python_executable)
    list(GET python_install_dirs ${val} python_install_dir)
    set(CMAKE_INSTALL_LIBDIR ${python_install_dir})
    if(IS_ABSOLUTE ${python_install_dir})
      set(d $ENV{DESTDIR}/${python_install_dir})
    else()
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${python_install_dir})
    endif()
      foreach(py_source ${py_sources})
        install(FILES python/${py_source} DESTINATION ${python_install_dir}/cppyy)
        install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
        install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
      endforeach()
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
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
    foreach(py_source ${py_sources})
      install(FILES python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy)
      install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
      install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
    endforeach()
  endforeach()
else()
  foreach(py_source ${py_sources})
    install(FILES python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy)
    install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
    install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
  endforeach()
endif()

