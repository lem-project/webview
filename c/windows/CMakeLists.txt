cmake_minimum_required(VERSION 3.20)
project(cl-webview-win LANGUAGES C CXX)

# MSVC x64 前提
if (NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This build expects MSVC on 64-bit (x64) Windows.")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

include(FetchContent)

# 上流 webview を取得（必要に応じてタグは調整）
FetchContent_Declare(
  webview
  GIT_REPOSITORY https://github.com/webview/webview
  GIT_TAG        0.12.0
)

# 共有ライブラリの生成を有効化
set(WEBVIEW_BUILD ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_SHARED_LIBRARY ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_STATIC_LIBRARY OFF CACHE BOOL "" FORCE)
# 公式 WebView2 Loader DLL に頼らない最小実装（既定ONだが明示）
set(WEBVIEW_USE_BUILTIN_MSWEBVIEW2 ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(webview)

# dist ディレクトリに生成物をまと�める（DLL/IMPLIB は必須、PDB は存在時のみ）
add_custom_target(stage ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/dist
  # DLL
  COMMAND ${CMAKE_COMMAND} -E copy
          $<TARGET_FILE:webview::core_shared>
          ${CMAKE_BINARY_DIR}/dist/webview.dll
  # インポートライブラリ（.lib）
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
          $<TARGET_LINKER_FILE:webview::core_shared>
          ${CMAKE_BINARY_DIR}/dist/webview.lib
  # PDB（存在すれば）
  COMMAND ${CMAKE_COMMAND}
          -DSRC=$<TARGET_PDB_FILE:webview::core_shared>
          -DDST=${CMAKE_BINARY_DIR}/dist/webview.pdb
          -P ${CMAKE_CURRENT_LIST_DIR}/CopyIfExists.cmake
  DEPENDS webview::core_shared
)

# BUILD.md の期待に合わせて DLL 名を固定したい場合は有効化
# set_target_properties(webview::core_shared PROPERTIES OUTPUT_NAME "libwebview")
