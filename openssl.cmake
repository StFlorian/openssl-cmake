project(openssl LANGUAGES C)

set(TARBALL_VERSION 3.0.13)
set(MD5 c15e53a62711002901d3515ac8b30b86)

set(EXPORTS
    "export CFLAGS='-march=armv8-a -Wall -g -O3'"
    "export CXXFLAGS='-march=armv8-a -Wall -g -O3'"
    "export LDFLAGS='-Wl,--build-id'"
    "export PKG_CONFIG_SYSROOT_DIR='${CMAKE_SYSROOT}'"
    "export PKG_CONFIG_PATH='${CMAKE_SYSROOT}/usr/lib/pkgconfig'"
)
string(REPLACE ";" "\n" EXPORTS "${EXPORTS}")
#XXX configure_file(${CMAKE_PATH}/build-wrapper.sh.in build-wrapper.sh)

include(ExternalProject)
ExternalProject_Add(${PROJECT_NAME}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR install
    #--Download step--------------
    URL https://github.com/openssl/openssl/releases/download/openssl-${TARBALL_VERSION}/${PROJECT_NAME}-${TARBALL_VERSION}.tar.gz
    URL_MD5 ${MD5}
    #--Update/Patch step----------
    #--Configure step-------------
    USES_TERMINAL_CONFIGURE TRUE
    CONFIGURE_COMMAND
        #XXX ${CMAKE_CURRENT_BINARY_DIR}/build-wrapper.sh
        ./Configure
            --prefix=/usr
            # --libdir=lib
            --openssldir=/etc/ssl
            no-capieng
            no-cms
            no-gost
            no-makedepend
            no-srtp
            no-tests
            no-aria
            no-bf
            no-blake2
            no-camellia
            no-cast
            no-cmac
            no-cmp
            no-idea
            no-mdc2
            no-ocb
            no-rc2
            no-rc4
            no-rmd160
            no-scrypt
            no-seed
            no-siphash
            no-sm2
            no-sm3
            no-sm4
            no-ssl-trace
            no-whirlpool
            zlib
            linux-aarch64
    #--Build step-----------------
    USES_TERMINAL_BUILD TRUE
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
        #XXX ${CMAKE_CURRENT_BINARY_DIR}/build-wrapper.sh
        make
    #--Install step---------------
    USES_TERMINAL_INSTALL TRUE
    INSTALL_COMMAND
        #XXX ${CMAKE_CURRENT_BINARY_DIR}/build-wrapper.sh
        make
            install
            DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/install
)
add_dependencies(${PROJECT_NAME} zlib)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/
    DESTINATION ${CMAKE_SYSROOT_REL}
    USE_SOURCE_PERMISSIONS
    COMPONENT ${PROJECT_NAME}
)

string(TOUPPER ${PROJECT_NAME} TARGET)
set(CPACK_ARCHIVE_${TARGET}_FILE_NAME ${PROJECT_NAME}-${TARBALL_VERSION}-${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL "")

