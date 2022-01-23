cmake_minimum_required(VERSION 3.18)

project(chat-server)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "-O2")

find_package(Threads REQUIRED)
find_package(Boost 1.74.0 COMPONENTS thread)
include_directories(${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

add_executable(server server/main.cpp server/src/functions.cpp server/src/inroom.cpp server/src/room.cpp server/src/server.cpp)
target_compile_options(server PUBLIC "-pthread")
target_link_libraries(server ${Boost_LIBRARIES} boost_thread)

#####################################################

project(chat-client)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "-O2")

find_package(Boost 1.74.0 COMPONENTS threads)
include_directories(${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})

find_package(OpenCL REQUIRED)
include_directories(${OpenCL_INCLUDE_DIRS})
link_directories(${OpenCL_LIBRARY})

add_executable(client client/main.cpp client/src/client.cpp client/ocle/src/ocle.cpp client/ocle/src/Base.cpp client/ocle/src/AES.cpp)
target_compile_options(client PUBLIC "-pthread")
target_link_libraries(client ${Boost_LIBRARIES} boost_thread ${OpenCL_LIBRARY})