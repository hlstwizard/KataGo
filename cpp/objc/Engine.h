//
//  Engine.h
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/28.
//

#pragma once

#import <Foundation/Foundation.h>
#import "types.h"

NS_ASSUME_NONNULL_BEGIN

@interface Engine : NSObject

- (id) init:(NSString *)modelFile
           :(NSString *)configFile;

- (void) runLoop;
- (void) addInputRequest: (NSString *)requestBlob;
- (NSString*) fetchResult;

@end

NS_ASSUME_NONNULL_END
