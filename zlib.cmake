project(zlib LANGUAGES C)

set(TARBALL_VERSION 1.2.12)
set(MD5 5fc414a9726be31427b440b434d05f78)

if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL x86_64)
    set(CFLAGS -m64 -Wall -g -O3 -fPIC)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL arm)
    set(CFLAGS -march=armv8-a -g -O2 -fPIC)
endif()
string(REPLACE ";" " " CFLAGS "${CFLAGS}")

set(EXPORTS
    "export CFLAGS='${CFLAGS}'"
)
string(REPLACE ";" "\n" EXPORTS "${EXPORTS}")
#XXX configure_file(${CMAKE_PATH}/build-wrapper.sh.in build-wrapper.sh)

include(ExternalProject)
ExternalProject_Add(${PROJECT_NAME}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_DIR install
    #--Download step--------------
    URL https://www.zlib.net/${PROJECT_NAME}-${TARBALL_VERSION}.tar.gz
    URL_MD5 ${MD5}
    #--Update/Patch step----------
    #--Configure step-------------
    USES_TERMINAL_CONFIGURE TRUE
    CONFIGURE_COMMAND
        #XXX ${CMAKE_CURRENT_BINARY_DIR}/build-wrapper.sh
        ./configure
            --prefix=/usr
            # --libdir=/lib
            --uname=Linux
            --shared
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

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/
    DESTINATION ${CMAKE_SYSROOT_REL}
    USE_SOURCE_PERMISSIONS
    COMPONENT ${PROJECT_NAME}
)

string(TOUPPER ${PROJECT_NAME} TARGET)
set(CPACK_ARCHIVE_${TARGET}_FILE_NAME ${PROJECT_NAME}-${TARBALL_VERSION}-${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL "")
