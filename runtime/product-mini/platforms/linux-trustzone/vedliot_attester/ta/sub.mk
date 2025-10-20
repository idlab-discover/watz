global-incdirs-y += include
global-incdirs-y += ../../../../../core/iwasm/include/ ../../../../../core/shared/utils ../../../../../core/shared/platform/linux-trustzone 
#NOTE(Friedrich) app-framework testje
# global-incdirs-y += ../../../../../../../../home/zelzahn/Onderzoek/wamr-app-framework/app-framework/base/app

srcs-y += ra_wasi.c remote_attestation.c tee_benchmarks.c wasm.c main.c

# Method 2 includes the static (trusted) library between the --start-group and
# --end-group arguments.
libnames += vmlib
libdirs += ../../build/
libdeps += ../../build/libvmlib.a
