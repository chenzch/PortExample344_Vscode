BUILDTOOLS_DIR = $(S32DS_DIR)/S32DS/build_tools

#The path to the GCC installation dir
GCC_DIR = $(BUILDTOOLS_DIR)/gcc_v11.4/gcc-11.4-arm32-eabi

#The path to MSYS32 installation dir
export PATH := $(BUILDTOOLS_DIR)/msys32/usr/bin:$PATH

ifeq ("$(wildcard $(GCC_DIR)/bin/arm-none-eabi-gcc.exe)","")
	$(error Invalid path set to the GCC compiler. \
	The provided path: from project_parameters.mk GCC_DIR=$(GCC_DIR) is invalid!)
endif

# Compiler for C files, linker, S files
CC := $(GCC_DIR)/bin/arm-none-eabi-gcc.exe
LD := $(GCC_DIR)/bin/arm-none-eabi-gcc.exe
AS := $(GCC_DIR)/bin/arm-none-eabi-gcc.exe
SIZE    := $(GCC_DIR)/bin/arm-none-eabi-size.exe
OBJCOPY := $(GCC_DIR)/bin/arm-none-eabi-objcopy.exe

clib        := $(GCC_DIR)/arm-none-eabi/lib
specs       := nano.specs \
               nosys.specs

# -MT $@ Set the name of the target in the generated dependency file.
# -MMD Generate dependency information as a side-effect of compilation, not instead of compilation.
# -MP Adds a target for each prerequisite in the list, to avoid errors when deleting files.
# -MF Write the generated dependency file to out folder as .d extension
DEP_FLAG =-MT"$(@)" -MMD -MP -MF"$(ODIR)/$(*).d"
################################################################################
# Compiler options
################################################################################

CCOPT :=  $(CCOPT) \
          $(MISRA) \
          -DEU_DISABLE_ANSILIB_CALLS \
          -DUSE_SW_VECTOR_MODE \
          -c \
          -mcpu=cortex-m7 \
          -mthumb \
          -std=c99 \
          -Os \
          -mfpu=fpv5-sp-d16 \
          -mfloat-abi=hard  \
          -ggdb3 \
          -mlittle-endian \
          -Wall \
          -Wextra \
          -Wstrict-prototypes \
          -Wundef \
          -Wunused \
          -Werror=implicit-function-declaration \
          -Wsign-compare \
          -Wdouble-promotion \
          -fno-short-enums \
          -funsigned-char \
          -funsigned-bitfields \
          -fomit-frame-pointer \
          -fno-common \
          -ffunction-sections \
          -fdata-sections \
          -pedantic \
          --sysroot="$(clib)" \
          $(foreach spec, $(specs), -specs=$(spec))

LDOPT := --entry=Reset_Handler \
      --sysroot="$(clib)" \
      $(foreach spec, $(specs), -specs=$(spec)) \
      -nostartfiles \
      -mcpu=cortex-m7 \
      -mthumb \
      -mfpu=fpv5-sp-d16 \
      -mfloat-abi=hard  \
      -ggdb3 \
      -mlittle-endian \
      -Xlinker --gc-sections
#      -nostdlib \
#      -nodefaultlibs \
#      -lc
#      -lm
#      -lgcc

ASOPT := $(ASOPT) \
         -c \
         -mthumb \
         -mcpu=cortex-m7 \
         -mfpu=fpv5-sp-d16 \
         -mfloat-abi=hard  \
         -x assembler-with-cpp

# Disable MCAL intermodule asr check for ASR 4.4
CCOPT += -DDISABLE_MCAL_INTERMODULE_ASR_CHECK
