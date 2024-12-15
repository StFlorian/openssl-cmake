cmake_minimum_required(VERSION 3.25...3.31)

project(OpenSSL_ExternalProject LANGUAGES C)

if(NOT CMAKE_C_STANDARD)
    set(CMAKE_C_STANDARD 17)
endif()

include(ExternalProject)

set(OPENSSL_INSTALL_PREFIX /opt/local)

include(openssl.cmake)

# Optionally, add OpenSSL include and library directories for other targets
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_PREFIX}/include)
set(OPENSSL_LIB_DIR ${OPENSSL_INSTALL_PREFIX}/lib)

# Display helpful messages
message(STATUS "OpenSSL will be installed to: ${OPENSSL_INSTALL_DIR}")
message(STATUS "Include directory: ${OPENSSL_INCLUDE_DIR}")
message(STATUS "Library directory: ${OPENSSL_LIB_DIR}")

add_executable(my_app main.c)
target_include_directories(my_app PRIVATE ${OPENSSL_INCLUDE_DIR})
target_link_directories(my_app PRIVATE ${OPENSSL_LIB_DIR})
target_link_libraries(my_app PRIVATE ssl crypto)
add_dependencies(my_app openssl_build)

# Create a target that depends on the OpenSSL build
add_custom_target(openssl_build ALL DEPENDS openssl)

set(CMAKE_SKIP_TEST_ALL_DEPENDENCY NO)
enable_testing()

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
        "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}"
        "-DCMAKE_BUILD_TYPE=$<CONFIG>"
        "-DCMAKE_PREFIX_PATH=${OPENSSL_INSTALL_PREFIX}"
)
