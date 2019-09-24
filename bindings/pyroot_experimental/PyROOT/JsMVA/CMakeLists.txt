# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

####################################################################################
# CMakeLists.txt file for building JsMVA bindings/pyroot_experimental/PyROOT package
####################################################################################

#set(JsMVADirName python/JsMVA)

# call setup
set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")

configure_file(${SETUP_PY_IN} ${SETUP_PY})

execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build
        --build-base=${py_localruntimedir})

install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} install --prefix=${CMAKE_INSTALL_PYROOTDIR})")


#file(COPY ${JsMVADirName} DESTINATION ${py_localruntimedir})
#install(DIRECTORY ${JsMVADirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})
