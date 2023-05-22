ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif

all: loadspritefromsd.z64
.PHONY: all

BUILD_DIR = build

OBJS = $(BUILD_DIR)/loadspritefromsd.o

include $(call FIXPATH,$(N64_INST)/include/n64.mk)

loadspritefromsd.z64: N64_ROM_TITLE = "loadspritefromsd"
loadspritefromsd.z64: $(BUILD_DIR)/loadspritefromsd.dfs

$(BUILD_DIR)/loadspritefromsd.dfs: $(wildcard filesystem/*)
$(BUILD_DIR)/loadspritefromsd.elf: $(OBJS)

clean:
	$(RM) $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d)
