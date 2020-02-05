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

foreach(python_output_dir ${python_abs_output_dirs})
  file(COPY ${JsMVADirName} DESTINATION ${python_output_dir})
endforeach()

# Installation
if(cmake14 AND DEFINED python_install_dirs)
  foreach(python_install_dir ${python_install_dirs})
    install(DIRECTORY ${JsMVADirName} DESTINATION ${python_install_dir})
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
  set(orig_cmake_pyroot_dir ${CMAKE_INSTALL_PYROOTDIR})
  foreach(python_output_name ${python_rel_output_dirs})
    set(CMAKE_INSTALL_PYROOTDIR ${orig_cmake_pyroot_dir}/${python_output_name})
    set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
    install(DIRECTORY ${JsMVADirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
  endforeach()
else()
  install(DIRECTORY ${JsMVADirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif()
