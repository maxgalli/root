# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

############################################################################
# CMakeLists.txt file for building ROOT bindings/pyroot_experimental package
############################################################################

if(dataframe)
    list(APPEND PYROOT_EXTRA_PYSOURCE
        ROOT/pythonization/_rdataframe.py
        ROOT/pythonization/_rtensor.py)
    list(APPEND PYROOT_EXTRA_SOURCE
        ROOT/src/RDataFramePyz.cxx
        ROOT/src/RTensorPyz.cxx)
endif()

set(py_sources
  ROOT/__init__.py
  ROOT/_application.py
  ROOT/_facade.py
  ROOT/pythonization/__init__.py
  ROOT/pythonization/_cppinstance.py
  ROOT/pythonization/_drawables.py
  ROOT/pythonization/_generic.py
  ROOT/pythonization/_rooabscollection.py
  ROOT/pythonization/_roodatahist.py
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
  ROOT/pythonization/_titer.py
  ROOT/pythonization/_tobject.py
  ROOT/pythonization/_tobjstring.py
  ROOT/pythonization/_tseqcollection.py
  ROOT/pythonization/_tstring.py
  ROOT/pythonization/_ttree.py
  ROOT/pythonization/_tvector3.py
  ROOT/pythonization/_tvectort.py
  ${PYROOT_EXTRA_PYSOURCE}
)

ROOT_STANDARD_LIBRARY_PACKAGE(ROOTPython
  HEADERS
    TPyArg.h
    TPyReturn.h
    TPython.h
  SOURCES
    ROOT/src/CppCallablePyz.cxx
    ROOT/src/PyROOTModule.cxx
    ROOT/src/PyROOTStrings.cxx
    ROOT/src/PyROOTWrapper.cxx
    ROOT/src/RPyROOTApplication.cxx
    ROOT/src/GenericPyz.cxx
    ROOT/src/RVecPyz.cxx
    ROOT/src/TClassPyz.cxx
    ROOT/src/TClonesArrayPyz.cxx
    ROOT/src/TDirectoryFilePyz.cxx
    ROOT/src/TDirectoryPyz.cxx
    ROOT/src/TFilePyz.cxx
    ROOT/src/TMemoryRegulator.cxx
    ROOT/src/TPyArg.cxx
    ROOT/src/TPyClassGenerator.cxx
    ROOT/src/TPyReturn.cxx
    ROOT/src/TPython.cxx
    ROOT/src/TObjectPyz.cxx
    ROOT/src/TTreePyz.cxx
    ROOT/src/PyzCppHelpers.cxx
    ROOT/src/PyzPythonHelpers.cxx
    ROOT/src/CPPInstancePyz.cxx
    ${PYROOT_EXTRA_SOURCE}
  DICTIONARY_OPTIONS
    -writeEmptyRootPCM
  DEPENDENCIES
    Core
    Tree
    cppyy
)

set(ROOTDirName ROOT/python/ROOT)
set(JupyROOTDirName JupyROOT/python/JupyROOT)
set(JsMVADirName JsMVA/python/JsMVA)

ROOT_LINKER_LIBRARY(JupyROOT JupyROOT/src/IOHandler.cxx DEPENDENCIES Core CMAKENOEXPORT)

#---Install python modules----------------------------------------------------------------------

file(COPY ${ROOTDirName} DESTINATION ${py_localruntimedir})
install(DIRECTORY ${ROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})

foreach(py_source ${py_sources})
  install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -m py_compile ${d}/${py_source})")
  install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -O -m py_compile ${d}/${py_source})")
endforeach()

file(COPY ${JupyROOTDirName} DESTINATION ${py_localruntimedir})
install(DIRECTORY ${JupyROOTDirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})

file(COPY ${JsMVADirName} DESTINATION ${py_localruntimedir})
install(DIRECTORY ${JsMVADirName} DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(NOT EXISTS ${localruntimedir}/python_default)
    if(WIN32)
        execute_process(COMMAND mklink ${py_localruntimedir} ${localruntimedir}/python_default)
    else()
        execute_process(COMMAND ln -s ${py_localruntimedir} ${localruntimedir}/python_default)
    endif()
endif()

# Disables warnings caused by Py_RETURN_TRUE/Py_RETURN_FALSE
if(NOT MSVC)
    target_compile_options(ROOTPython PRIVATE -Wno-strict-aliasing)
endif()

# Disables warnings originating from deprecated register keyword in Python
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(ROOTPython PRIVATE -Wno-register)
endif()
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(ROOTPython PRIVATE -Wno-deprecated-register)
endif()

ROOT_ADD_TEST_SUBDIRECTORY(ROOT/test)
