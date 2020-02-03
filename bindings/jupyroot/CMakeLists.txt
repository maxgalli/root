# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

#######################################################################################
# CMakeLists.txt file for building JupyROOT bindings/pyroot_experimental/PyROOT package
#######################################################################################

set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
set(JupyROOTDirName python/JupyROOT)

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_executables ${val} python_executable)
  list(GET python_rel_output_dirs ${val} python_output_name)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  ROOT_LINKER_LIBRARY(JupyROOT_${python_output_name} src/IOHandler.cxx DEPENDENCIES Core CMAKENOEXPORT)

  set_target_properties(JupyROOT_${python_output_name} PROPERTIES OUTPUT_NAME "JupyROOT")

  file(COPY ${JupyROOTDirName} DESTINATION ${python_output_dir})
  install(DIRECTORY ${JupyROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endforeach()
