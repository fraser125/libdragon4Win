ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif

all: spritemap.z64
.PHONY: all

BUILD_DIR = build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

OBJS = $(BUILD_DIR)/spritemap.o

spritemap.z64: N64_ROM_TITLE = "Spritemap"
spritemap.z64: $(BUILD_DIR)/spritemap.dfs

$(BUILD_DIR)/spritemap.dfs: $(wildcard filesystem/*)
$(BUILD_DIR)/spritemap.elf: $(OBJS)

clean:
	$(RM) $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d)
