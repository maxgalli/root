# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

#---Check for Python installation-------------------------------------------------------

message(STATUS "Looking for python")

if(pyroot_experimental)
  unset(PYTHON_INCLUDE_DIR CACHE)
  unset(PYTHON_LIBRARY CACHE)
endif()

# Python is required by header and manpage generation

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.14)

  set(cmake14 ON)

  if(PYTHON_EXECUTABLE)
    execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys;print(sys.version_info[0])"
                    OUTPUT_VARIABLE PYTHON_PREFER_VERSION
                    ERROR_VARIABLE PYTHON_PREFER_VERSION_ERR)
    if(PYTHON_PREFER_VERSION_ERR)
      message(WARNING "Unable to determine version of ${PYTHON_EXECUTABLE}: ${PYTHON_PREFER_VERSION_ERR}")
    endif()
    string(STRIP "${PYTHON_PREFER_VERSION}" PYTHON_PREFER_VERSION)
    set(Python${PYTHON_PREFER_VERSION}_EXECUTABLE "${PYTHON_EXECUTABLE}")
  endif()

  find_package(Python3 COMPONENTS Interpreter Development)
  if(Python3_Development_FOUND)
    # Re-run, now with NumPy, but not required:
    find_package(Python3 COMPONENTS NumPy)
    # Compat with find_package(PythonInterp), find_package(PythonLibs)
    set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
    set(PYTHON_INCLUDE_DIRS "${Python3_INCLUDE_DIRS}")
    set(PYTHON_LIBRARIES "${Python3_LIBRARIES}")
    set(PYTHON_VERSION_MAJOR "${Python3_VERSION_MAJOR}")
    set(PYTHON_VERSION_MINOR "${Python3_VERSION_MINOR}")
    set(PYTHON_VERSION_STRING "${Python3_VERSION_MAJOR}_${Python3_VERSION_MINOR}")
    set(NUMPY_FOUND ${Python3_NumPy_FOUND})
    set(NUMPY_INCLUDE_DIRS "${Python3_NumPy_INCLUDE_DIRS}")
  endif()

  find_package(Python2 COMPONENTS Interpreter Development)
  if(Python2_Development_FOUND)
    # Re-run, now with NumPy, but not required:
    find_package(Python2 COMPONENTS NumPy)
    if(NOT Python3_Development_FOUND)
      # Compat with find_package(PythonInterp), find_package(PythonLibs)
      set(PYTHON_EXECUTABLE "${Python2_EXECUTABLE}")
      set(PYTHON_INCLUDE_DIRS "${Python2_INCLUDE_DIRS}")
      set(PYTHON_LIBRARIES "${Python2_LIBRARIES}")
      set(PYTHON_VERSION_MAJOR "${Python2_VERSION_MAJOR}")
      set(PYTHON_VERSION_MINOR "${Python2_VERSION_MINOR}")
      set(PYTHON_VERSION_STRING "${Python2_VERSION_MAJOR}_${Python2_VERSION_MINOR}")
      set(NUMPY_FOUND ${Python2_NumPy_FOUND})
      set(NUMPY_INCLUDE_DIRS "${Python2_NumPy_INCLUDE_DIRS}")
    else()
      set(OTHER_PYTHON_EXECUTABLE "${Python2_EXECUTABLE}")
      set(OTHER_PYTHON_INCLUDE_DIRS "${Python2_INCLUDE_DIRS}")
      set(OTHER_PYTHON_LIBRARIES "${Python2_LIBRARIES}")
      set(OTHER_PYTHON_VERSION_MAJOR "${Python2_VERSION_MAJOR}")
      set(OTHER_PYTHON_VERSION_MINOR "${Python2_VERSION_MINOR}")
      set(OTHER_PYTHON_VERSION_STRING "${Python2_VERSION_MAJOR}_${Python2_VERSION_MINOR}")
      set(OTHER_NUMPY_FOUND ${Python2_NumPy_FOUND})
      set(OTHER_NUMPY_INCLUDE_DIRS "${Python2_NumPy_INCLUDE_DIRS}")
    endif()
  endif()

  if(NOT Python3_Development_FOUND AND NOT Python2_Development_FOUND)
    message(FATAL_ERROR "No Python 2 or 3 were found")
  endif()

else()

  find_package(PythonInterp ${python_version} REQUIRED)
  find_package(PythonLibs ${python_version} REQUIRED)

  if(NOT "${PYTHONLIBS_VERSION_STRING}" MATCHES "${PYTHON_VERSION_STRING}")
    message(FATAL_ERROR "Version mismatch between Python interpreter (${PYTHON_VERSION_STRING})"
    " and libraries (${PYTHONLIBS_VERSION_STRING}).\nROOT cannot work with this configuration. "
    "Please specify only PYTHON_EXECUTABLE to CMake with an absolute path to ensure matching versions are found.")
  endif()

  find_package(NumPy)

  set(PYTHON_VERSION_STRING "${PYTHON_VERSION_MAJOR}_${PYTHON_VERSION_MINOR}")

endif()

# create lists of Python 2 and 3 useful variables
set(python_executables ${PYTHON_EXECUTABLE} ${OTHER_PYTHON_EXECUTABLE})
set(python_include_dirs ${PYTHON_INCLUDE_DIRS} ${OTHER_PYTHON_INCLUDE_DIRS})
set(python_version_strings ${PYTHON_VERSION_STRING} ${OTHER_PYTHON_VERSION_STRING})
set(python_major_versions ${PYTHON_VERSION_MAJOR} ${OTHER_PYTHON_VERSION_MAJOR})
set(python_minor_versions ${PYTHON_VERSION_MINOR} ${OTHER_PYTHON_VERSION_MINOR})
set(python_libraries ${PYTHON_LIBRARIES} ${OTHER_PYTHON_LIBRARIES})

# Machinary necessary to loop in parallel over multiple lists
list(LENGTH python_executables len)
math(EXPR how_many_pythons "${len} - 1")
