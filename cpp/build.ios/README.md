# Build a katago library for iOS

CMakeLists.txt is copied from `cpp/CMakeLists.txt`, and modified for:
1. source directory
2. remove main.cpp
3. added coreml framework
4. run with iOS toolchain

* Using OS64COMBINED will build the FAT-lib for both device and simulator 
```console
cmake . -DENABLE_BITCODE=1 -DPLATFORM=OS64COMBINED -DDEPLOYMENT_TARGET=15.0 -DUSE_BACKEND=COREML -DNO_GIT_REVISION=1 -DCMAKE_TOOLCHAIN_FILE=./ios.toolchain.cmake  -G Xcode
```
