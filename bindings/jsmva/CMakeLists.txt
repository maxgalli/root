# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

####################################################################################
# CMakeLists.txt file for building JsMVA bindings/pyroot_experimental/PyROOT package
####################################################################################

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${py_localruntimedir})
set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
set(JsMVADirName python/JsMVA)

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)

  file(COPY ${JsMVADirName} DESTINATION ${python_output_dir})
  install(DIRECTORY ${JsMVADirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endforeach()
