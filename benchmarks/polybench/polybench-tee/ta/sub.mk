global-incdirs-y += include
global-incdirs-y += ../../polybench-srcs/all/
# global-incdirs-y += ../../../../wamr/2.4.1/core/iwasm/include/ ../../../../wamr/2.4.1/core/shared/utils ../../../../wamr/2.4.1/core/shared/platform/linux-trustzone 
srcs-y += polybench_ta.c

libnames += polybench
libdirs += lib/
libdeps += lib/libpolybench.a
