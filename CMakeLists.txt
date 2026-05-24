cmake_minimum_required(VERSION 3.22)

project(
    learn_cuda
    LANGUAGES C CXX CUDA
)

list(PREPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(ProjectEssentials)

option(BUILD_SHARED_LIBS "Build using shared libraries." OFF)
