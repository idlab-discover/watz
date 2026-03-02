cmake_minimum_required(VERSION 3.5)
project(onn2x)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

add_executable(onnx main.c)

target_sources(onnx
	PRIVATE "main.c"
	PRIVATE
	 FILE_SET private_headers
	 TYPE HEADERS
	 BASE_DIRS "include"
	 FILES "include/onnxruntime_c_api.h" # "include/onnxruntime_ep_c_api.h"
)
target_link_libraries(onnx PRIVATE ${CMAKE_SOURCE_DIR}/lib/libonnxruntime_webassembly.a)
