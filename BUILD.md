```
cd c/
cmake -G Ninja -B build -S . -D CMAKE_BUILD_TYPE=Release
cmake --build build

cd ../
mkdir -p lib/<os>/<arch>/
cp -r c/build/lib/* lib/<os>/<arch>/*
```
