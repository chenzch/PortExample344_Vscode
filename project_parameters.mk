#Select a toolchain from the list: replace_toolchain_list
TOOLCHAIN = gcc

BUILDTOOLS_DIR = /d/NXP/S32DS.3.5/S32DS/build_tools

#The path to the GCC installation dir
GCC_DIR = $(BUILDTOOLS_DIR)/gcc_v10.2/gcc-10.2-arm32-eabi

#The path to MSYS32 installation dir
MSYS32_DIR = $(BUILDTOOLS_DIR)/msys32

ifeq ("$(wildcard $(GCC_DIR)/bin/arm-none-eabi-gcc.exe)","")
	$(error Invalid path set to the GCC compiler. \
	The provided path: from project_parameters.mk GCC_DIR=$(GCC_DIR) is invalid!)
endif

MCAL_DIR = /d/NXP/AUTOSAR/SW32K3_S32M27x_RTD_4.4_4.0.0_P24

#The path to the Tresos plugins directory
PLUGINS_DIR = $(MCAL_DIR)/eclipse/plugins

#The path to the Tresos add-on plugins directory
PLUGINS_DIR_ADDON =

#The paths to the additional directories to be included at build phase
ADDITIONAL_INCLUDE_DIRS =

# ------------------------------------------------------------------------------------
#Example specific parameters - do not modify

#MCAL modules used
MCAL_MODULE_LIST := Resource BaseNXP Platform Mcu Dem Dio EcuC Port Det

#MCAL modules used - only for examples based on 2 software products
MCAL_MODULE_LIST_ADDON :=

#The package name for the MCAL release
AR_PKG_NAME = TS_T40D34M40I0R0

#The AUTOSAR module origin ('NXP')
AR_MODULE_ORIGIN = NXP

#The package name for the MCAL release - only for examples based on 2 software products
AR_PKG_NAME_ADDON =

#The derivative of the device
EXAMPLE_DERIVATIVE = S32K344

#The name of the elf file
ELFNAME = main

export PATH := $(MSYS32_DIR)/usr/bin:$PATH
