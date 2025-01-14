#ifdef USE_COREML_BACKEND

#import <CoreML/CoreML.h>
#import <TargetConditionals.h>

#include "../neuralnet/nninterface.h"
#include "../neuralnet/nninputs.h"
#include "../neuralnet/nneval.h"
#include "../neuralnet/modelversion.h"

#import "Katagob40.h"

using namespace std;

struct ComputeContext {
  const int nnXLen;
  const int nnYLen;
  const LoadedModel *loadedModel;
  enabled_t usingNHWCMode;
  
  ComputeContext() = delete;
  ComputeContext(const ComputeContext&) = delete;
  ComputeContext& operator=(const ComputeContext&) = delete;
  
  ComputeContext(const LoadedModel* loadedModel, int nnX, int nnY, enabled_t useNHWCMode)
  : nnXLen(nnX),
  nnYLen(nnY),
  loadedModel(loadedModel),
  usingNHWCMode(useNHWCMode)
  {}
  
  ~ComputeContext()
  {}
};

struct ComputeHandle {
  const ComputeContext *context;
  int maxBatchSize;
  int nnXLen;
  int nnYLen;
  int policySize;
  bool inputsUseNHWC;
  
  ComputeHandle() = delete;
  ComputeHandle(const ComputeHandle&) = delete;
  ComputeHandle& operator=(const ComputeHandle&) = delete;
  
  ComputeHandle(const ComputeContext* ctx, const LoadedModel& loadedModel, int maxBSize, bool inputsNHWC)
  : context(ctx),
  maxBatchSize(maxBSize)
  {
    nnXLen = context->nnXLen;
    nnYLen = context->nnYLen;
    
    policySize = NNPos::getPolicySize(nnXLen, nnYLen);
    inputsUseNHWC = inputsNHWC;
  }
  
  ~ComputeHandle() { }
};

struct LoadedModel {
  ModelDesc modelDesc;
  Katagob40 *model;
  
  LoadedModel(const string& file,  const string& expectedSha256) {
    // file should be the path doesn't contain extension
    // i.e. Katagob40 (NOT katatrain/Models/Katagob40.mlmodelc)
    (void)expectedSha256;
    
    NSString *nsfile = [NSString stringWithCString:file.c_str() encoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSURL *url = [[NSBundle mainBundle] URLForResource:nsfile withExtension:@"plist"];
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:nsfile
                                              withExtension:@"mlmodelc"];
#elif TARGET_OS_OSX
    NSURL *url = [NSURL fileURLWithPath: [NSString stringWithFormat: @"%@.plist", nsfile]];
    NSURL *modelUrl = [NSURL fileURLWithPath: [NSString stringWithFormat: @"%@.mlmodelc", nsfile]];
#endif
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    assert(error == nil);
    NSDictionary *descDict = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
    assert(error == nil);
    
    
    modelDesc = ModelDesc([descDict[@"version"] intValue],
                          [descDict[@"numInputChannels"] intValue],
                          [descDict[@"numInputGlobalChannels"] intValue],
                          [descDict[@"numValueChannels"] intValue],
                          [descDict[@"numScoreValueChannels"] intValue],
                          [descDict[@"numOwnershipChannels"] intValue]);
    

    
    model = [[Katagob40 alloc] initWithContentsOfURL:modelUrl error:&error];
    
    assert(error == nil);
  }
  
  LoadedModel() = delete;
  LoadedModel(const LoadedModel&) = delete;
  LoadedModel& operator=(const LoadedModel&) = delete;
};

LoadedModel* NeuralNet::loadModelFile(const string& file,  const string& expectedSha256) {
  return new LoadedModel(file, expectedSha256);
}

void NeuralNet::freeLoadedModel(LoadedModel* loadedModel) {
  delete loadedModel;
}

string NeuralNet::getModelName(const LoadedModel* loadedModel) {
  return loadedModel->modelDesc.name;
}
int NeuralNet::getModelVersion(const LoadedModel* loadedModel) {
  return loadedModel->modelDesc.version;
}

