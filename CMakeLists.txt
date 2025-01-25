cmake_minimum_required(VERSION 3.10)

set(CMAKE_PROJECT_NAME "Port_Example_S32K344")

set(S32DS_DIR "C:/NXP/S32DS.3.6")
set(RTD_DIR "C:/Users/peter_chen.WTMEC/SyncData/AUTOSAR/SW32K3_RTD_R21-11_4.0.0_HF_02")
set(AR_PKG_NAME "TS_T40D34M40I0R0")
set(MCAL_MODULE_LIST Resource BaseNXP Platform Mcu Dem Dio EcuC Port Det)

set(CMAKE_BUILD_TYPE "Debug")
option(USE_DEFAULT_RTE "Use default RTE" ON)
option(USE_DEFAULT_STARTUP "Use default RTE" ON)

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

file(GLOB LD_FILE "linker_flash_s32k344.ld")

#---------------------------------------------------------------------------------------
# Set toolchain
#---------------------------------------------------------------------------------------
# Target definition
set(CMAKE_SYSTEM_NAME  Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# Include the toolchain file
set(TOOLCHAIN_PREFIX "${S32DS_DIR}/S32DS/build_tools/gcc_v11.4/gcc-11.4-arm32-eabi")

set(TOOLCHAIN arm-none-eabi)
if(NOT DEFINED TOOLCHAIN_PREFIX)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
        set(TOOLCHAIN_PREFIX "/usr")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
        set(TOOLCHAIN_PREFIX "/usr/local")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
        message(STATUS "Please specify the TOOLCHAIN_PREFIX !\n For example: -DTOOLCHAIN_PREFIX=\"C:/Program Files/GNU Tools ARM Embedded\" ")
    else()
        set(TOOLCHAIN_PREFIX "/usr")
        message(STATUS "No TOOLCHAIN_PREFIX specified, using default: " ${TOOLCHAIN_PREFIX})
    endif()
endif()
set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/lib)

# Set system depended extensions
if(WIN32)
    set(TOOLCHAIN_EXT ".exe" )
else()
    set(TOOLCHAIN_EXT "" )
endif()

# Perform compiler test with static library
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#---------------------------------------------------------------------------------------
# Set compiler/linker flags
#---------------------------------------------------------------------------------------

# Object build options
# -O0                   No optimizations, reduce compilation time and make debugging produce the expected results.
# -mthumb               Generat thumb instructions.
# -fno-builtin          Do not use built-in functions provided by GCC.
# -Wall                 Print only standard warnings, for all use Wextra
# -ffunction-sections   Place each function item into its own section in the output file.
# -fdata-sections       Place each data item into its own section in the output file.
# -fomit-frame-pointer  Omit the frame pointer in functions that don’t need one.
set(OBJECT_GEN_FLAGS "-pedantic -Wall -Wextra -Wunused -Wstrict-prototypes -Wsign-compare -Werror=implicit-function-declaration -Wundef -Wdouble-promotion -ffunction-sections -fdata-sections -fomit-frame-pointer -funsigned-char -fomit-frame-pointer -fno-short-enums -funsigned-bitfields -fno-common -mcpu=cortex-m7 -mthumb -mlittle-endian -mfloat-abi=hard -mfpu=fpv5-sp-d16 -specs=nano.specs -specs=nosys.specs --sysroot=\"${TOOLCHAIN_LIB_DIR}\"")

set(CMAKE_C_FLAGS   "${OBJECT_GEN_FLAGS} -std=c99 " CACHE INTERNAL "C Compiler options")
set(CMAKE_CXX_FLAGS "${OBJECT_GEN_FLAGS} -std=c++11 " CACHE INTERNAL "C++ Compiler options")
set(CMAKE_ASM_FLAGS "${OBJECT_GEN_FLAGS} -x assembler-with-cpp " CACHE INTERNAL "ASM Compiler options")


