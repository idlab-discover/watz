global-incdirs-y += include
global-incdirs-y += ../../native/
srcs-y += onnx_ta.c

libnames += onnx
libdirs += lib/
libdeps += lib/libonnx.a
