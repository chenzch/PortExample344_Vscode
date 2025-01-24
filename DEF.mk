
# Output: List all path .h files (include/Fls_TestSetup.h include/Platform_Types.h ....)
INCLUDE_FILES := $(foreach DIR, $(INCLUDE_DIRS),$(wildcard $(DIR)/*.h))

# $(addsuffix suffix,names…)  : $(addsuffix .c,foo bar) ->  produces the result ‘foo.c bar.c’
#                             : $(addprefix src/,foo bar) -> produces the result ‘src/foo src/bar’
# Output: -Iinclude -I../include
CFLAGS := $(CFLAGS) $(addprefix -I, $(INCLUDE_DIRS))
# Output: List all .c and .s files (Fls_TestSetup.c exceptions.c Startup.s Vector_core.s)
SOURCE_FILES := $(foreach DIR,$(SRC_DIRS),$(notdir $(wildcard $(DIR)/*.c))) $(foreach DIR,$(SRC_DIRS),$(notdir $(wildcard $(DIR)/*.s))) $(foreach DIR,$(SRC_DIRS),$(notdir $(wildcard $(DIR)/*.S))) $(SOURCE_FILES)
# Object files
OUT_FILES := $(SOURCE_FILES:.c=.o)
OUT_FILES += $(SOURCE_FILES:.s=.o)
OUT_FILES += $(SOURCE_FILES:.S=.o)
ifeq ($(USE_DEFAULT_RTE), ON)
SRC_DIRS  := $(SRC_DIRS) $(PLUGINS_DIR)/Rte_$(AR_PKG_NAME)/src/
endif

winpath = $(foreach WINPATH_ITEM,$(1),$(patsubst /cygdrive/$(word 2,$(subst /, , $(WINPATH_ITEM)))%,$(word 2,$(subst /, ,$(WINPATH_ITEM))):%,$(WINPATH_ITEM)))
ifeq ($(realpath /),)
my_realpath = $1
my_abspath = $1
else
my_realpath = $(realpath $1)
my_abspath = $(abspath $1)
endif

## Testing to check whether it is a Windows environment or an Unix like
## one. This test is based on 'uname' command call. If the shell is a Windows one
## with no GNU binutils or similar tools, the command will raise a CreateProcess
## error but the makefile will detect the correct environment and work as expected.

SEPARATOR:===========================================================
UNAME_CMD:=uname
OS_DETECTED:=linux
mkdir_message:=Creating directory for object files
clean_message:=Removing files and directories from the compliation output
clean_all_message:=Removing files and directories from the compliation output and for the generation output

ifeq ($(OS_DETECTED), )
mkdir=mkdir_windows
clean_target=clean_windows
clean_all_target=clean_all_windows
env_predetection_msg=Checked for '$(UNAME_CMD)', not found
env_detected_msg=Assuming Windows environment
else
mkdir=mkdir_linux
clean_target=clean_linux
clean_all_target=clean_all_linux
env_predetection_msg=Checked for '$(UNAME_CMD)', found: $(OS_DETECTED)
env_detected_msg=Assuming Unix like environment
endif
SAMPLE_APP_DBG_DIR:=$(call winpath,$(CURDIR))/debug
## Targets ##
default: build

.PHONY: mkdir_windows
mkdir_windows:
	@echo $(SEPARATOR)
	@echo $(mkdir_message)
	@mkdir $(ODIR) || @echo Directory already exists

.PHONY: mkdir_linux
mkdir_linux:
	@echo $(SEPARATOR)
	@echo $(mkdir_message)
	@mkdir -p $(ODIR)

.PHONY: clean_windows
clean_windows:
	@echo $(SEPARATOR)
	@echo $(clean_message)
	@rmdir /s /q $(ODIR) || @echo Directory already cleaned

.PHONY: clean_linux
clean_linux:
	@echo $(SEPARATOR)
	@echo $(clean_message)
	@rm -fr $(ODIR)

.PHONY: clean_all_windows
clean_all_windows:
	@echo $(SEPARATOR)
	@echo $(clean_all_message)
	@rmdir /s /q $(ODIR) || @echo Directory already cleaned
	@rmdir /s /q $(GDIR) || @echo Directory already cleaned

.PHONY: clean_all_linux
clean_all_linux:
	@echo $(SEPARATOR)
	@echo $(clean_all_message)
	@rm -fr $(ODIR)
	@rm -fr $(GDIR)

.PHONY: build
build: $(ELFNAME).elf # Build the example
	@${SIZE} $(ODIR)/$(ELFNAME).elf
	@${OBJCOPY} -O ihex $(ODIR)/$(ELFNAME).elf $(ODIR)/$(ELFNAME).hex
	@${OBJCOPY} -O srec $(ODIR)/$(ELFNAME).elf $(ODIR)/$(ELFNAME).srec

$(ELFNAME).elf : $(OUT_FILES)
#add path for .o and .c filer to easy to automatically look up in sub folder
vpath %.c $(SRC_DIRS)
vpath %.o $(ODIR)
#add the rule to check if ODIR has been already created before start but we do want to rebuild .o so ODIR is added as order-only-prerequisites
%.o: %.c | $(ODIR)
    # The -c flag says to generate the object file, the -o $@ says to put the output of the compilation in the
    # file named on the left side of the :, the $< is the first item in the dependencies list and the CFLAGS macro is defined as above.
	@echo "Compiling $<"
	@$(CC) $(CCOPT) -c -o $(ODIR)/$@ $< $(CFLAGS) $(DEP_FLAG)

$(ODIR): $(mkdir)
vpath %.s $(addsuffix :, $(SRC_DIRS))
vpath %.S $(addsuffix :, $(SRC_DIRS))
%.o : %.s
	@echo "Compiling $<"
	@$(AS) $(ASOPT) $< -o $(ODIR)/$@ $(DEP_FLAG)
%.o : %.S
	@echo "Compiling $<"
	@$(AS) $(ASOPT) $< -o $(ODIR)/$@ $(DEP_FLAG)
# Link all the object files to become one elf file
#%.elf: %.o $(LINKER_DEF)
%.elf: $(LINKER_DEF)
	@echo "Linking $@"
	@$(LD) -Wl,-Map,"$(MAPFILE)" $(LDOPT) -T $(LINKER_DEF) $(ODIR)/*.o -o $(ODIR)/$@
#include new .d files which contain new rule created from gcc auto-depend generation
-include $(wildcard $(ODIR)/*.d)
.PHONY: clean_all
clean_all: $(clean_all_target) # Clean all object files and generated code

.PHONY: clean
clean: $(clean_target) # Clean all object files
