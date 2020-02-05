# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

##################################################################################################
# CMakeLists.txt file for building ROOT bindings/pyroot_experimental/pythonizations/PyROOT package
##################################################################################################

if(dataframe)
    list(APPEND PYROOT_EXTRA_PYSOURCE
        ROOT/pythonization/_rdataframe.py
        ROOT/pythonization/_rtensor.py)
    list(APPEND PYROOT_EXTRA_SOURCE
        src/RDataFramePyz.cxx
        src/RTensorPyz.cxx)
endif()

set(py_sources
  ROOT/__init__.py
  ROOT/_application.py
  ROOT/_facade.py
  ROOT/pythonization/__init__.py
  ROOT/pythonization/_cppinstance.py
  ROOT/pythonization/_drawables.py
  ROOT/pythonization/_generic.py
  ROOT/pythonization/_rbdt.py
  ROOT/pythonization/_rooabscollection.py
  ROOT/pythonization/_roodatahist.py
  ROOT/pythonization/_roodataset.py
  ROOT/pythonization/_rvec.py
  ROOT/pythonization/_stl_vector.py
  ROOT/pythonization/_tarray.py
  ROOT/pythonization/_tclonesarray.py
  ROOT/pythonization/_tcollection.py
  ROOT/pythonization/_tcomplex.py
  ROOT/pythonization/_tdirectory.py
  ROOT/pythonization/_tdirectoryfile.py
  ROOT/pythonization/_tfile.py
  ROOT/pythonization/_tgraph.py
  ROOT/pythonization/_th1.py
  ROOT/pythonization/_th2.py
  ROOT/pythonization/_titer.py
  ROOT/pythonization/_tobject.py
  ROOT/pythonization/_tobjstring.py
  ROOT/pythonization/_tree_inference.py
  ROOT/pythonization/_tseqcollection.py
  ROOT/pythonization/_tstring.py
  ROOT/pythonization/_ttree.py
  ROOT/pythonization/_tvector3.py
  ROOT/pythonization/_tvectort.py
  ${PYROOT_EXTRA_PYSOURCE}
)

set(cpp_sources
    src/CppCallablePyz.cxx
    src/PyROOTModule.cxx
    src/PyROOTStrings.cxx
    src/PyROOTWrapper.cxx
    src/RPyROOTApplication.cxx
    src/GenericPyz.cxx
    src/RVecPyz.cxx
    src/TClassPyz.cxx
    src/TClonesArrayPyz.cxx
    src/TDirectoryFilePyz.cxx
    src/TDirectoryPyz.cxx
    src/TFilePyz.cxx
    src/TMemoryRegulator.cxx
    src/TObjectPyz.cxx
    src/TTreePyz.cxx
    src/PyzCppHelpers.cxx
    src/PyzPythonHelpers.cxx
    src/CPPInstancePyz.cxx
    ${PYROOT_EXTRA_SOURCE}
)

set(ROOTDirName python/ROOT)
set(ROOT_headers inc)

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_rel_output_dirs ${val} python_output_name)
  list(GET python_include_dirs ${val} python_include_dir)
  list(GET python_executables ${val} python_executable)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  if(cmake14)
  ROOT_LINKER_LIBRARY(ROOTPythonizations_${python_output_name} ${cpp_sources} DEPENDENCIES Core Tree cppyy_${python_output_name} CMAKENOEXPORT NOINSTALL)
  else()
  ROOT_LINKER_LIBRARY(ROOTPythonizations_${python_output_name} ${cpp_sources} DEPENDENCIES Core Tree cppyy_${python_output_name} CMAKENOEXPORT)
  endif()

  target_include_directories(ROOTPythonizations_${python_output_name} PRIVATE ${ROOT_headers} ${python_include_dir})

  file(COPY ${ROOTDirName} DESTINATION ${python_output_dir})

  set_target_properties(ROOTPythonizations_${python_output_name} PROPERTIES OUTPUT_NAME "ROOTPythonizations")

  # Disables warnings caused by Py_RETURN_TRUE/Py_RETURN_FALSE
  if(NOT MSVC)
    target_compile_options(ROOTPythonizations_${python_output_name} PRIVATE -Wno-strict-aliasing)
  endif()

  # Disables warnings originating from deprecated register keyword in Python
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(ROOTPythonizations_${python_output_name} PRIVATE -Wno-register)
  endif()
  if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(ROOTPythonizations_${python_output_name} PRIVATE -Wno-register)
    target_compile_options(ROOTPythonizations_${python_output_name} PRIVATE -Wno-deprecated-register)
  endif()

  # create egg with PyROOT info
  set(ROOT_egg "${CMAKE_CURRENT_BINARY_DIR}/PyROOT.egg")
  file(WRITE ${ROOT_egg} "PyROOT ${ROOT_VERSION}")
endforeach()

# Installation
if(cmake14 AND DEFINED python_install_dirs)
  # Case 1: we are building PyROOT with two versions (cmake > 3.14) and, since
  # python_install_dirs is defined, CMAKE_INSTALL_PYROOTDIR wasn't defined by
  # the user (see RootInstallDirs)
  # We install each target in the default Python paths related to the Python
  # version it was built with
  # e.g.
  # libROOTPythonizations_python2.X -> /usr/lib/python2.X/site-packages
  # libROOTPythonizations_python3.Y -> /usr/lib/python3.Y/site-packages
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
    install(DIRECTORY ${ROOTDirName} DESTINATION ${python_install_dir})
    install(TARGETS ROOTPythonizations_${python_output_name} DESTINATION ${python_install_dir})
    foreach(py_source ${py_sources})
      install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
      install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
    endforeach()
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
  # Case 2: we are still building two versions, but in this case CMAKE_INSTALL_PYROOTDIR
  # was defined by the user; we then install the two libROOTPythonization libraries
  # will end up into subdirectories placed inside CMAKE_INSTALL_PYROOTDIR
  # e.g.
  # libROOTPythonizations_python2.X -> CMAKE_INSTALL_PYROOTDIR/python2.X/
  # libROOTPythonizations_python3.Y -> CMAKE_INSTALL_PYROOTDIR/python3.Y/
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
    install(DIRECTORY ${ROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
    install(TARGETS ROOTPythonizations_${python_output_name} DESTINATION ${CMAKE_INSTALL_LIBDIR})
    foreach(py_source ${py_sources})
      install(CODE "execute_process(COMMAND ${python_executable} -m py_compile ${d}/${py_source})")
      install(CODE "execute_process(COMMAND ${python_executable} -O -m py_compile ${d}/${py_source})")
    endforeach()
  endforeach()
else()
  # Case 3: we are building only one version, so the behavior does not change
  install(DIRECTORY ${ROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
  foreach(py_source ${py_sources})
    install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -m py_compile ${d}/${py_source})")
    install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -O -m py_compile ${d}/${py_source})")
  endforeach()
endif()

# Copy headers inside build_dir/include/Pythonizations
file(COPY ${ROOT_headers}/ DESTINATION ${CMAKE_BINARY_DIR}/include/ROOT)

ROOT_ADD_TEST_SUBDIRECTORY(test)
