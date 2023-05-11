ifdef SystemRoot
FIXPATH = $(subst /,\,$1)
RM = -del /Q
RMF = -rd /Q /S
MD = -md
SENDNULL = 2> nul
SENDNULLALL = > nul 1> nul 2> nul
MV = copy
else
FIXPATH = $1
RM = rm -f
RMF = rm -rf
MD = mkdir -p
MV = mv
SENDNULL = 
SENDNULLALL = 
endif

all: libdragon

V = 1  # force verbose (at least until we have converted all sub-Makefiles)
SOURCE_DIR = src
BUILD_DIR = build
include n64.mk
INSTALLDIR = $(N64_INST)

# Activate N64 toolchain for libdragon build
libdragon: CC=$(N64_CC)
libdragon: AS=$(N64_AS)
libdragon: LD=$(N64_LD)
libdragon: CFLAGS+=$(N64_CFLAGS) -I$(call FIXPATH, $(CURDIR)/src) -I$(call FIXPATH, $(CURDIR)/include) 
libdragon: ASFLAGS+=$(N64_ASFLAGS) -I$(call FIXPATH, $(CURDIR)/src) -I$(call FIXPATH, $(CURDIR)/include)
libdragon: RSPASFLAGS+=$(N64_RSPASFLAGS) -I$(call FIXPATH, $(CURDIR)/src) -I$(call FIXPATH, $(CURDIR)/include)
libdragon: LDFLAGS+=$(N64_LDFLAGS)
libdragon: libdragon.a libdragonsys.a

libdragonsys.a: $(BUILD_DIR)/system.o
	@echo "    [AR] $@"
	@$(N64_AR) -rcs -o $(call FIXPATH,$@) $(call FIXPATH,$^)

libdragon.a: $(BUILD_DIR)/n64sys.o $(BUILD_DIR)/interrupt.o \
			 $(BUILD_DIR)/inthandler.o $(BUILD_DIR)/entrypoint.o \
			 $(BUILD_DIR)/debug.o $(BUILD_DIR)/usb.o $(BUILD_DIR)/fatfs/ff.o \
			 $(BUILD_DIR)/fatfs/ffunicode.o $(BUILD_DIR)/dragonfs.o \
			 $(BUILD_DIR)/audio.o $(BUILD_DIR)/display.o $(BUILD_DIR)/surface.o \
			 $(BUILD_DIR)/console.o $(BUILD_DIR)/joybus.o \
			 $(BUILD_DIR)/controller.o $(BUILD_DIR)/rtc.o \
			 $(BUILD_DIR)/eeprom.o $(BUILD_DIR)/eepromfs.o $(BUILD_DIR)/mempak.o \
			 $(BUILD_DIR)/tpak.o $(BUILD_DIR)/graphics.o $(BUILD_DIR)/rdp.o \
			 $(BUILD_DIR)/rsp.o $(BUILD_DIR)/rsp_crash.o \
			 $(BUILD_DIR)/dma.o $(BUILD_DIR)/timer.o \
			 $(BUILD_DIR)/exception.o $(BUILD_DIR)/do_ctors.o \
			 $(BUILD_DIR)/audio/mixer.o $(BUILD_DIR)/audio/samplebuffer.o \
			 $(BUILD_DIR)/audio/rsp_mixer.o $(BUILD_DIR)/audio/wav64.o \
			 $(BUILD_DIR)/audio/xm64.o $(BUILD_DIR)/audio/libxm/play.o \
			 $(BUILD_DIR)/audio/libxm/context.o $(BUILD_DIR)/audio/libxm/load.o \
			 $(BUILD_DIR)/audio/ym64.o $(BUILD_DIR)/audio/ay8910.o \
			 $(BUILD_DIR)/rspq/rspq.o $(BUILD_DIR)/rspq/rsp_queue.o 
	@echo "    [AR] $@"
	@$(N64_AR) -rcs -o $@ $(call FIXPATH,$^)

examples:
	$(MAKE) -C examples
# We are unable to clean examples built with n64.mk unless we
# install it first
examples-clean: install-mk
	$(MAKE) -C examples clean

doxygen: doxygen.conf
	mkdir -p doxygen/
	doxygen doxygen.conf
doxygen-api: doxygen-public.conf
	mkdir -p doxygen/
	doxygen doxygen-public.conf
doxygen-clean:
	rm -rf $(CURDIR)/doxygen

tools:
	$(MAKE) -C tools
tools-install:
	$(MAKE) -C tools install
tools-clean:
	$(MAKE) -C tools clean

install-mk: n64.mk
	install -Cv -m 0644 n64.mk $(call FIXPATH, $(INSTALLDIR)/include/n64.mk)

