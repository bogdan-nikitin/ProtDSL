cmake_minimum_required(VERSION 3.17)
project(SimProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

FetchContent_Declare(
    elfio
    GIT_REPOSITORY https://github.com/serge1/ELFIO.git
    GIT_TAG main
)

FetchContent_MakeAvailable(elfio)

find_program(RUBY_EXECUTABLE ruby REQUIRED)

set(GEN_DIR ${CMAKE_SOURCE_DIR}/gen)
file(MAKE_DIRECTORY ${GEN_DIR})
MESSAGE(INFO ${GEN_DIR})

add_custom_command(
    OUTPUT ${GEN_DIR}/.generated
    COMMAND ${RUBY_EXECUTABLE} ${CMAKE_SOURCE_DIR}/main.rb
    COMMAND ${CMAKE_COMMAND} -E touch ${GEN_DIR}/.generated
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running Ruby code generator"
)

add_custom_target(generate
    DEPENDS ${GEN_DIR}/.generated
)

file(GLOB_RECURSE SIM_SOURCES
    ${CMAKE_SOURCE_DIR}/Sim/lib/*.cpp
)

file(GLOB_RECURSE SIM_SOURCES
    ${CMAKE_SOURCE_DIR}/Sim/lib/*.cpp
)

add_executable(sim
    ${SIM_SOURCES}
)

add_dependencies(sim generate)

target_include_directories(sim PRIVATE
    ${CMAKE_SOURCE_DIR}/Sim/lib
    ${GEN_DIR}
    ${elfio_SOURCE_DIR}
)

target_link_libraries(sim PRIVATE elfio)
