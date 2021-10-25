//
// Katagob40.m
//
// This file was automatically generated and should not be edited.
//

#import "Katagob40.h"

@implementation Katagob40Input

- (instancetype)initWithSwa_model_bin_inputs:(MLMultiArray *)swa_model_bin_inputs swa_model_global_inputs:(MLMultiArray *)swa_model_global_inputs {
    self = [super init];
    if (self) {
        _swa_model_bin_inputs = swa_model_bin_inputs;
        _swa_model_global_inputs = swa_model_global_inputs;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"swa_model_bin_inputs", @"swa_model_global_inputs"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"swa_model_bin_inputs"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_bin_inputs];
    }
    if ([featureName isEqualToString:@"swa_model_global_inputs"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_global_inputs];
    }
    return nil;
}

@end

@implementation Katagob40Output

- (instancetype)initWithSwa_model_miscvalues_output:(MLMultiArray *)swa_model_miscvalues_output swa_model_ownership_output:(MLMultiArray *)swa_model_ownership_output swa_model_policy_output:(MLMultiArray *)swa_model_policy_output swa_model_value_output:(MLMultiArray *)swa_model_value_output {
    self = [super init];
    if (self) {
        _swa_model_miscvalues_output = swa_model_miscvalues_output;
        _swa_model_ownership_output = swa_model_ownership_output;
        _swa_model_policy_output = swa_model_policy_output;
        _swa_model_value_output = swa_model_value_output;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"swa_model_miscvalues_output", @"swa_model_ownership_output", @"swa_model_policy_output", @"swa_model_value_output"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"swa_model_miscvalues_output"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_miscvalues_output];
    }
    if ([featureName isEqualToString:@"swa_model_ownership_output"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_ownership_output];
    }
    if ([featureName isEqualToString:@"swa_model_policy_output"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_policy_output];
    }
    if ([featureName isEqualToString:@"swa_model_value_output"]) {
        return [MLFeatureValue featureValueWithMultiArray:_swa_model_value_output];
    }
    return nil;
}

@end

@implementation Katagob40


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Katagob40" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load Katagob40.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize Katagob40 instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of Katagob40.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model {
    self = [super init];
    if (!self) { return nil; }
    _model = model;
    if (_model == nil) { return nil; }
    return self;
}


/**
    Initialize Katagob40 instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize Katagob40 instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize Katagob40 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for Katagob40.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize Katagob40 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for Katagob40.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct Katagob40 instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid Katagob40 instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(Katagob40 * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct Katagob40 instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid Katagob40 instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(Katagob40 * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            Katagob40 *typedModel = [[Katagob40 alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable Katagob40Output *)predictionFromFeatures:(Katagob40Input *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable Katagob40Output *)predictionFromFeatures:(Katagob40Input *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [_model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[Katagob40Output alloc] initWithSwa_model_miscvalues_output:(MLMultiArray *)[outFeatures featureValueForName:@"swa_model_miscvalues_output"].multiArrayValue swa_model_ownership_output:(MLMultiArray *)[outFeatures featureValueForName:@"swa_model_ownership_output"].multiArrayValue swa_model_policy_output:(MLMultiArray *)[outFeatures featureValueForName:@"swa_model_policy_output"].multiArrayValue swa_model_value_output:(MLMultiArray *)[outFeatures featureValueForName:@"swa_model_value_output"].multiArrayValue];
}

- (nullable Katagob40Output *)predictionFromSwa_model_bin_inputs:(MLMultiArray *)swa_model_bin_inputs swa_model_global_inputs:(MLMultiArray *)swa_model_global_inputs error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    Katagob40Input *input_ = [[Katagob40Input alloc] initWithSwa_model_bin_inputs:swa_model_bin_inputs swa_model_global_inputs:swa_model_global_inputs];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<Katagob40Output *> *)predictionsFromInputs:(NSArray<Katagob40Input*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [_model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<Katagob40Output*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        Katagob40Output * result = [[Katagob40Output alloc] initWithSwa_model_miscvalues_output:(MLMultiArray *)[resultProvider featureValueForName:@"swa_model_miscvalues_output"].multiArrayValue swa_model_ownership_output:(MLMultiArray *)[resultProvider featureValueForName:@"swa_model_ownership_output"].multiArrayValue swa_model_policy_output:(MLMultiArray *)[resultProvider featureValueForName:@"swa_model_policy_output"].multiArrayValue swa_model_value_output:(MLMultiArray *)[resultProvider featureValueForName:@"swa_model_value_output"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
