INCLUDE(CheckCXXSourceRuns)
INCLUDE(ExternalProject)

SET(WITH_LIBFMT "auto" CACHE STRING
   "Which libfmt to use (possible values are 'bundled', 'system', or 'auto')")

MACRO(BUNDLE_LIBFMT)
  # Set the directory where libfmt is expected to be located
  SET(dir "${CMAKE_BINARY_DIR}/extra/libfmt")
  SET(LIBFMT_INCLUDE_DIR "${dir}/include")

  # Assuming that libfmt is already extracted and built in the specified directory
  IF(NOT EXISTS "${LIBFMT_INCLUDE_DIR}/fmt/format.h")
    MESSAGE(FATAL_ERROR "The specified directory does not contain the expected libfmt headers.")
  ENDIF()

  # Set the include directory for libfmt
  INCLUDE_DIRECTORIES(${LIBFMT_INCLUDE_DIR})
ENDMACRO()

MACRO (CHECK_LIBFMT)
  IF(WITH_LIBFMT STREQUAL "system" OR WITH_LIBFMT STREQUAL "auto")
    # Assume libfmt is provided in the specified directory
    SET(CMAKE_REQUIRED_INCLUDES ${LIBFMT_INCLUDE_DIR})
    CHECK_CXX_SOURCE_RUNS(
    "#define FMT_STATIC_THOUSANDS_SEPARATOR ','
     #define FMT_HEADER_ONLY 1
     #include <fmt/format-inl.h>
     int main() {
       int answer= 4321;
       fmt::format_args::format_arg arg=
         fmt::detail::make_arg<fmt::format_context>(answer);
       return fmt::vformat(\"{:L}\", fmt::format_args(&arg, 1)).compare(\"4,321\");
     }" HAVE_SYSTEM_LIBFMT)
    SET(CMAKE_REQUIRED_INCLUDES)
  ENDIF()
  
  IF(NOT HAVE_SYSTEM_LIBFMT OR WITH_LIBFMT STREQUAL "bundled")
    IF (WITH_LIBFMT STREQUAL "system")
      MESSAGE(FATAL_ERROR "System libfmt library is not found or unusable")
    ENDIF()
    BUNDLE_LIBFMT()
  ELSE()
    FIND_FILE(Libfmt_core_h fmt/core.h) # for build_depends.cmake
  ENDIF()
ENDMACRO()

MARK_AS_ADVANCED(LIBFMT_INCLUDE_DIR)