install: install-mk libdragon
	install -Cv -m 0644 libdragon.a $(call FIXPATH, $(INSTALLDIR)/mips64-elf/lib/libdragon.a)
	install -Cv -m 0644 n64.ld $(call FIXPATH, $(INSTALLDIR)/mips64-elf/lib/n64.ld)
	install -Cv -m 0644 rsp.ld $(call FIXPATH, $(INSTALLDIR)/mips64-elf/lib/rsp.ld)
	install -Cv -m 0644 header $(call FIXPATH, $(INSTALLDIR)/mips64-elf/lib/header)
	install -Cv -m 0644 libdragonsys.a $(call FIXPATH, $(INSTALLDIR)/mips64-elf/lib/libdragonsys.a)
	install -Cv -m 0644 $(call FIXPATH, include/audio.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/audio.h)
	install -Cv -m 0644 $(call FIXPATH, include/ay8910.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/ay8910.h)
	install -Cv -m 0644 $(call FIXPATH, include/backtrace.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/backtrace.h)
	install -Cv -m 0644 $(call FIXPATH, include/console.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/console.h)
	install -Cv -m 0644 $(call FIXPATH, include/controller.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/controller.h)
	install -Cv -m 0644 $(call FIXPATH, include/cop0.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/cop0.h)
	install -Cv -m 0644 $(call FIXPATH, include/cop1.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/cop1.h)
	install -Cv -m 0644 $(call FIXPATH, include/debug.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/debug.h)
	install -Cv -m 0644 $(call FIXPATH, include/display.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/display.h)
	install -Cv -m 0644 $(call FIXPATH, include/dir.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/dir.h)
	install -Cv -m 0644 $(call FIXPATH, include/dma.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/dma.h)
	install -Cv -m 0644 $(call FIXPATH, include/dragonfs.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/dragonfs.h)
	install -Cv -m 0644 $(call FIXPATH, include/eeprom.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/eeprom.h)
	install -Cv -m 0644 $(call FIXPATH, include/eepromfs.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/eepromfs.h)
	install -Cv -m 0644 $(call FIXPATH, include/exception.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/exception.h)
	install -Cv -m 0644 $(call FIXPATH, include/graphics.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/graphics.h)
	install -Cv -m 0644 $(call FIXPATH, include/interrupt.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/interrupt.h)
	install -Cv -m 0644 $(call FIXPATH, include/joybus.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/joybus.h)
	install -Cv -m 0644 $(call FIXPATH, include/libdragon.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/libdragon.h)
	install -Cv -m 0644 $(call FIXPATH, include/mempak.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/mempak.h)
	install -Cv -m 0644 $(call FIXPATH, include/mixer.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/mixer.h)
	install -Cv -m 0644 $(call FIXPATH, include/n64sys.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/n64sys.h)
	install -Cv -m 0644 $(call FIXPATH, include/n64types.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/n64types.h)
	install -Cv -m 0644 $(call FIXPATH, include/pputils.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/pputils.h)
	install -Cv -m 0644 $(call FIXPATH, include/rdp.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rdp.h)
	install -Cv -m 0644 $(call FIXPATH, include/rsp.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rsp.h)
	install -Cv -m 0644 $(call FIXPATH, include/rsp.inc) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rsp.inc)
	install -Cv -m 0644 $(call FIXPATH, include/rsp_assert.inc) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rsp_assert.inc)
	install -Cv -m 0644 $(call FIXPATH, include/rsp_dma.inc) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rsp_dma.inc)
	install -Cv -m 0644 $(call FIXPATH, include/rsp_queue.inc) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rsp_queue.inc)
	install -Cv -m 0644 $(call FIXPATH, include/rspq.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rspq.h)
	install -Cv -m 0644 $(call FIXPATH, include/rspq_constants.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rspq_constants.h)
	install -Cv -m 0644 $(call FIXPATH, include/rtc.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/rtc.h)
	install -Cv -m 0644 $(call FIXPATH, include/samplebuffer.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/samplebuffer.h)
	install -Cv -m 0644 $(call FIXPATH, include/surface.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/surface.h)
	install -Cv -m 0644 $(call FIXPATH, include/system.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/system.h)
	install -Cv -m 0644 $(call FIXPATH, include/timer.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/timer.h)
	install -Cv -m 0644 $(call FIXPATH, include/tpak.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/tpak.h)
	install -Cv -m 0644 $(call FIXPATH, include/ucode.S) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/ucode.S)
	install -Cv -m 0644 $(call FIXPATH, include/usb.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/usb.h)
	install -Cv -m 0644 $(call FIXPATH, include/wav64.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/wav64.h)
	install -Cv -m 0644 $(call FIXPATH, include/xm64.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/xm64.h)
	install -Cv -m 0644 $(call FIXPATH, include/ym64.h) $(call FIXPATH, $(INSTALLDIR)/mips64-elf/include/ym64.h)



clean:
	$(RM) *.o $(SENDNULL)
	$(RM) *.a $(SENDNULL)
	$(RMF) $(call FIXPATH, $(CURDIR)/build)

test:
	$(MAKE) -C tests

test-clean: install-mk
	$(MAKE) -C tests clean

clobber: clean doxygen-clean examples-clean tools-clean test-clean

.PHONY : clobber clean doxygen-clean doxygen doxygen-api examples examples-clean tools tools-clean tools-install test test-clean

# Automatic dependency tracking
-include $(wildcard $(BUILD_DIR)/*.d) $(wildcard $(BUILD_DIR)/*/*.d)
