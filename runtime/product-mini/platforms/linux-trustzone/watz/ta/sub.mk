global-incdirs-y += include
global-incdirs-y += ../../../../../core/iwasm/include/ ../../../../../core/shared/utils ../../../../../core/shared/platform/linux-trustzone 

srcs-y += tee_benchmarks.c wasm.c main.c

# Method 2 includes the static (trusted) library between the --start-group and
# --end-group arguments.
libnames += vmlib
libdirs += ../../build/
libdeps += ../../build/libvmlib.a