//Return the "nearest" supported ruleset to desiredRules by this model.
//Fills supported with true if desiredRules itself was exactly supported, false if some modifications had to be made.
Rules NeuralNet::getSupportedRules(const LoadedModel* loadedModel, const Rules& desiredRules, bool& supported) {
  return loadedModel->modelDesc.getSupportedRules(desiredRules, supported);
}

// Call globalInitialize() once upon program startup to construct the net.
void NeuralNet::globalInitialize() {
  
}

// Call globalCleanup() at program termination.
void NeuralNet::globalCleanup() {
  
}

//Print available backend devices
void NeuralNet::printDevices() {
  
}

// The interface for the input buffers for the neural network. The MCTS code
// uses this interface to pass data into the neural network for computation.
struct InputBuffers {
  int maxBatchSize;
  
  size_t singleInputElts;
  size_t singleInputGlobalElts;
  size_t singlePolicyResultElts;
  size_t singleValueResultElts;
  size_t singleScoreValueResultElts;
  size_t singleOwnershipResultElts;
  
  size_t userInputBufferElts;
  size_t userInputGlobalBufferElts;
  
  float* userInputBuffer; //Host pointer
  float* userInputGlobalBuffer; //Host pointer
  
  InputBuffers(const LoadedModel* loadedModel, int maxBatchSz, int nnXLen, int nnYLen) {
    const ModelDesc& m = loadedModel->modelDesc;
    
    int xSize = nnXLen;
    int ySize = nnYLen;
    
    maxBatchSize = maxBatchSz;
    
    singleInputElts = (size_t)m.numInputChannels * xSize * ySize;
    singleInputGlobalElts = (size_t)m.numInputGlobalChannels;
    singlePolicyResultElts = NNPos::getPolicySize(xSize, ySize);
    singleValueResultElts = (size_t)m.numValueChannels;
    singleScoreValueResultElts = (size_t)m.numScoreValueChannels;
    singleOwnershipResultElts = (size_t)m.numOwnershipChannels * xSize * ySize;
    
    assert(NNModelVersion::getNumSpatialFeatures(m.version) == m.numInputChannels);
    assert(NNModelVersion::getNumGlobalFeatures(m.version) == m.numInputGlobalChannels);
    
    userInputBufferElts = (size_t)m.numInputChannels * maxBatchSize * xSize * ySize;
    userInputGlobalBufferElts = (size_t)m.numInputGlobalChannels * maxBatchSize;

    userInputBuffer = new float[maxBatchSize * singleInputElts];
    userInputGlobalBuffer = new float[singleInputGlobalElts * maxBatchSize];
  }
  ~InputBuffers() {
    delete[] userInputBuffer;
    delete[] userInputGlobalBuffer;
  }
};

// Context -------------------------------------------------------------------

ComputeContext* NeuralNet::createComputeContext(const vector<int>& gpuIdxs,
                                                Logger* logger,
                                                int nnXLen,
                                                int nnYLen,
                                                const string& openCLTunerFile,
                                                const string& homeDataDirOverride,
                                                bool openCLReTunePerBoardSize,
                                                enabled_t useFP16Mode,
                                                enabled_t useNHWCMode,
                                                const LoadedModel* loadedModel) {
  (void)gpuIdxs;
  (void)logger;
  (void)openCLTunerFile;
  (void)homeDataDirOverride;
  (void)openCLReTunePerBoardSize;
  (void)useFP16Mode;
  ComputeContext* context = new ComputeContext(loadedModel, nnXLen, nnYLen, useNHWCMode);
  return context;
}

void NeuralNet::freeComputeContext(ComputeContext* computeContext) {
  delete computeContext;
}

// Compute Handle -----------------------------------------------------------------

