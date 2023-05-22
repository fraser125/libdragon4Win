BUILD_DIR ?= .
SOURCE_DIR ?= .
N64_DFS_OFFSET ?= 1M # Override this to offset where the DFS file will be located inside the ROM

N64_ROM_TITLE = "Made with libdragon" # Override this with the name of your game or project
N64_ROM_SAVETYPE = # Supported savetypes: none eeprom4k eeprom16 sram256k sram768k sram1m flashram
N64_ROM_RTC = # Set to true to enable the Joybus Real-Time Clock
N64_ROM_REGIONFREE = # Set to true to allow booting on any console region

N64_ROOTDIR = $(N64_INST)
N64_BINDIR = $(call FIXPATH, $(N64_ROOTDIR)/bin)
N64_INCLUDEDIR = $(call FIXPATH, $(N64_ROOTDIR)/mips64-elf/include)
N64_LIBDIR = $(call FIXPATH, $(N64_ROOTDIR)/mips64-elf/lib)
N64_GCCPREFIX = $(call FIXPATH, $(N64_BINDIR)/mips64-elf-)
N64_HEADERPATH = $(call FIXPATH, $(N64_LIBDIR)/header)

COMMA:=,

N64_CC = $(N64_GCCPREFIX)gcc
N64_CXX = $(N64_GCCPREFIX)g++
N64_AS = $(N64_GCCPREFIX)as
N64_AR = $(N64_GCCPREFIX)ar
N64_LD = $(N64_GCCPREFIX)ld
N64_OBJCOPY = $(N64_GCCPREFIX)objcopy
N64_OBJDUMP = $(N64_GCCPREFIX)objdump
N64_SIZE = $(N64_GCCPREFIX)size

N64_CHKSUM = $(call FIXPATH, $(N64_BINDIR)/chksum64)
N64_ED64ROMCONFIG = $(call FIXPATH, $(N64_BINDIR)/ed64romconfig)
N64_MKDFS = $(call FIXPATH, $(N64_BINDIR)/mkdfs)
N64_TOOL = $(call FIXPATH, $(N64_BINDIR)/n64tool)
N64_AUDIOCONV = $(call FIXPATH, $(N64_BINDIR)/audioconv64)

N64_CFLAGS =  -march=vr4300 -mtune=vr4300 -I$(call FIXPATH, $(N64_INCLUDEDIR))
N64_CFLAGS += -falign-functions=32 -ffunction-sections -fdata-sections
N64_CFLAGS += -DN64 -O2 -Wall -Werror -Wno-error=deprecated-declarations -fdiagnostics-color=always
N64_ASFLAGS = -mtune=vr4300 -march=vr4300 -Wa,--fatal-warnings
N64_RSPASFLAGS = -march=mips1 -mabi=32 -Wa,--fatal-warnings
N64_LDFLAGS = -L$(N64_LIBDIR) -ldragon -lm -ldragonsys -Tn64.ld --gc-sections --wrap __do_global_ctors

N64_TOOLFLAGS = --header $(N64_HEADERPATH) --title $(N64_ROM_TITLE)
N64_ED64ROMCONFIGFLAGS =  $(if $(N64_ROM_SAVETYPE),--savetype $(N64_ROM_SAVETYPE))
N64_ED64ROMCONFIGFLAGS += $(if $(N64_ROM_RTC),--rtc) 
N64_ED64ROMCONFIGFLAGS += $(if $(N64_ROM_REGIONFREE),--regionfree)

ifeq ($(D),1)
CFLAGS+=-g3
CXXFLAGS+=-g3
ASFLAGS+=-g
RSPASFLAGS+=-g
LDFLAGS+=-g
endif

# automatic .d dependency generation
CFLAGS+=-MMD     
CXXFLAGS+=-MMD
ASFLAGS+=-MMD
RSPASFLAGS+=-MMD

N64_CXXFLAGS := $(N64_CFLAGS)
N64_CFLAGS += -std=gnu99

# Change all the dependency chain of z64 ROMs to use the N64 toolchain.
%.z64: CC=$(N64_CC)
%.z64: CXX=$(N64_CXX)
%.z64: AS=$(N64_AS)
%.z64: LD=$(N64_LD)
%.z64: CFLAGS+=$(N64_CFLAGS)
%.z64: CXXFLAGS+=$(N64_CXXFLAGS)
%.z64: ASFLAGS+=$(N64_ASFLAGS)
%.z64: RSPASFLAGS+=$(N64_RSPASFLAGS)
%.z64: LDFLAGS=$(N64_LDFLAGS)
%.z64: $(BUILD_DIR)/%.elf
	@echo "    [Z64] $@"		
	$(N64_OBJCOPY) -O binary $(call FIXPATH,$<) $<.bin
	$(RM) $(call FIXPATH,$@) $(SENDNULL)
