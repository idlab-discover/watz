global-incdirs-y += include

srcs-y += mobilenet.c main.c
# cflags-main.c-y+=-pg
# cflags-wasm.c-y+=-pg

# Method 2 includes the static (trusted) library between the --start-group and
# --end-group arguments.