// Any given thread should only ever create one of these at a time.
// When using the CUDA backend, will mutably set the GPU that this thread is
// associated with to the specified index. If logger is specified, may output
// some info messages to it. If requireExactNNLen is true, the backend is
// allowed to assume that all boards to evaluate will be of size exactly equal
// to (nnXLen,nnYLen) rather than smaller, and skip any masking operations.
// gpuIdxForThisThread == -1 indicates to select a default GPU.
ComputeHandle* NeuralNet::createComputeHandle(
                                              ComputeContext* context,
                                              const LoadedModel* loadedModel,
                                              Logger* logger,
                                              int maxBatchSize,
                                              bool requireExactNNLen,
                                              bool inputsUseNHWC,
                                              int gpuIdxForThisThread,
                                              int serverThreadIdx) {
  (void)logger;
  (void)requireExactNNLen;
  (void)gpuIdxForThisThread;
  (void)serverThreadIdx;
  return new ComputeHandle(context, *loadedModel, maxBatchSize, inputsUseNHWC);
}

void NeuralNet::freeComputeHandle(ComputeHandle* computeHandle) {
  delete computeHandle;
}

//Input Buffers ---------------------------------------------------------------

InputBuffers* NeuralNet::createInputBuffers(const LoadedModel* loadedModel, int maxBatchSize, int nnXLen, int nnYLen) {
  return new InputBuffers(loadedModel, maxBatchSize, nnXLen, nnYLen);
}
void NeuralNet::freeInputBuffers(InputBuffers* buffers) {
  delete buffers;
}

