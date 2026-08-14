global-incdirs-y += include
global-incdirs-y += ../../../../optee/watz/wamr/2.4.1/core/iwasm/include/
global-incdirs-y += ../../../../optee/watz/wamr/2.4.1/core/shared/utils
global-incdirs-y += ../../../../optee/watz/wamr/2.4.1/core/shared/platform/linux-trustzone 

srcs-y += wasm.c main.c
# cflags-main.c-y+=-pg
# cflags-wasm.c-y+=-pg

# Method 2 includes the static (trusted) library between the --start-group and
# --end-group arguments.
libnames += vmlib
libdirs += ../vmlib/build/
libdeps += ../vmlib/build/libvmlib.a
