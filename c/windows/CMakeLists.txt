cmake_minimum_required(VERSION 3.20)
project(cl-webview-win LANGUAGES C CXX)

if (NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This build expects MSVC on 64-bit (x64) Windows.")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# ← 追加：/MT 静的ランタイム指定（VS 2019+ の正攻法）
#   上流にも効かせるため、FetchContent する前に設定します
if (MSVC)
  cmake_policy(SET CMP0091 NEW)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

include(FetchContent)

FetchContent_Declare(
  webview
  GIT_REPOSITORY https://github.com/webview/webview
  GIT_TAG        0.12.0
)

set(WEBVIEW_BUILD ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_SHARED_LIBRARY ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_STATIC_LIBRARY OFF CACHE BOOL "" FORCE)
set(WEBVIEW_USE_BUILTIN_MSWEBVIEW2 ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(webview)

add_custom_target(stage ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/dist
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:webview::core_shared> ${CMAKE_BINARY_DIR}/dist/webview.dll
  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_LINKER_FILE:webview::core_shared> ${CMAKE_BINARY_DIR}/dist/webview.lib
  COMMAND ${CMAKE_COMMAND} -DSRC=$<TARGET_PDB_FILE:webview::core_shared> -DDST=${CMAKE_BINARY_DIR}/dist/webview.pdb -P ${CMAKE_CURRENT_LIST_DIR}/CopyIfExists.cmake
  DEPENDS webview::core_shared
)
