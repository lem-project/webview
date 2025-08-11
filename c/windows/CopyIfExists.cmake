# 使い方:
#   cmake -D SRC=<source_path> -D DST=<dest_path> -P CopyIfExists.cmake
if(DEFINED SRC AND DEFINED DST)
  if(EXISTS "${SRC}")
    file(COPY_FILE "${SRC}" "${DST}")
  endif()
endif()
