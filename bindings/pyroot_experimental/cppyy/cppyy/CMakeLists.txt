# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

set(py_sources
  cppyy/_stdcpp_fix.py
  cppyy/__init__.py
  cppyy/_cpython_cppyy.py
  cppyy/_pypy_cppyy.py
  cppyy/_pythonization.py
  cppyy/_typemap.py
  cppyy/_version.py
  cppyy/interactive.py
)

# call setup
set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
#set(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/python/build/timestamp")

configure_file(${SETUP_PY_IN} ${SETUP_PY})

#[[
add_custom_command(OUTPUT ${OUTPUT}
        COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build
        --build-base=${py_localruntimedir}
        COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
        DEPENDS ${DEPS})
]]
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build
        --build-base=${py_localruntimedir})

install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} install --prefix=${CMAKE_INSTALL_PYROOTDIR})")



#[[
foreach(py_source ${py_sources})
  file(COPY python/${py_source} DESTINATION ${py_localruntimedir}/cppyy)
  install(FILES python/${py_source} DESTINATION ${CMAKE_INSTALL_LIBDIR}/cppyy)
  install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -m py_compile ${d}/${py_source})")
  install(CODE "execute_process(COMMAND ${PYTHON_EXECUTABLE} -O -m py_compile ${d}/${py_source})")
endforeach()
]]
