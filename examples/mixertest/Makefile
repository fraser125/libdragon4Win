ifdef SystemRoot
include $(N64_INST)\include\crossplatform.mk
else
include $(N64_INST)/include/crossplatform.mk
endif

BUILD_DIR=build
include $(call FIXPATH,$(N64_INST)/include/n64.mk)

OBJS = $(BUILD_DIR)/mixertest.o

assets = $(wildcard assets/*.wav)
assets_conv = $(addprefix filesystem/,$(notdir $(assets:%.wav=%.wav64)))

all: mixertest.z64

# Run audioconv on all WAV files under assets/
# We do this file by file, but we could even do it just once for the whole
# directory, because audioconv64 supports directory walking.
filesystem/%.wav64: assets/%.wav
	$(MD) -p $(dir $@)
	@echo "    [AUDIO] $@"
	@$(N64_AUDIOCONV) -o filesystem $<

$(BUILD_DIR)/mixertest.dfs: $(assets_conv)
$(BUILD_DIR)/mixertest.elf: $(OBJS)

mixertest.z64: N64_ROM_TITLE="Mixer Test"
mixertest.z64: $(BUILD_DIR)/mixertest.dfs

clean:
	$(RM) $(BUILD_DIR)/* mixertest.z64 $(assets_conv)

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean
