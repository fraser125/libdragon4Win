ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif


BUILD_DIR=build
SOURCE_DIR=.
include $(call FIXPATH,$(N64_INST)/include/n64.mk)
N64_CXXFLAGS += -std=c++14

all: cpptest.z64

OBJS = $(BUILD_DIR)/cpptest.o

$(BUILD_DIR)/cpptest.elf: $(OBJS)

cpptest.z64: N64_ROM_TITLE="C++ test"

clean:
	@echo $(RM) $(BUILD_DIR) cpptest.z64
	$(RM) $(BUILD_DIR) cpptest.z64

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean
