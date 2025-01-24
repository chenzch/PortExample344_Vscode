#The name of the elf file
ELFNAME = PortExample344

RTD_DIR = /c/Users/peter_chen.WTMEC/SyncData/AUTOSAR/SW32K3_RTD_R21-11_4.0.0_HF_02
MCAL_MODULE_LIST := Resource BaseNXP Platform Mcu Dem Dio EcuC Port Det

USE_DEFAULT_STARTUP := ON
USE_DEFAULT_RTE     := ON

#$(foreach mod,$(MCAL_MODULE_LIST_ADDON),$(PLUGINS_DIR_ADDON)/$(mod)_$(AR_PKG_NAME_ADDON)/include)
#$(foreach mod,$(MCAL_MODULE_LIST_ADDON),$(PLUGINS_DIR_ADDON)/$(mod)_$(AR_PKG_NAME_ADDON)/src)
MCAL_MODULE_LIST_ADDON :=
PLUGINS_DIR_ADDON =
AR_PKG_NAME_ADDON =

AR_PKG_NAME = TS_T40D34M40I0R0

include RTD.mk

S32DS_DIR = /c/NXP/S32DS.3.6

include S32DS.mk

ODIR=Debug
GDIR=generate
# Path to folders
SRC_DIRS := src \
            generate/src \
			$(SRC_DIRS)

INCLUDE_DIRS := include \
                generate/include \
				$(INCLUDE_DIRS)

CCOPT   :=  $(CCOPT) \
        -DS32K3XX \
        -DS32K344 \
        -DCPU_S32K344 \
        -DD_CACHE_ENABLE \
        -DI_CACHE_ENABLE \
        -DMPU_ENABLE \
        -DENABLE_FPU \
        -DGCC \
        -DVV_RESULT_ADDRESS=0x2043FF00 \
        -DBTB_ENABLE

LINKER_DEF:= linker_flash_s32k344.ld

MAPFILE = $(ODIR)/$(ELFNAME).map

include DEF.mk
