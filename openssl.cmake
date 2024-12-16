cmake_minimum_required(VERSION 3.25...3.31)

project(openssl_build LANGUAGES C)

set(OPENSSL_VERSION "3.4.0")
set(SHA256 e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf)
set(OPENSSL_URL
    "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
)

include(ExternalProject)

set(OPENSSL_BUILD_TYPE $<CONFIG>)
if($ENV{CI})
    set(OPENSSL_WRITE_LOG OFF)
else()
    set(OPENSSL_WRITE_LOG ON)
endif()

if(MSVC)
    set(MAKE_PROGRAM nmake)
else()
    set(MAKE_PROGRAM make -j8)
endif()

find_program(PERL_PROGRAM perl REQUIRED)

include(zlib.cmake)

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
        # see build/src/openssl/Configure
        # bash only! build/src/openssl/config
        ${PERL_PROGRAM} ../openssl/Configure --api=1.1.0 # TBD: --api=1.0.2
        no-deprecated --static # TODO: depends on BUILD_SHARED_LIBS
        --release # FIXME: --$<LIST:TRANSFORM,$<CONFIG>,TOLOWER> # or --debug
        --prefix=${OPENSSL_INSTALL_PREFIX}
        #XXX --libdir=lib #FIXME: /${OPENSSL_BUILD_TYPE}
        --openssldir=${OPENSSL_INSTALL_PREFIX}/etc/ssl #
        zlib # FIXME: debug lib name: libzlibd.lib
        --with-zlib-include=${OPENSSL_INSTALL_PREFIX}/include
        --with-zlib-lib=${OPENSSL_INSTALL_PREFIX}/lib no-apps no-aria no-asm
        no-async no-bf no-blake2 no-camellia no-capieng no-cast no-cmac no-cmp
        no-cms no-ct no-docs no-dso no-ec no-ec2m no-gost no-idea no-makedepend
        no-mdc2 no-ocb no-rc2 no-rc4 no-rmd160 no-scrypt no-seed no-shared
        no-siphash no-sm2 no-sm3 no-sm4 no-srtp no-ssl-trace no-tests no-threads
        no-whirlpool
    # linux-aarch64
    #--Build step-----------------
    USES_TERMINAL_BUILD TRUE
    BUILD_COMMAND ${MAKE_PROGRAM} -C <BINARY_DIR>
    #--Install step---------------
    USES_TERMINAL_INSTALL TRUE
    INSTALL_COMMAND ${MAKE_PROGRAM} -C <BINARY_DIR> install
    #--Logging -------------------
    LOG_DOWNLOAD ${OPENSSL_WRITE_LOG}
    LOG_CONFIGURE ${OPENSSL_WRITE_LOG}
    LOG_BUILD ${OPENSSL_WRITE_LOG}
    LOG_INSTALL ${OPENSSL_WRITE_LOG}
)

add_dependencies(openssl zlib)
