cmake_minimum_required(VERSION 3.15)
project(CodeQLTestCpp VERSION 1.0 LANGUAGES CXX)

# C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler warnings (but allow unsafe code for demo purposes)
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra)
endif()

# Source files
set(SOURCES
    src/main.cpp
    src/vulnerable.cpp
)

# Executable
add_executable(vulnerable_app ${SOURCES})

# Include directories
target_include_directories(vulnerable_app PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
