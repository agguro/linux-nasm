#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "OpenXLSX::OpenXLSX-static" for configuration ""
set_property(TARGET OpenXLSX::OpenXLSX-static APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(OpenXLSX::OpenXLSX-static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libOpenXLSX-static.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS OpenXLSX::OpenXLSX-static )
list(APPEND _IMPORT_CHECK_FILES_FOR_OpenXLSX::OpenXLSX-static "${_IMPORT_PREFIX}/lib/libOpenXLSX-static.a" )

# Import target "OpenXLSX::OpenXLSX-shared" for configuration ""
set_property(TARGET OpenXLSX::OpenXLSX-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(OpenXLSX::OpenXLSX-shared PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libOpenXLSX-shared.so"
  IMPORTED_SONAME_NOCONFIG "libOpenXLSX-shared.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS OpenXLSX::OpenXLSX-shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_OpenXLSX::OpenXLSX-shared "${_IMPORT_PREFIX}/lib/libOpenXLSX-shared.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
