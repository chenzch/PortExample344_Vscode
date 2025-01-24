#The path to the Tresos plugins directory
PLUGINS_DIR = $(RTD_DIR)/eclipse/plugins

# Get only needed Rte files
find_files = $(wildcard $(PLUGINS_DIR)/Rte_$(AR_PKG_NAME)/src/SchM_$(mod).c)
# Get RTE source files
RTE_FILES_WITH_PATH := $(foreach mod,$(MCAL_MODULE_LIST),$(find_files))

# Get only the file names, path will be added later
RTE_INC      := $(PLUGINS_DIR)/Rte_$(AR_PKG_NAME)/include

RTE_SRC      := $(foreach file,$(RTE_FILES_WITH_PATH),$(file:$(PLUGINS_DIR)/Rte_$(AR_PKG_NAME)/src/%=%))

INCLUDE_DIRS := $(INCLUDE_DIRS) \
                $(foreach mod,$(MCAL_MODULE_LIST),$(PLUGINS_DIR)/$(mod)_$(AR_PKG_NAME)/include) \
                $(foreach mod,$(MCAL_MODULE_LIST_ADDON),$(PLUGINS_DIR_ADDON)/$(mod)_$(AR_PKG_NAME_ADDON)/include) \
                $(PLUGINS_DIR)/BaseNXP_$(AR_PKG_NAME)/header \

SRC_DIRS     := $(SRC_DIRS) \
                $(foreach mod,$(MCAL_MODULE_LIST),$(PLUGINS_DIR)/$(mod)_$(AR_PKG_NAME)/src) \
                $(foreach mod,$(MCAL_MODULE_LIST_ADDON),$(PLUGINS_DIR_ADDON)/$(mod)_$(AR_PKG_NAME_ADDON)/src)

STARTUP_INC  := $(PLUGINS_DIR)/Platform_$(AR_PKG_NAME)/startup/include

STARTUP_DIRS := $(PLUGINS_DIR)/Platform_$(AR_PKG_NAME)/startup/src \
                $(PLUGINS_DIR)/Platform_$(AR_PKG_NAME)/startup/src/m7 \
                $(PLUGINS_DIR)/Platform_$(AR_PKG_NAME)/startup/src/m7/gcc

ifeq ($(USE_DEFAULT_STARTUP), ON)
# Using default startup
SRC_DIRS := $(SRC_DIRS) $(STARTUP_DIRS)
INCLUDE_DIRS := $(INCLUDE_DIRS) $(STARTUP_INC)
endif

ifeq ($(USE_DEFAULT_RTE), ON)
# Using default RTE
SOURCE_FILES := $(SOURCE_FILES) $(RTE_SRC)
INCLUDE_DIRS := $(INCLUDE_DIRS) $(RTE_INC)
endif