# -Wl,--gc-sections     Perform the dead code elimination.
# --specs=nano.specs    Link with newlib-nano.
# --specs=nosys.specs   No syscalls, provide empty implementations for the POSIX system calls.
set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -ggdb3 -Wl,--gc-sections -Wl,-Map=${CMAKE_PROJECT_NAME}.map  -mcpu=cortex-m7 -mthumb -mlittle-endian -mfloat-abi=hard -mfpu=fpv5-sp-d16 --sysroot=\"${TOOLCHAIN_LIB_DIR}\"" CACHE INTERNAL "Linker options")

#---------------------------------------------------------------------------------------
# Set debug/release build configuration Options
#---------------------------------------------------------------------------------------

# Options for DEBUG build
# -Og   Enables optimizations that do not interfere with debugging.
# -g    Produce debugging information in the operating system’s native format.
set(CMAKE_C_FLAGS_DEBUG "-O0 -ggdb3" CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -ggdb3" CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG "-g3" CACHE INTERNAL "ASM Compiler options for debug build type")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Linker options for debug build type")

# Options for RELEASE build
# -Os   Optimize for size. -Os enables all -O2 optimizations.
# -flto Runs the standard link-time optimizer.
set(CMAKE_C_FLAGS_RELEASE "-Os -ggdb3 -flto" CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -ggdb3 -flto" CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE "-g3" CACHE INTERNAL "ASM Compiler options for release build type")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "Linker options for release build type")

#---------------------------------------------------------------------------------------
# Set compilers
#---------------------------------------------------------------------------------------
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX}/${${TOOLCHAIN}} ${CMAKE_PREFIX_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T ${LD_FILE} --entry=Reset_Handler")

set(PLUGINS_DIR "${RTD_DIR}/eclipse/plugins")

foreach(MODULE ${MCAL_MODULE_LIST})
    include_directories(${PLUGINS_DIR}/${MODULE}_${AR_PKG_NAME}/include)
    aux_source_directory(${PLUGINS_DIR}/${MODULE}_${AR_PKG_NAME}/src SOURCES)
endforeach()
include_directories(${PLUGINS_DIR}/BaseNXP_${AR_PKG_NAME}/header)

if(USE_DEFAULT_STARTUP)
    # Using default startup
    message(STATUS "Using default startup")
    aux_source_directory(${PLUGINS_DIR}/Platform_${AR_PKG_NAME}/startup/src SOURCES)
    aux_source_directory(${PLUGINS_DIR}/Platform_${AR_PKG_NAME}/startup/src/m7 SOURCES)
    file(GLOB ASM_SOURCES "${PLUGINS_DIR}/Platform_${AR_PKG_NAME}/startup/src/m7/gcc/*.s")
    list(APPEND SOURCES ${ASM_SOURCES})
    include_directories(${PLUGINS_DIR}/Platform_${AR_PKG_NAME}/startup/include)
else()
    message(STATUS "Using custom startup")
endif()

if(USE_DEFAULT_RTE)
    # Get only needed Rte files
    message(STATUS "Using default RTE")
    foreach(MODULE ${MCAL_MODULE_LIST})
        file(GLOB RTE_SOURCE "${PLUGINS_DIR}/Rte_${AR_PKG_NAME}/src/SchM_${MODULE}.c")
        list(APPEND SOURCES ${RTE_SOURCE})
    endforeach()
    include_directories(${PLUGINS_DIR}/Rte_${AR_PKG_NAME}/include)
else()
    message(STATUS "Using custom RTE")
endif()

# Set the project name
project(${CMAKE_PROJECT_NAME} C ASM)

# Create an executable from the source files
add_executable(${CMAKE_PROJECT_NAME}.elf ${SOURCES})

# Add a custom command to run arm-none-eabi-size after building
add_custom_command(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-size${TOOLCHAIN_EXT} ${CMAKE_PROJECT_NAME}.elf
    COMMENT "Displaying the size of the executable"
)
# Add objcopy to ihex & srec
add_custom_command(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy${TOOLCHAIN_EXT} -O ihex ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.hex
    COMMAND ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy${TOOLCHAIN_EXT} -O srec ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.srec
    COMMENT "Converting ELF to HEX and SREC"
)
