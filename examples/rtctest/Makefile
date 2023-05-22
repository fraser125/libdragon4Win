ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif


all: rtctest.z64
.PHONY: all

BUILD_DIR = build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

OBJS = $(BUILD_DIR)/rtctest.o

rtctest.z64: N64_ROM_TITLE = "RTC Test"
rtctest.z64: N64_ROM_RTC = true

$(BUILD_DIR)/rtctest.elf: $(OBJS)

clean:
	$(RM) $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d)