#	@echo $(N64_TOOL) $(N64_TOOLFLAGS) --output $@ $(call FIXPATH,$<.bin) --offset $(N64_DFS_OFFSET) $(filter %.dfs, $^)	
	$(N64_TOOL) $(N64_TOOLFLAGS) --output $@ $(call FIXPATH,$<.bin) --offset $(N64_DFS_OFFSET) $(filter %.dfs, $^)	
	@echo end copy
#	DFS_FILE="$(filter %.dfs, $^)"; \
#	if [ -z "$$DFS_FILE" ]; then \
#		$(N64_TOOL) $(N64_TOOLFLAGS) --output $@ $<.bin; \
#	else \
#		$(N64_TOOL) $(N64_TOOLFLAGS) --output $@ $<.bin --offset $(N64_DFS_OFFSET) "$$DFS_FILE"; \
#	fi
#	if [ ! -z "$(strip $(N64_ED64ROMCONFIGFLAGS))" ]; then \
#		$(N64_ED64ROMCONFIG) $(N64_ED64ROMCONFIGFLAGS) $@; \
#	fi
	@echo $(N64_CHKSUM) $(call FIXPATH,$@) $(SENDNULL)
	$(N64_CHKSUM) $(call FIXPATH,$@) $(SENDNULL)

%.v64: %.z64
	@echo "    [V64] $@"
	$(N64_OBJCOPY) -I binary -O binary --reverse-bytes=2 $< $@

%.dfs:
	@mkdir -p $(dir $@)
	@echo "    [DFS] $@"
	$(N64_MKDFS) $@ $(<D) $(SENDNULL)

$(BUILD_DIR)/rsp%.o: $(SOURCE_DIR)/rsp%.S $(SOURCE_DIR)\rsp%.S
	@$(MD) $(call FIXPATH,$(dir $@)) $(SENDNULL)	
	@echo "    [RSP] $<"
	@$(N64_CC) $(RSPASFLAGS) -nostartfiles -Wl,-Trsp.ld -Wl,--gc-sections -o $(call FIXPATH,$@) $(call FIXPATH,$<)
	@$(MV) "$(call FIXPATH,$@)" $(call FIXPATH,$(basename $@)).elf $(SENDNULLALL)
	@$(N64_OBJCOPY) -O binary -j .text $(call FIXPATH,$(basename $@)).elf $(call FIXPATH,$(basename $@)).text.bin
	@$(N64_OBJCOPY) -O binary -j .data $(basename $@).elf $(basename $@).data.bin
	@$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_text_bin_start=$(notdir $(basename $@))_text_start \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_text_bin_end=$(notdir $(basename $@))_text_end \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_text_bin_size=$(notdir $(basename $@))_text_size \
		--rename-section .text=.data $(basename $@).text.bin $(basename $@).text.o \
		--set-section-alignment .data=8	
	@$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_data_bin_start=$(notdir $(basename $@))_data_start \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_data_bin_end=$(notdir $(basename $@))_data_end \
		--redefine-sym _binary_$(subst .,_,$(subst /,_,$(basename $@)))_data_bin_size=$(notdir $(basename $@))_data_size \
		--rename-section .text=.data $(basename $@).data.bin $(basename $@).data.o \
		--set-section-alignment .data=8
	@$(N64_SIZE) -G $(basename $@).elf
	@$(N64_LD) -relocatable $(basename $@).text.o $(basename $@).data.o -o $(call FIXPATH,$@)
	@$(RM) $(call FIXPATH,$(basename $@)).text.bin $(call FIXPATH,$(basename $@)).data.bin $(call FIXPATH,$(basename $@)).text.o $(call FIXPATH,$(basename $@)).data.o

# Assembly rule. We use .S for both RSP and MIPS assembly code, and we differentiate
# using the prefix of the filename: if it starts with "rsp", it is RSP ucode, otherwise
# it's a standard MIPS assembly file.
$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.S $(SOURCE_DIR)\%.S
#	@echo "     filename : $(notdir $(basename $@))"
	@$(MD) $(call FIXPATH,$(dir $@)) $(SENDNULL)	
	@echo "    [AS] $<"
	@$(CC) -c $(ASFLAGS) -o $(call FIXPATH,$@) $(call FIXPATH,$<)