// Result: mutably writes the results of the numBatchEltsFilled many parallel neural net evaluations
// into the NNOutput structs.
// All outputs are in logits - all final activation functions softmax, tanh, etc. are NOT applied.
void NeuralNet::getOutput(ComputeHandle* computeHandle,
                          InputBuffers* inputBuffers,
                          int numBatchEltsFilled,
                          NNResultBuf** inputBufs,
                          vector<NNOutput*>& outputs) {
  int batchSize = numBatchEltsFilled;
  int nnXLen = computeHandle->nnXLen;
  int nnYLen = computeHandle->nnYLen;
  int version = computeHandle->context->loadedModel->modelDesc.version;
  
  int numSpatialFeatures = NNModelVersion::getNumSpatialFeatures(version);
  int numGlobalFeatures = NNModelVersion::getNumGlobalFeatures(version);
  
  NSError *error = nil;
  
  NSMutableArray *inputs = [[NSMutableArray alloc] init];
  for(int nIdx = 0; nIdx < batchSize; nIdx++) {
    float* rowSpatialInput = inputBuffers->userInputBuffer + (inputBuffers->singleInputElts * nIdx);
    float* rowGlobalInput = inputBuffers->userInputGlobalBuffer + (inputBuffers->singleInputGlobalElts * nIdx);
    
    const float* rowGlobal = inputBufs[nIdx]->rowGlobal;
    const float* rowSpatial = inputBufs[nIdx]->rowSpatial;
    copy(rowGlobal,rowGlobal+numGlobalFeatures,rowGlobalInput);
    SymmetryHelpers::copyInputsWithSymmetry(rowSpatial, rowSpatialInput, 1, nnYLen, nnXLen, numSpatialFeatures, computeHandle->inputsUseNHWC, inputBufs[nIdx]->symmetry);
    
    /// swa_model_bin_inputs as 1 × 361 × 22 3-dimensional array of floats
    int numInputChannels = computeHandle->context->loadedModel->modelDesc.numInputChannels;
    NSArray *userInputShape = @[@1, @(computeHandle->nnXLen * computeHandle->nnYLen), @(numInputChannels)];
    NSArray *userInputStride = @[@(computeHandle->nnXLen * computeHandle->nnYLen * numInputChannels), @(numInputChannels), @1];
    
    // MLMultiArray might reuse the same mem space, so we don't need deallocator.
    MLMultiArray *binInputs = [[MLMultiArray alloc] initWithDataPointer:(void*)rowSpatialInput
                                                                  shape:userInputShape
                                                               dataType:MLMultiArrayDataTypeFloat
                                                                strides:userInputStride
                                                            deallocator:nil
                                                                  error:&error];
    assert(error == nil);
    
    /// swa_model_global_inputs as 1 by 19 matrix of floats
    // MLMultiArray might reuse the same mem space, so we don't need deallocator.
    NSArray *globalInputShape = @[@1, @(computeHandle->context->loadedModel->modelDesc.numInputGlobalChannels)];
    NSArray *globalInputStride = @[@(computeHandle->context->loadedModel->modelDesc.numInputGlobalChannels), @1];
    MLMultiArray *globalInputs = [[MLMultiArray alloc] initWithDataPointer:(void*)rowGlobalInput
                                                                     shape:globalInputShape
                                                                  dataType:MLMultiArrayDataTypeFloat
                                                                   strides:globalInputStride
                                                               deallocator:nil
                                                                     error:&error];
    assert(error == nil);
    
    [inputs addObject: [[Katagob40Input alloc] initWithSwa_model_bin_inputs:binInputs
                                                    swa_model_global_inputs:globalInputs]];
  }
  
  NSArray *mloutputs = [computeHandle->context->loadedModel->model predictionsFromInputs: [inputs copy]
                                                                                 options: [[MLPredictionOptions alloc] init]
                                                                                   error: &error];
  assert(error == nil);
  assert([mloutputs count] == batchSize);
  
  for(int row = 0; row < batchSize; row++) {
    NNOutput *output = outputs[row];
    Katagob40Output *mloutput = mloutputs[row];
    
    // Policy
    NSArray* expectedPolicyShape = @[@1, @2, @(inputBuffers->singlePolicyResultElts)];
    assert([mloutput.swa_model_policy_output.shape isEqualToArray: expectedPolicyShape]);
    
    const float* policySrcBuf = (float*)mloutput.swa_model_policy_output.dataPointer;
    float* policyProbs = output->policyProbs;

    //These are not actually correct, the client does the postprocessing to turn them into
    //policy probabilities and white game outcome probabilities
    //Also we don't fill in the nnHash here either
    SymmetryHelpers::copyOutputsWithSymmetry(policySrcBuf, policyProbs, 1, nnYLen, nnXLen, inputBufs[row]->symmetry);
    policyProbs[inputBuffers->singlePolicyResultElts - 1] = policySrcBuf[inputBuffers->singlePolicyResultElts - 1];
    
    // Value
    int numValueChannels = computeHandle->context->loadedModel->modelDesc.numValueChannels;
    assert(numValueChannels == 3);
    NSArray* expectedValueShape = @[@1, @(numValueChannels)];
    assert([mloutput.swa_model_value_output.shape isEqualToArray: expectedValueShape]);
    
    output->whiteWinProb = [mloutput.swa_model_value_output[row * numValueChannels] floatValue];
    output->whiteLossProb = [mloutput.swa_model_value_output[row * numValueChannels + 1] floatValue];
    output->whiteNoResultProb = [mloutput.swa_model_value_output[row * numValueChannels + 2] floatValue];
    
    // Ownership
    NSArray* expectedOwnershipShape = @[@1, @(nnXLen), @(nnYLen)];
    assert([mloutput.swa_model_ownership_output.shape isEqualToArray: expectedOwnershipShape]);
    
    //As above, these are NOT actually from white's perspective, but rather the player to move.
    //As usual the client does the postprocessing.
    if(output->whiteOwnerMap != NULL) {
      const float* ownershipSrcBuf = (float*)mloutput.swa_model_ownership_output.dataPointer;
      assert(computeHandle->context->loadedModel->modelDesc.numOwnershipChannels == 1);
      SymmetryHelpers::copyOutputsWithSymmetry(ownershipSrcBuf, output->whiteOwnerMap, 1, nnYLen, nnXLen, inputBufs[row]->symmetry);
    }
    
    // ScoreValue
    if(version >= 9) {
      int numScoreValueChannels = computeHandle->context->loadedModel->modelDesc.numScoreValueChannels;
      assert(numScoreValueChannels == 6);
      output->whiteScoreMean = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels] floatValue];
      output->whiteScoreMeanSq = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+1] floatValue];
      output->whiteLead = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+2] floatValue];
      output->varTimeLeft = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+3] floatValue];
      output->shorttermWinlossError = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+4] floatValue];
      output->shorttermScoreError = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+5] floatValue];
    }
    else if(version >= 8) {
      int numScoreValueChannels = computeHandle->context->loadedModel->modelDesc.numScoreValueChannels;
      assert(numScoreValueChannels == 6);
      output->whiteScoreMean = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels] floatValue];
      output->whiteScoreMeanSq = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+1] floatValue];
      output->whiteLead = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+2] floatValue];
      output->varTimeLeft = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+3] floatValue];
      output->shorttermWinlossError = 0;
      output->shorttermScoreError = 0;
    }
    else if(version >= 4) {
      int numScoreValueChannels = computeHandle->context->loadedModel->modelDesc.numScoreValueChannels;
      assert(numScoreValueChannels == 6);
      output->whiteScoreMean = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels] floatValue];
      output->whiteScoreMeanSq = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+1] floatValue];
      output->whiteLead = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels+2] floatValue];
      output->varTimeLeft = 0;
      output->shorttermWinlossError = 0;
      output->shorttermScoreError = 0;
    }
    else if(version >= 3) {
      int numScoreValueChannels = computeHandle->context->loadedModel->modelDesc.numScoreValueChannels;
      assert(numScoreValueChannels == 6);
      output->whiteScoreMean = [mloutput.swa_model_miscvalues_output[row * numScoreValueChannels] floatValue];
      //Version 3 neural nets don't have any second moment output, implicitly already folding it in, so we just use the mean squared
      output->whiteScoreMeanSq = output->whiteScoreMean * output->whiteScoreMean;
      output->whiteLead = output->whiteScoreMean;
      output->varTimeLeft = 0;
      output->shorttermWinlossError = 0;
      output->shorttermScoreError = 0;
    }
    else {
      ASSERT_UNREACHABLE;
    }
  }
}


