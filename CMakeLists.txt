cmake_minimum_required(VERSION 3.25...3.31)
project(OpenSSL_ExternalProject LANGUAGES C)

include(ExternalProject)

# Set OpenSSL version and source location
set(OPENSSL_VERSION "3.4.0") # Ändere die Version bei Bedarf
set(OPENSSL_URL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz")

# Define installation directory
set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl-install)

# Add ExternalProject to download, configure, and build OpenSSL
if(OPENSSL_INSTALL_DIR)
  ExternalProject_Add(
    openssl
    URL ${OPENSSL_URL}
    URL_HASH SHA256=e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf
    PREFIX ${CMAKE_BINARY_DIR}/openssl-src
    SOURCE_SUBDIR .
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/openssl-src/src/openssl/config --prefix=${OPENSSL_INSTALL_DIR}
                      --openssldir=${OPENSSL_INSTALL_DIR}/ssl
    BUILD_COMMAND make -C <BINARY_DIR> -j8
    INSTALL_COMMAND make -C <BINARY_DIR> -j8 install
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
  )

  # Optionally, add OpenSSL include and library directories for other targets
  set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include)
  set(OPENSSL_LIB_DIR ${OPENSSL_INSTALL_DIR}/lib)

  # Display helpful messages
  message(STATUS "OpenSSL will be installed to: ${OPENSSL_INSTALL_DIR}")
  message(STATUS "Include directory: ${OPENSSL_INCLUDE_DIR}")
  message(STATUS "Library directory: ${OPENSSL_LIB_DIR}")

  add_executable(my_app main.c)
  target_include_directories(my_app PRIVATE ${OPENSSL_INCLUDE_DIR})
  target_link_directories(my_app PRIVATE ${OPENSSL_LIB_DIR})
  target_link_libraries(my_app PRIVATE ssl crypto)
  add_dependencies(my_app openssl_build)

else()
  ExternalProject_Add(
    openssl
    URL ${OPENSSL_URL}
    URL_HASH SHA256=e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf
    PREFIX ${CMAKE_BINARY_DIR}/openssl-src
    SOURCE_SUBDIR .
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/openssl-src/src/openssl/config --prefix=/opt/local --openssldir=/opt/local/ssl
    BUILD_COMMAND make -C <BINARY_DIR> -j8
    INSTALL_COMMAND make -C <BINARY_DIR> -j8 install
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
  )
endif()

# Create a target that depends on the OpenSSL build
add_custom_target(openssl_build ALL DEPENDS openssl)
