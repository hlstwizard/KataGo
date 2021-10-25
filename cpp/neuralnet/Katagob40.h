//
// Katagob40.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>
#include <os/log.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")))
@interface Katagob40Input : NSObject<MLFeatureProvider>

/// swa_model_bin_inputs as 1 × 361 × 22 3-dimensional array of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_bin_inputs;

/// swa_model_global_inputs as 1 by 19 matrix of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_global_inputs;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSwa_model_bin_inputs:(MLMultiArray *)swa_model_bin_inputs swa_model_global_inputs:(MLMultiArray *)swa_model_global_inputs NS_DESIGNATED_INITIALIZER;

@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")))
@interface Katagob40Output : NSObject<MLFeatureProvider>

/// swa_model_miscvalues_output as multidimensional array of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_miscvalues_output;

/// swa_model_ownership_output as multidimensional array of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_ownership_output;

/// swa_model_policy_output as multidimensional array of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_policy_output;

/// swa_model_value_output as multidimensional array of floats
@property (readwrite, nonatomic, strong) MLMultiArray * swa_model_value_output;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSwa_model_miscvalues_output:(MLMultiArray *)swa_model_miscvalues_output swa_model_ownership_output:(MLMultiArray *)swa_model_ownership_output swa_model_policy_output:(MLMultiArray *)swa_model_policy_output swa_model_value_output:(MLMultiArray *)swa_model_value_output NS_DESIGNATED_INITIALIZER;

@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")))
@interface Katagob40 : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;

/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle;

/**
    Initialize Katagob40 instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of Katagob40.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model NS_DESIGNATED_INITIALIZER;

/**
    Initialize Katagob40 instance with the model in this bundle.
*/
- (nullable instancetype)init;

/**
    Initialize Katagob40 instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize Katagob40 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for Katagob40.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize Katagob40 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for Katagob40.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Construct Katagob40 instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid Katagob40 instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(Katagob40 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Construct Katagob40 instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid Katagob40 instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(Katagob40 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the standard interface
    @param input an instance of Katagob40Input to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as Katagob40Output
*/
- (nullable Katagob40Output *)predictionFromFeatures:(Katagob40Input *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of Katagob40Input to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as Katagob40Output
*/
- (nullable Katagob40Output *)predictionFromFeatures:(Katagob40Input *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the convenience interface
    @param swa_model_bin_inputs as 1 × 361 × 22 3-dimensional array of floats:
    @param swa_model_global_inputs as 1 by 19 matrix of floats:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as Katagob40Output
*/
- (nullable Katagob40Output *)predictionFromSwa_model_bin_inputs:(MLMultiArray *)swa_model_bin_inputs swa_model_global_inputs:(MLMultiArray *)swa_model_global_inputs error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of Katagob40Input instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<Katagob40Output *>
*/
- (nullable NSArray<Katagob40Output *> *)predictionsFromInputs:(NSArray<Katagob40Input*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
