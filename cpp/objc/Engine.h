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

- (id) init: (NSString *)modelFile;

- (NSArray*) getColors;
- (bool) set_position:(NSArray*) pairs;
- (int) genmove: (Player) pla;
- (bool) play: (Loc) loc :(Player) pla;
- (bool) undo;


@end

NS_ASSUME_NONNULL_END
