# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")

add_subdirectory(ROOT)
add_subdirectory(JupyROOT)
add_subdirectory(JsMVA)

if(NOT EXISTS ${localruntimedir}/python_default)
    if(WIN32)
        execute_process(COMMAND mklink ${py_localruntimedir} ${localruntimedir}/python_default)
    else()
        execute_process(COMMAND ln -s ${py_localruntimedir} ${localruntimedir}/python_default)
    endif()
endif()
