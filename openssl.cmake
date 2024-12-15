cmake_minimum_required(VERSION 3.25...3.31)

project(openssl_build LANGUAGES C)

set(OPENSSL_VERSION "3.4.0")
set(SHA256 e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf)
set(OPENSSL_URL
    "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
)

# include(ExternalProject)

set(OPENSSL_BUILD_TYPE $<CONFIG>)

#XXX include(zlib.cmake)

ExternalProject_Add(
    openssl
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    PREFIX ${CMAKE_BINARY_DIR}
    #--Download step--------------
    URL ${OPENSSL_URL}
    URL_HASH SHA256=${SHA256}
    #--Update/Patch step----------
    #--Configure step-------------
    USES_TERMINAL_CONFIGURE TRUE
    CONFIGURE_COMMAND
        ../openssl/config --api=1.1.0 no-deprecated --$<LIST:TRANSFORM,$<CONFIG>,TOLOWER>
        --prefix=${OPENSSL_INSTALL_PREFIX}
        #XXX --libdir=lib #FIXME: /${OPENSSL_BUILD_TYPE}
        --openssldir=${OPENSSL_INSTALL_PREFIX}/etc/ssl #
        no-zlib #XXX
        --with-zlib-include=${OPENSSL_INSTALL_PREFIX}/include
        --with-zlib-lib=${OPENSSL_INSTALL_PREFIX}/lib no-apps no-aria no-asm
        no-async no-bf no-blake2 no-camellia no-capieng no-cast no-cmac no-cmp
        no-cms no-ct no-docs no-dso no-ec no-ec2m no-gost no-idea no-makedepend
        no-mdc2 no-ocb no-rc2 no-rc4 no-rmd160 no-scrypt no-seed no-shared
        no-siphash no-sm2 no-sm3 no-sm4 no-srtp no-ssl-trace no-tests
        no-whirlpool
    # linux-aarch64
    #--Build step-----------------
    USES_TERMINAL_BUILD TRUE
    BUILD_COMMAND make -C <BINARY_DIR> -j8
    #--Install step---------------
    USES_TERMINAL_INSTALL TRUE
    INSTALL_COMMAND make -C <BINARY_DIR> -j8 install
    #--Logging -------------------
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)

#XXX add_dependencies(openssl zlib)
