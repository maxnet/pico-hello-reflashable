cmake_minimum_required(VERSION 3.13)

include(pico-sdk/pico_sdk_init.cmake)
project(pico_hello_reflashable)
pico_sdk_init()

add_executable(${PROJECT_NAME} hello_reflashable.c)

pico_enable_stdio_usb(${PROJECT_NAME} 1)
pico_enable_stdio_uart(${PROJECT_NAME} 0)
target_link_libraries(${PROJECT_NAME} pico_stdlib)
pico_add_extra_outputs(${PROJECT_NAME})
target_compile_definitions(${PROJECT_NAME} PRIVATE PICO_ENTER_USB_BOOT_ON_EXIT=1)
