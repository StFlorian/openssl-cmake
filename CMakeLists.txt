cmake_minimum_required(VERSION 3.25...3.31)

project(OpenSSL_ExternalProject LANGUAGES C)

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
