# Build a katago library for iOS

```console
cmake . -DPLATFORM=SIMULATOR64 -DDEPLOYMENT_TARGET=15.0 -DUSE_BACKEND=COREML -DNO_GIT_REVISION=1 -DCMAKE_TOOLCHAIN_FILE=./ios.toolchain.cmake  -G Xcode
```