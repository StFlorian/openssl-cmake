cmake_minimum_required(VERSION 3.25...3.31)

project(OpenSSL_ExternalProject LANGUAGES C)

if(NOT CMAKE_C_STANDARD)
    set(CMAKE_C_STANDARD 17)
endif()

set(OPENSSL_INSTALL_PREFIX /opt/local)
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY NO)
enable_testing()

include(openssl.cmake)

# Optionally, add OpenSSL include and library directories for other targets
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_PREFIX}/include)
set(OPENSSL_LIB_DIR ${OPENSSL_INSTALL_PREFIX}/lib)

# Display helpful messages
message(STATUS "OpenSSL will be installed to: ${OPENSSL_INSTALL_DIR}")
message(STATUS "Include directory: ${OPENSSL_INCLUDE_DIR}")
message(STATUS "Library directory: ${OPENSSL_LIB_DIR}")

set(ZLIB_DEBUG_POSTFIX)
if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(ZLIB_DEBUG_POSTFIX "d")
endif()

set(WIN32_LIBRARY_PREFIX)
if(MSVC)
    set(OPENSSL_LINK_LIBRARIES
        "optimized;ws2_32.lib;gdi32.lib;advapi32.lib;crypt32.lib;user32.lib;z.lib"
        "debug;ws2_32.lib;gdi32.lib;advapi32.lib;crypt32.lib;user32.lib;zd.lib"
    )
    set(WIN32_LIBRARY_PREFIX lib)
else()
    set(OPENSSL_LINK_LIBRARIES z${ZLIB_DEBUG_POSTFIX})
endif()


add_executable(my_app main.c)
target_include_directories(my_app PRIVATE ${OPENSSL_INCLUDE_DIR})
target_link_directories(my_app PRIVATE ${OPENSSL_LIB_DIR})
target_link_libraries(
    my_app
    PRIVATE
        ${WIN32_LIBRARY_PREFIX}ssl
        ${WIN32_LIBRARY_PREFIX}crypto
        ${OPENSSL_LINK_LIBRARIES}
)
add_dependencies(my_app openssl)
add_test(NAME my-app-h COMMAND my_app -h)

# Create a target that depends on the OpenSSL build
add_custom_target(openssl_build ALL DEPENDS openssl)

# test if the targets are usable from the install directory
add_test(
    NAME find-package-test
    COMMAND
        ${CMAKE_CTEST_COMMAND}
        # --verbose
        --output-on-failure -C $<CONFIG> --build-and-test
        "${CMAKE_CURRENT_SOURCE_DIR}/test-FindOpenSSL"
        "${CMAKE_CURRENT_BINARY_DIR}/find-package-test" --build-generator
        ${CMAKE_GENERATOR} --build-makeprogram ${CMAKE_MAKE_PROGRAM}
        --build-options "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
        "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}" "-DCMAKE_BUILD_TYPE=$<CONFIG>"
        "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
        "-DOPENSSL_INSTALL_PREFIX=${OPENSSL_INSTALL_PREFIX}"
)
