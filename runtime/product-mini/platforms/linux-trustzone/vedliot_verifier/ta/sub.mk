global-incdirs-y += include
global-incdirs-y += ../../../../../core/iwasm/include/ ../../../../../core/shared/utils ../../../../../core/shared/platform/linux-trustzone
srcs-y += tee_benchmarks.c verifier.c main.c

libnames += vmlib
libdirs += ../../build/
libdeps += ../../build/libvmlib.a