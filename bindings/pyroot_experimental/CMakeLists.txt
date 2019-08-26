# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${py_localruntimedir})
set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})

add_subdirectory(cppyy)
add_subdirectory(PyROOT)
