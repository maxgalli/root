# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(headers
    inc/CPyCppyy/API.h
    inc/CPyCppyy/PyResult.h
    inc/CPyCppyy/TPyArg.h
    inc/CPyCppyy/CommonDefs.h
    inc/CPyCppyy/PyException.h
    inc/CPyCppyy/DispatchPtr.h
)

set(sources
    src/API.cxx
    src/CallContext.cxx
    src/Converters.cxx
    src/CPPClassMethod.cxx
    src/CPPConstructor.cxx
    src/CPPDataMember.cxx
    src/CPPExcInstance.cxx
    src/CPPFunction.cxx
    src/CPPInstance.cxx
    src/CPPMethod.cxx
    src/CPPOverload.cxx
    src/CPPScope.cxx
    src/CPPGetSetItem.cxx
    src/CPyCppyyModule.cxx
    src/CustomPyTypes.cxx
    src/Dispatcher.cxx
    src/DispatchPtr.cxx
    src/Executors.cxx
    src/LowLevelViews.cxx
    src/MemoryRegulator.cxx
    src/ProxyWrappers.cxx
    src/PyStrings.cxx
    src/Pythonize.cxx
    src/TemplateProxy.cxx
    src/PyException.cxx
    src/PyResult.cxx
    src/TPyArg.cxx
    src/TupleOfInstances.cxx
    src/TypeManip.cxx
    src/Utility.cxx
)

foreach(val RANGE ${how_many_pythons})
  list(GET python_abs_output_dirs ${val} python_output_dir)
  list(GET python_rel_output_dirs ${val} python_output_name)
  list(GET python_include_dirs ${val} python_include_dir)
  list(GET python_version_strings ${val} python_version_string)
  list(GET python_libraries ${val} python_library)
  list(GET python_install_dirs ${val} python_install_dir)

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${python_output_dir})

  add_library(cppyy_${python_output_name} SHARED ${headers} ${sources})

  set_target_properties(cppyy_${python_output_name} PROPERTIES OUTPUT_NAME "cppyy")

  if(NOT MSVC)
    target_compile_options(cppyy_${python_output_name} PRIVATE
      -Wno-shadow -Wno-strict-aliasing)
  endif()
  if(NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    target_compile_options(cppyy_${python_output_name} PRIVATE
      -Wno-unused-but-set-parameter)
  endif()

  # Disables warnings coming from PyCFunction casts
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND ${CMAKE_CXX_COMPILER_VERSION} VERSION_GREATER_EQUAL 8)
    target_compile_options(cppyy_${python_output_name} PRIVATE -Wno-cast-function-type)
  endif()

  # Disables warnings originating from deprecated register keyword in Python
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(cppyy_${python_output_name} PRIVATE -Wno-register)
  endif()
  if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    target_compile_options(cppyy_${python_output_name} PRIVATE -Wno-register)
    target_compile_options(cppyy_${python_output_name} PRIVATE -Wno-deprecated-register)
  endif()

  # Disables warnings due to new field tp_vectorcall in Python 3.8
  if(NOT MSVC AND ${python_version_string} VERSION_GREATER_EQUAL "3.8")
    target_compile_options(cppyy_${python_output_name} PRIVATE -Wno-missing-field-initializers)
  endif()

  target_include_directories(cppyy_${python_output_name} PRIVATE ${CMAKE_BINARY_DIR}/include) # needed for string_view backport

  target_include_directories(cppyy_${python_output_name} PUBLIC ${python_include_dir}
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)
  target_link_libraries(cppyy_${python_output_name} cppyy_backend_${python_output_name} ${python_library})

  set_property(GLOBAL APPEND PROPERTY ROOT_EXPORTED_TARGETS cppyy_${python_output_name})
endforeach()

# Installation
if(cmake14 AND DEFINED python_install_dirs)
  # Case 1: we are building PyROOT with two versions (cmake > 3.14) and, since
  # python_install_dirs is defined, CMAKE_INSTALL_PYROOTDIR wasn't defined by
  # the user (see RootInstallDirs)
  # We install each target in the default Python paths related to the Python
  # version it was built with
  # e.g.
  # libcppyy_python2.X -> /usr/lib/python2.X/site-packages
  # libcppyy_python3.Y -> /usr/lib/python3.Y/site-packages
  foreach(val RANGE ${how_many_pythons})
    list(GET python_install_dirs ${val} python_install_dir)
    list(GET python_rel_output_dirs ${val} python_output_name)
    set(CMAKE_INSTALL_LIBDIR ${python_install_dir})
    install(TARGETS cppyy_${python_output_name} EXPORT ${CMAKE_PROJECT_NAME}Exports DESTINATION ${python_install_dir})
    install(FILES ${headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/CPyCppyy)
  endforeach()
elseif(cmake14 AND NOT DEFINED python_install_dirs)
  # Case 2: we are still building two versions, but in this case CMAKE_INSTALL_PYROOTDIR
  # was defined by the user; we then install the two libcppyy libraries
  # will end up into subdirectories placed inside CMAKE_INSTALL_PYROOTDIR
  # e.g.
  # libcppyy_python2.X -> CMAKE_INSTALL_PYROOTDIR/python2.X/
  # libcppyy_python3.Y -> CMAKE_INSTALL_PYROOTDIR/python3.Y/
  set(orig_cmake_pyroot_dir ${CMAKE_INSTALL_PYROOTDIR})
  foreach(python_output_name ${python_rel_output_dirs})
    set(CMAKE_INSTALL_PYROOTDIR ${orig_cmake_pyroot_dir}/${python_output_name})
    set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_PYROOTDIR})
    install(TARGETS cppyy_${python_output_name} EXPORT ${CMAKE_PROJECT_NAME}Exports DESTINATION ${CMAKE_INSTALL_PYROOTDIR})
    install(FILES ${headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/CPyCppyy)
  endforeach()
else()
  # Case 3: we are building only one version, so the behavior does not change
  list(GET python_rel_output_dirs 0 python_output_name)
  install(TARGETS cppyy_${python_output_name} EXPORT ${CMAKE_PROJECT_NAME}Exports DESTINATION ${CMAKE_INSTALL_PYROOTDIR})
  install(FILES ${headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/CPyCppyy)
endif()

file(COPY ${headers} DESTINATION ${CMAKE_BINARY_DIR}/include/CPyCppyy)
