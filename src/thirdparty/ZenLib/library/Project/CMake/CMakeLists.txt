cmake_minimum_required(VERSION 3.0)

project(ZenLib VERSION 0.4.36)

if(WIN32)
  option(BUILD_SHARED_LIBS "Build shared libs" OFF)
else()
  option(BUILD_SHARED_LIBS "Build shared libs" ON)
endif()

option(ENABLE_UNICODE "Enable unicode support" ON)
option(LARGE_FILES "Enable large files support" ON)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/Modules/")
set(ZenLib_SOURCES_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../Source)

# On Windows debug library should have 'd' postfix.
if(WIN32)
  set(CMAKE_DEBUG_POSTFIX "d")
elseif(APPLE)
  set(CMAKE_DEBUG_POSTFIX "_debug")
endif()

include(GNUInstallDirs)

set(LIB_SUFFIX "" CACHE STRING "Define suffix of directory name (32/64)" )
set(BIN_INSTALL_DIR "${CMAKE_INSTALL_FULL_BINDIR}" CACHE STRING "Directory where binary will install")
set(LIB_INSTALL_DIR "${CMAKE_INSTALL_FULL_LIBDIR}" CACHE STRING "Directory where library will install")
set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_FULL_INCLUDEDIR}" CACHE PATH "The directory the headers are installed in")

if(NOT MSVC)
  set(ZenLib_CONFIG_INSTALL_DIR "${LIB_INSTALL_DIR}/cmake/zenlib")
else()
  set(ZenLib_CONFIG_INSTALL_DIR "cmake")
endif()

set(ZenLib_HDRS
  ${ZenLib_SOURCES_PATH}/ZenLib/BitStream.h
  ${ZenLib_SOURCES_PATH}/ZenLib/BitStream_Fast.h
  ${ZenLib_SOURCES_PATH}/ZenLib/BitStream_LE.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Conf.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Conf_Internal.h
  ${ZenLib_SOURCES_PATH}/ZenLib/CriticalSection.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Dir.h
  ${ZenLib_SOURCES_PATH}/ZenLib/File.h
  ${ZenLib_SOURCES_PATH}/ZenLib/FileName.h
  ${ZenLib_SOURCES_PATH}/ZenLib/InfoMap.h
  ${ZenLib_SOURCES_PATH}/ZenLib/MemoryDebug.h
  ${ZenLib_SOURCES_PATH}/ZenLib/OS_Utils.h
  ${ZenLib_SOURCES_PATH}/ZenLib/PreComp.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Thread.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Trace.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Translation.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Utils.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Ztring.h
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringList.h
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringListList.h
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringListListF.h
  ${ZenLib_SOURCES_PATH}/ZenLib/int128s.h
  ${ZenLib_SOURCES_PATH}/ZenLib/int128u.h
  )

set(ZenLib_format_html_HDRS
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Html/Html_Handler.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Html/Html_Request.h
  )

set(ZenLib_format_http_HDRS
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Cookies.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Handler.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Request.h
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Utils.h
  )

set(ZenLib_SRCS
  ${ZenLib_SOURCES_PATH}/ZenLib/Conf.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/CriticalSection.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Dir.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/File.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/FileName.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/InfoMap.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/int128s.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/int128u.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/MemoryDebug.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/OS_Utils.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Translation.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Thread.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Utils.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Ztring.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringList.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringListList.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/ZtringListListF.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Html/Html_Handler.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Html/Html_Request.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Cookies.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Handler.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Request.cpp
  ${ZenLib_SOURCES_PATH}/ZenLib/Format/Http/Http_Utils.cpp
  )

add_library(zen ${ZenLib_SRCS} ${ZenLib_HDRS} ${ZenLib_format_html_HDRS} ${ZenLib_format_http_HDRS})
if(ENABLE_UNICODE)
  set(ZenLib_Unicode "yes")
  set(ZenLib_CXXFLAGS -DUNICODE) # For pkg-config template
  target_compile_definitions(zen PUBLIC UNICODE _UNICODE)
else()
  set(ZenLib_Unicode "no")
endif()

if(LARGE_FILES)
  include(TestLargeFiles)

  test_large_files(_LARGEFILES)
  target_compile_definitions(zen PUBLIC ${LARGE_FILES_DEFINITIONS})
endif()

include(CheckTypeSize)
check_type_size(size_t SIZE_T_SIZE)
check_type_size(long LONG_SIZE)
if((LONG_SIZE GREATER 4) AND (SIZE_T_SIZE EQUAL LONG_SIZE))
  target_compile_definitions(zen PUBLIC SIZE_T_IS_LONG)
endif()

target_include_directories(zen PUBLIC
  $<BUILD_INTERFACE:${ZenLib_SOURCES_PATH}>
  $<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}>)

set_target_properties(zen PROPERTIES
  VERSION ${ZenLib_VERSION}
  SOVERSION ${ZenLib_VERSION_MAJOR}
  PUBLIC_HEADER "${ZenLib_HDRS}"
  )

if(MSVC)
  install(FILES $<TARGET_PDB_FILE:zen> DESTINATION ${BIN_INSTALL_DIR} CONFIGURATIONS "Debug;RelWithDebInfo" OPTIONAL)
endif()

install(TARGETS zen EXPORT zen-export
  PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR}/ZenLib
  RUNTIME DESTINATION ${BIN_INSTALL_DIR}
  ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
  LIBRARY DESTINATION ${LIB_INSTALL_DIR})

install(FILES ${ZenLib_format_html_HDRS} DESTINATION ${INCLUDE_INSTALL_DIR}/ZenLib/Format/Html)
install(FILES ${ZenLib_format_http_HDRS} DESTINATION ${INCLUDE_INSTALL_DIR}/ZenLib/Format/Http)

install(EXPORT zen-export DESTINATION ${ZenLib_CONFIG_INSTALL_DIR} FILE ZenLibTargets.cmake)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

# pkg-config
find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/libzen.pc.in
                 ${CMAKE_CURRENT_BINARY_DIR}/libzen.pc
                 @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libzen.pc
          DESTINATION ${LIB_INSTALL_DIR}/pkgconfig)
endif()

# cmake-modules
include(CMakePackageConfigHelpers)
configure_package_config_file(
  ZenLibConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/ZenLibConfig.cmake"
  INSTALL_DESTINATION ${ZenLib_CONFIG_INSTALL_DIR}
  PATH_VARS INCLUDE_INSTALL_DIR)

write_basic_config_version_file(ZenLibConfigVersion.cmake COMPATIBILITY AnyNewerVersion)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/ZenLibConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/ZenLibConfigVersion.cmake
  DESTINATION ${ZenLib_CONFIG_INSTALL_DIR})

if(NOT TARGET uninstall)
  add_custom_target(uninstall
    "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")
endif()
