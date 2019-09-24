# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

#######################################################################################
# CMakeLists.txt file for building JupyROOT bindings/pyroot_experimental/PyROOT package
#######################################################################################

set(JupyROOTDirName python/JupyROOT)

# call setup
set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
set(DEPS Core)
#set(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/python/build/timestamp")

configure_file(${SETUP_PY_IN} ${SETUP_PY})

add_custom_target(JupyROOT
        ALL
        COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build
        --build-base=${py_localruntimedir}
        DEPENDS ${DEPS})

install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} install --prefix=${CMAKE_INSTALL_PYROOTDIR})")



#ROOT_LINKER_LIBRARY(JupyROOT src/IOHandler.cxx DEPENDENCIES Core CMAKENOEXPORT)

#file(COPY ${JupyROOTDirName} DESTINATION ${py_localruntimedir})
#install(DIRECTORY ${JupyROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
