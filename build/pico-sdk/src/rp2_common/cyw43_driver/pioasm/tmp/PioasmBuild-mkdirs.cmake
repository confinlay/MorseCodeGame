# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/conor/Desktop/pico/pico-sdk/tools/pioasm"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pioasm"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/tmp"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/src/PioasmBuild-stamp"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/src"
  "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/src/PioasmBuild-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/src/PioasmBuild-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/conor/Desktop/pico/pico-apps/assignments/assign02/build/pico-sdk/src/rp2_common/cyw43_driver/pioasm/src/PioasmBuild-stamp${cfgdir}") # cfgdir has leading slash
endif()
