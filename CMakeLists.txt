cmake_minimum_required(VERSION 3.13)
include(~/Desktop/pico/pico-apps/pico_sdk_import.cmake)
project(assign01 CXX C ASM)

pico_sdk_init()

file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/generated)

# Specify the name of the executable.
add_executable(assign02
assign02.c
)

# Generate the PIO header file from the PIO source file.
pico_generate_pio_header(assign02 ${CMAKE_CURRENT_LIST_DIR}/led.pio)

# Specify the source files to be compiled.
target_sources(assign02 PRIVATE assign02.c assign02.S)

# Pull in commonly used features.
target_link_libraries(assign02 pico_stdlib hardware_pio)

# Create map/bin/hex file etc.
pico_add_extra_outputs(assign02)

# Add the URL via pico_set_program_url.
#apps_auto_set_url(assign02)
