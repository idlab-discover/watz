# Copyright (C) 2021 University of Neuchatel.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

set (PLATFORM_SHARED_DIR ${CMAKE_CURRENT_LIST_DIR})

# add_definitions(-D)
add_compile_definitions(BH_PLATFORM_LINUX_TRUSTZONE FRIEDRICH_BASE)

include_directories(${PLATFORM_SHARED_DIR})
include_directories(${PLATFORM_SHARED_DIR}/../include)

include (${CMAKE_CURRENT_LIST_DIR}/../common/math/platform_api_math.cmake)

if ("$ENV{OPTEE_DIR}" STREQUAL "")
  set (OPTEE_DIR " /home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee")
else()
  set (OPTEE_DIR $ENV{OPTEE_DIR})
endif()

#include_directories (${OPTEE_DIR}/optee_os/out/arm/export-ta_arm64/include)
include_directories (${OPTEE_DIR}/optee_os/lib/libutee/include)
include_directories (${OPTEE_DIR}/optee_os/lib/libutils/ext/include)

file (GLOB source_all ${PLATFORM_SHARED_DIR}/*.c)
list(APPEND source_all
    ${PLATFORM_SHARED_DIR}/../common/posix/posix_file.c
    ${PLATFORM_SHARED_DIR}/../common/posix/posix_clock.c
    ${PLATFORM_SHARED_DIR}/../common/posix/posix_time.c
    ${PLATFORM_SHARED_DIR}/../common/memory/mremap.c
)
include (${CMAKE_CURRENT_LIST_DIR}/../common/libc-util/platform_common_libc_util.cmake)

set(source_all ${source_all} ${PLATFORM_COMMON_LIBC_UTIL_SOURCE})

set (PLATFORM_SHARED_SOURCE ${source_all} ${PLATFORM_COMMON_MATH_SOURCE})


# Cross-compilation to ARM (from samples/simple/profiles/arm-interp/toolchain.cmake)
INCLUDE(CMakeForceCompiler)

SET(CMAKE_SYSTEM_NAME Linux) # this one is important
SET(CMAKE_SYSTEM_VERSION 1) # this one not so much

set (WAMR_BUILD_TARGET AARCH64)