bool NeuralNet::testEvaluateConv(const ConvLayerDesc* desc,
                                 int batchSize,
                                 int nnXLen,
                                 int nnYLen,
                                 bool useFP16,
                                 bool useNHWC,
                                 const vector<float>& inputBuffer,
                                 vector<float>& outputBuffer
                                 ) {
  (void)desc;
  (void)batchSize;
  (void)nnXLen;
  (void)nnYLen;
  (void)useFP16;
  (void)useNHWC;
  (void)inputBuffer;
  (void)outputBuffer;
  return false;
}

//Mask should be in 'NHW' format (no "C" channel).
bool NeuralNet::testEvaluateBatchNorm(const BatchNormLayerDesc* desc,
                                      int batchSize,
                                      int nnXLen,
                                      int nnYLen,
                                      bool useFP16,
                                      bool useNHWC,
                                      const vector<float>& inputBuffer,
                                      const vector<float>& maskBuffer,
                                      vector<float>& outputBuffer
                                      ){
  (void)desc;
  (void)batchSize;
  (void)nnXLen;
  (void)nnYLen;
  (void)useFP16;
  (void)useNHWC;
  (void)inputBuffer;
  (void)maskBuffer;
  (void)outputBuffer;
  
  return false;
}


bool NeuralNet::testEvaluateResidualBlock(const ResidualBlockDesc* desc,
                                          int batchSize,
                                          int nnXLen,
                                          int nnYLen,
                                          bool useFP16,
                                          bool useNHWC,
                                          const vector<float>& inputBuffer,
                                          const vector<float>& maskBuffer,
                                          vector<float>& outputBuffer
                                          ){
  (void)desc;
  (void)batchSize;
  (void)nnXLen;
  (void)nnYLen;
  (void)useFP16;
  (void)useNHWC;
  (void)inputBuffer;
  (void)maskBuffer;
  (void)outputBuffer;
  
  return false;
}


bool NeuralNet::testEvaluateGlobalPoolingResidualBlock(const GlobalPoolingResidualBlockDesc* desc,
                                                       int batchSize,
                                                       int nnXLen,
                                                       int nnYLen,
                                                       bool useFP16,
                                                       bool useNHWC,
                                                       const vector<float>& inputBuffer,
                                                       const vector<float>& maskBuffer,
                                                       vector<float>& outputBuffer
                                                       ){
  (void)desc;
  (void)batchSize;
  (void)nnXLen;
  (void)nnYLen;
  (void)useFP16;
  (void)useNHWC;
  (void)inputBuffer;
  (void)maskBuffer;
  (void)outputBuffer;
  
  return false;
}

#endif
