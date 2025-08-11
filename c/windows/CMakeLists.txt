cmake_minimum_required(VERSION 3.20)
project(cl-webview-win LANGUAGES C CXX)

if (NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This build expects MSVC on 64-bit (x64) Windows.")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

include(FetchContent)

# upstream を取得（必要ならタグは調整）
FetchContent_Declare(
  webview
  GIT_REPOSITORY https://github.com/webview/webview
  GIT_TAG        0.12.0
)

# upstream のビルドを有効化（共有ライブラリを作る）
set(WEBVIEW_BUILD ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_SHARED_LIBRARY ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_STATIC_LIBRARY OFF CACHE BOOL "" FORCE)
# 公式 WebView2 Loader DLL に頼らない最小実装（既定で ON だが明示しておく）
set(WEBVIEW_USE_BUILTIN_MSWEBVIEW2 ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(webview)

# 生成物を取り出しやすい場所へコピーするターゲット
add_custom_target(stage ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/dist
  COMMAND ${CMAKE_COMMAND} -E copy          $<TARGET_FILE:webview::core_shared>       ${CMAKE_BINARY_DIR}/dist/webview.dll
  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_LINKER_FILE:webview::core_shared> ${CMAKE_BINARY_DIR}/dist/webview.lib
  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_PDB_FILE:webview::core_shared>    ${CMAKE_BINARY_DIR}/dist/webview.pdb
  DEPENDS webview::core_shared
)

# 必要なら DLL 名を固定（BUILD.md に合わせて）
# set_target_properties(webview::core_shared PROPERTIES OUTPUT_NAME "libwebview")
