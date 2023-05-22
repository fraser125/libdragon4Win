ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif

all: test.z64
.PHONY: all

BUILD_DIR = build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

OBJS = $(BUILD_DIR)/test.o

test.z64: N64_ROM_TITLE = "Video Test"
test.z64: $(BUILD_DIR)/test.dfs

$(BUILD_DIR)/test.dfs: $(wildcard filesystem/*)
$(BUILD_DIR)/test.elf: $(OBJS)

clean:
	$(RM) $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d))
