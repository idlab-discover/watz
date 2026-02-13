cmake_minimum_required(VERSION 3.5)
project(onn2x)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

option(BUILD_LIB "Compile it as a library for the native TEE" OFF)

if(BUILD_LIB)
	add_compile_definitions(COMPILE_AS_LIB)
	add_library(onnx main.c)
else()
	add_executable(onnx main.c)
endif()

add_custom_command(
	OUTPUT app_generated.c
	COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/onnx2c -l 0 ${CMAKE_CURRENT_SOURCE_DIR}/model.onnx > app_generated.c
)

target_sources(onnx
	PRIVATE "app_generated.c"
)