# The following is a bash script embedded in the Makefile
#	set -e; \
#	FILENAME="$(notdir $(basename $@))"; \
#	@echo $$FILENAME \
#	if case "$$FILENAME" in "rsp"*) true;; *) false;; esac; then \
#		@echo "     if case" \
#		SYMPREFIX="$(subst .,_,$(subst /,_,$(basename $@)))"; \
#		TEXTSECTION="$(basename $@).text"; \
#		DATASECTION="$(basename $@).data"; \
#		BINARY="$(basename $@).elf"; \
#		echo "    [RSP] $<"; \
#		$(N64_CC) $(RSPASFLAGS) -nostartfiles -Wl,-Trsp.ld -Wl,--gc-sections -o $@ $<; \
#		mv "$@" $$BINARY; \
#		$(N64_OBJCOPY) -O binary -j .text $$BINARY $$TEXTSECTION.bin; \
#		$(N64_OBJCOPY) -O binary -j .data $$BINARY $$DATASECTION.bin; \
#		$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
#				--redefine-sym _binary_$${SYMPREFIX}_text_bin_start=$${FILENAME}_text_start \
#				--redefine-sym _binary_$${SYMPREFIX}_text_bin_end=$${FILENAME}_text_end \
#				--redefine-sym _binary_$${SYMPREFIX}_text_bin_size=$${FILENAME}_text_size \
#				--set-section-alignment .data=8 \
#				--rename-section .text=.data $$TEXTSECTION.bin $$TEXTSECTION.o; \
#		$(N64_OBJCOPY) -I binary -O elf32-bigmips -B mips4300 \
#				--redefine-sym _binary_$${SYMPREFIX}_data_bin_start=$${FILENAME}_data_start \
#				--redefine-sym _binary_$${SYMPREFIX}_data_bin_end=$${FILENAME}_data_end \
#				--redefine-sym _binary_$${SYMPREFIX}_data_bin_size=$${FILENAME}_data_size \
#				--set-section-alignment .data=8 \
#				--rename-section .text=.data $$DATASECTION.bin $$DATASECTION.o; \
#		$(N64_SIZE) -G $$BINARY; \
#		$(N64_LD) -relocatable $$TEXTSECTION.o $$DATASECTION.o -o $@; \
#		rm $$TEXTSECTION.bin $$DATASECTION.bin $$TEXTSECTION.o $$DATASECTION.o; \
#	else \
#		echo "    [AS] $<"; \
#		$(CC) -c $(ASFLAGS) -o $(call FIXPATH,$@) $(call FIXPATH,$<); \
#	fi
	

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c 
	@$(MD) $(call FIXPATH,$(dir $@)) $(SENDNULL)
	@echo "    [CC] $<"
	@$(CC) -c $(CFLAGS) -o $(call FIXPATH,$@) $(call FIXPATH,$<)

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	@$(MD) $(call FIXPATH,$(dir $@)) $(SENDNULL)
	@echo "    [CXX] $<"
	$(CXX) -c $(CXXFLAGS) -o $(call FIXPATH,$@) $(call FIXPATH,$<)

%.elf: $(N64_LIBDIR)/libdragon.a $(N64_LIBDIR)/libdragonsys.a $(N64_LIBDIR)/n64.ld 
	@$(MD) $(call FIXPATH,$(dir $@)) $(SENDNULL)
	@echo "    [LD] $@"	
# We always use g++ to link except for ucode because of the inconsistencies
# between ld when it comes to global ctors dtors. Also see __do_global_ctors
#	@echo $(LDFLAGS)
#	@echo $(CXX) -o $(call FIXPATH,$@) $(call FIXPATH,$(filter-out $(N64_LIBDIR)/n64.ld,$^)) -lc $(patsubst %,-Wl$(COMMA)%,$(LDFLAGS)) -Wl,-Map=$(call FIXPATH,$(BUILD_DIR)/$(notdir $(basename $@))).map
	$(CXX) -o $(call FIXPATH,$@) $(call FIXPATH,$(filter-out $(N64_LIBDIR)/n64.ld,$^)) -lc $(patsubst %,-Wl$(COMMA)%,$(LDFLAGS)) -Wl,-Map=$(call FIXPATH,$(BUILD_DIR)/$(notdir $(basename $@))).map
#	@echo $(N64_SIZE) -G $(call FIXPATH,$@)
	$(N64_SIZE) -G $(call FIXPATH,$@)

ifneq ($(V),1)
.SILENT:
endif
