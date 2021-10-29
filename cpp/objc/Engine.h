//
//  Engine.h
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/28.
//

#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Engine : NSObject

- (id) init: (NSString *)modelFile;

- (NSArray*) getColors;
- (int) genmove: (int8_t) pla;

@end

NS_ASSUME_NONNULL_END
