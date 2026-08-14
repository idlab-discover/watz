cmake_minimum_required (VERSION 3.14)

include(CheckPIESupported)

project (wamr-host C)

SET(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
SET(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)

# set (WAMR_BUILD_TARGET "X86_64")
set (WAMR_BUILD_TARGET "AARCH64")
set (WAMR_BUILD_PLATFORM "linux")

if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE Release)
endif ()

add_compile_options (-Wall)
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
	set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
	set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

set (WAMR_BUILD_INTERP 0)
set (WAMR_BUILD_FAST_INTERP 0)
set (WAMR_BUILD_AOT 1)
set (WAMR_BUILD_JIT 0)
set (WAMR_BUILD_LIBC_BUILTIN 1)
set (WAMR_BUILD_LIBC_WASI 1)
set (WAMR_BUILD_REF_TYPES 1)
set (WAMR_BUILD_SIMD 1)
set (WAMR_BUILD_SIMDE 1)
set (WAMR_BUILD_LIB_SIMDE 1)

if (NOT MSVC)
  # linker flags
  if (NOT (CMAKE_C_COMPILER MATCHES ".*clang.*" OR CMAKE_C_COMPILER_ID MATCHES ".*Clang"))
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")
  endif ()
endif ()

# build out vmlib
set (WAMR_ROOT_DIR "/home/zelzahn/Onderzoek/optee/watz/wamr/2.4.1/")
include (${WAMR_ROOT_DIR}/build-scripts/runtime_lib.cmake)

add_library(vmlib ${WAMR_RUNTIME_LIB_SOURCE})

# Build WAMR
# ---
# Build App

set (SRC tract.c)

add_executable (${PROJECT_NAME}-tract ${SRC})

check_pie_supported()
set_target_properties (${PROJECT_NAME}-tract PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries (${PROJECT_NAME}-tract vmlib -lm -ldl -lpthread -lrt)

set (SRC onnx2c.c)

add_executable (${PROJECT_NAME}-onnx2c ${SRC})

check_pie_supported()
set_target_properties (${PROJECT_NAME}-onnx2c PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries (${PROJECT_NAME}-onnx2c vmlib -lm -ldl -lpthread -lrt)
