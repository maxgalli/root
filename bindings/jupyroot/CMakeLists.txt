# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

#######################################################################################
# CMakeLists.txt file for building JupyROOT bindings/pyroot_experimental/PyROOT package
#######################################################################################

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${py_localruntimedir})
set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
set(JupyROOTDirName python/JupyROOT)

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_executables ${val} python_executable)
  list(GET python_rel_output_dirs ${val} python_output_name)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  if(cmake14)
    ROOT_LINKER_LIBRARY(JupyROOT_${python_output_name} src/IOHandler.cxx DEPENDENCIES Core CMAKENOEXPORT NOINSTALL)
  else()
    ROOT_LINKER_LIBRARY(JupyROOT_${python_output_name} src/IOHandler.cxx DEPENDENCIES Core CMAKENOEXPORT)
  endif()

  set_target_properties(JupyROOT_${python_output_name} PROPERTIES OUTPUT_NAME "JupyROOT")

  file(COPY ${JupyROOTDirName} DESTINATION ${python_output_dir})
endforeach()

# Installation
if(cmake14 AND DEFINED python_install_dirs)
  # Case 1: we are building PyROOT with two versions (cmake > 3.14) and, since
  # python_install_dirs is defined, CMAKE_INSTALL_PYROOTDIR wasn't defined by
  # the user (see RootInstallDirs)
  # We install each target in the default Python paths related to the Python
  # version it was built with
  # e.g.
  # libJupyROOT_python2.X -> /usr/lib/python2.X/site-packages
  # libJupyROOT_python3.Y -> /usr/lib/python3.Y/site-packages
  foreach(val RANGE ${how_many_pythons})
    list(GET python_install_dirs ${val} python_install_dir)
    list(GET python_rel_output_dirs ${val} python_output_name)
    set(CMAKE_INSTALL_LIBDIR ${python_install_dir})
    if(IS_ABSOLUTE ${python_install_dir})
      set(d $ENV{DESTDIR}/${python_install_dir})
    else()
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${python_install_dir})
    endif()
    install(DIRECTORY ${JupyROOTDirName} DESTINATION ${python_install_dir})
    install(TARGETS JupyROOT_${python_output_name} DESTINATION ${python_install_dir})
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
  # Case 2: we are still building two versions, but in this case CMAKE_INSTALL_PYROOTDIR
  # was defined by the user; we then install the two libJupyROOT libraries
  # will end up into subdirectories placed inside CMAKE_INSTALL_PYROOTDIR
  # e.g.
  # libJupyROOT_python2.X -> CMAKE_INSTALL_PYROOTDIR/python2.X/
  # libJupyROOT_python3.Y -> CMAKE_INSTALL_PYROOTDIR/python3.Y/
  set(orig_cmake_pyroot_dir ${CMAKE_INSTALL_PYROOTDIR})
  foreach(python_output_name ${python_rel_output_dirs})
    set(CMAKE_INSTALL_PYROOTDIR ${orig_cmake_pyroot_dir}/${python_output_name})
    set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
    if(IS_ABSOLUTE ${CMAKE_INSTALL_PYROOTDIR})
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PYROOTDIR})
    else()
      set(d $ENV{DESTDIR}/${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_PYROOTDIR})
    endif()
    install(DIRECTORY ${JupyROOTDirName} DESTINATION ${CMAKE_INSTALL_PYROOTDIR})
    install(TARGETS JupyROOT_${python_output_name} DESTINATION ${CMAKE_INSTALL_LIBDIR})
  endforeach()
else()
  # Case 3: we are building only one version, so the behavior does not change
  install(DIRECTORY ${JupyROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif()
