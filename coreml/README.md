# How to convert tf model to coreml

## Prepare:
1. Get the tensorflow source code and put them in `~/OpenSources`, and build with the following command to build the tools
    ```concolse
    ./configure
    bazel build //tensorflow/tools/pip_package:build_pip_package
    ```
2. Install Tensorflow version 2.x
```console
pip install tensorflow
```
3. Locate the freeze_graph, and edit FROZEN_MODEL in `Makefile`


## Make
1. `make saved_model/saved_model.pb`
2. `make tmp/frozen_model.pb`
3. `make tmp/optimized.pb`
4. `make saved_model2/saved_model.pb`
5. `python convert_coreml.py` to convert the final model to coreml model.
