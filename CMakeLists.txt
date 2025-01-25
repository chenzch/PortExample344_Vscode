cmake_minimum_required(VERSION 3.10)

set(S32DS_DIR "C:/NXP/S32DS.3.6")
set(RTD_DIR "C:/Users/peter_chen.WTMEC/SyncData/AUTOSAR/SW32K3_RTD_R21-11_4.0.0_HF_02")
set(AR_PKG_NAME "TS_T40D34M40I0R0")
set(MCAL_MODULE_LIST Resource BaseNXP Platform Mcu Dem Dio EcuC Port Det)

file(GLOB LD_FILE "linker_flash_s32k344.ld")

set(CMAKE_BUILD_TYPE "Debug")
option(USE_DEFAULT_RTE "Use default RTE" ON)
option(USE_DEFAULT_STARTUP "Use default RTE" ON)

# Include the toolchain file
include("S32DS.cmake")

# Set the project name
project(Port_Example_S32K344 C ASM)

# Add definitions
add_definitions(-DS32K3XX)
add_definitions(-DS32K344)
add_definitions(-DD_CACHE_ENABLE)
add_definitions(-DI_CACHE_ENABLE)
add_definitions(-DENABLE_FPU)
add_definitions(-DGCC)
add_definitions(-DCPU_S32K344)
add_definitions(-DVV_RESULT_ADDRESS=0x2043FF00)
add_definitions(-DMPU_ENABLE)
add_definitions(-DBTB_ENABLE)

# Add the source directories
aux_source_directory(src SOURCES)
aux_source_directory(generate/src SOURCES)

include_directories(include)
include_directories(generate/include)

# Create an executable from the source files
add_executable(${CMAKE_PROJECT_NAME} ${SOURCES})

# Add a custom command to run arm-none-eabi-size after building
add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-size${TOOLCHAIN_EXT} ${CMAKE_PROJECT_NAME}
    COMMENT "Displaying the size of the executable"
)
# Add objcopy to ihex & srec
add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy${TOOLCHAIN_EXT} -O ihex ${CMAKE_PROJECT_NAME} ${CMAKE_PROJECT_NAME}.hex
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy${TOOLCHAIN_EXT} -O srec ${CMAKE_PROJECT_NAME} ${CMAKE_PROJECT_NAME}.srec
    COMMENT "Converting ELF to HEX and SREC"
)
