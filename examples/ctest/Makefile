ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

all: ctest.z64
.PHONY: all

BUILD_DIR = build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

OBJS = $(call FIXPATH,$(BUILD_DIR)/ctest.o)

ctest.z64: N64_ROM_TITLE = "Controller Test"

$(BUILD_DIR)/ctest.elf: $(OBJS)

clean:
	$(RM) $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d)
