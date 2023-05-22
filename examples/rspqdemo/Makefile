ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif

BUILD_DIR=build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

all: rspqdemo.z64

$(BUILD_DIR)/rspqdemo.elf: $(BUILD_DIR)/rspqdemo.o $(BUILD_DIR)/rsp_vec.o $(BUILD_DIR)/vec.o

rspqdemo.z64: N64_ROM_TITLE="RSPQ Demo"

clean:
	$(RM) $(BUILD_DIR) rspqdemo.z64

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean