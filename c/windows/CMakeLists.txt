cmake_minimum_required(VERSION 3.20)
project(cl-webview-win LANGUAGES C CXX)

# x64 前提
if (NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This build expects MSVC on 64-bit (x64) Windows.")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

include(FetchContent)
# 上流 webview を取得（必要に応じてタグ固定）
FetchContent_Declare(
  webview
  GIT_REPOSITORY https://github.com/webview/webview
  GIT_TAG        0.12.0
)
FetchContent_MakeAvailable(webview)

# C API を DLL 化（CFFI からロードする想定）
add_library(webview SHARED)

# 上流の C API 実装（パスは上流リポ構成に追従）
target_sources(webview PRIVATE
  ${webview_SOURCE_DIR}/webview/webview_capi.cpp
)

# 上流のコアにリンク
target_link_libraries(webview PRIVATE webview::core)

# 必要に応じて DLL 名を固定したい場合は有効化
# set_target_properties(webview PROPERTIES OUTPUT_NAME "libwebview")

# 出力先
set_target_properties(webview PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if (MSVC)
  target_compile_definitions(webview PRIVATE -DUNICODE -D_UNICODE)
  # 静的ランタイム (/MT) にしたい場合は以下を有効化
  # foreach(flag_var  CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE)
  #   string(REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
  # endforeach()
endif()

target_compile_definitions(webview PRIVATE WEBVIEW_LISP_BINDING=1)
