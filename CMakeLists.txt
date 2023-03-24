# Set minimum required version of CMake
cmake_minimum_required(VERSION 3.13)

# Include build functions from Pico SDK
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

# Generate the PIO header file from the PIO source file.
pico_generate_pio_header(assign02 ${CMAKE_CURRENT_LIST_DIR}/ws2812.pio)

# Pull in commonly used features.
target_link_libraries(assign02 PRIVATE pico_stdlib hardware_pio)

# Creates a pico-sdk subdirectory in our project for the libraries
pico_sdk_init()

# Tell CMake where to find the executable source file
add_executable(${PROJECT_NAME} 
    assign02.c
    assign02.S
)

# Create map/bin/hex/uf2 files
pico_add_extra_outputs(${PROJECT_NAME})

# Link to pico_stdlib (gpio, time, etc. functions)
target_link_libraries(${PROJECT_NAME} 
    pico_stdlib
    pico_multicore # Needed for some of the later labs
)

# Enable uart output, disable usb output
pico_enable_stdio_usb(${PROJECT_NAME} 0)
pico_enable_stdio_uart(${PROJECT_NAME} 1)