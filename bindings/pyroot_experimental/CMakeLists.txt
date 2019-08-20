# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(original_library_output_directory ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
set(python_build_directory ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/python${PYTHON_VERSION_STRING})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_build_directory}/ROOT)

set(localruntimedir ${python_build_directory})
set(runtimedir ${CMAKE_INSTALL_LIBDIR}/python${PYTHON_VERSION_STRING})

add_subdirectory(cppyy)
add_subdirectory(PyROOT)
