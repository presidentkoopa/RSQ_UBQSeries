# qzlinux17 Makefile (driven by build.sh which generates sources.mk)
include sources.mk
SRC := $(QGZ)/src
CC  := clang
CXX := clang++
# ndk-build release builds define NDEBUG
OPT ?= -O2 -g0 -DNDEBUG
# Android flags straight from Android_src.mk (+ __ANDROID__, which the NDK predefines)
CFLAGS   := $(OPT) -D__ANDROID__ $(ANDROID_CFLAGS) -I$(CURDIR)/shim $(ENGINE_INC) -w -fsigned-char
CXXFLAGS := $(CFLAGS) $(ANDROID_CPPFLAGS)
CFLAGS_p_acs.cpp := -O1
# Android ships an old OpenAL-soft that names the device struct ALCdevice_struct
CFLAGS_oalsound.cpp := -DALCdevice_struct=ALCdevice

OBJ := $(addprefix obj/e/,$(addsuffix .o,$(ENGINE_SRC))) \
       $(addprefix obj/q/,$(addsuffix .o,$(QZ_SRC))) obj/glue/qz_linux_glue.cpp.o

LIBS := $(DEPS)/libbuild/libraries/lzma/liblzma.a $(DEPS)/libbuild/libraries/webp/libwebp.a \
        $(DEPS)/libbuild/libraries/ZWidget/libzwidget.a
SYSLIBS := -Wl,-rpath,'$$ORIGIN' -Wl,-rpath,$(ZLIB) -Wl,--wrap=_Z16I_ShowFatalErrorPKc \
        -L$(ZLIB) -lzmusic -lEGL -lGLESv2 -lvpx -lz -lbz2 -ldl -lpthread -lm -rdynamic -lopenal

qzdoom: $(OBJ)
	@echo LINK $@; $(CXX) -o $@ $(OBJ) $(LIBS) $(SYSLIBS)

obj/e/%.c.o: $(SRC)/%.c
	@mkdir -p $(dir $@); echo CC $<; $(CC) $(CFLAGS) -c $< -o $@
obj/e/%.cpp.o: $(SRC)/%.cpp
	@mkdir -p $(dir $@); echo CXX $<; $(CXX) $(CXXFLAGS) $(CFLAGS_$(notdir $<)) -c $< -o $@
obj/q/%.c.o: $(JNI)/QzDoom/%.c
	@mkdir -p $(dir $@); echo CC $<; $(CC) $(CFLAGS) -c $< -o $@
obj/q/%.cpp.o: $(JNI)/QzDoom/%.cpp
	@mkdir -p $(dir $@); echo CXX $<; $(CXX) $(CXXFLAGS) -I$(JNI)/QzDoom -c $< -o $@
obj/glue/%.cpp.o: glue/%.cpp
	@mkdir -p $(dir $@); echo CXX $<; $(CXX) $(CXXFLAGS) -I$(JNI)/QzDoom -c $< -o $@
