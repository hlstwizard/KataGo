//
//  Game.h
//  libkatago
//
//  Created by 黄轶明 on 2021/11/4.
//

#pragma once

#import <Foundation/Foundation.h>
#import "types.h"

NS_ASSUME_NONNULL_BEGIN

@interface Game : NSObject

- (id) init: (NSString*) rules;

- (bool) makeMove: (Loc) loc :(Player) movePla;

- (NSArray*) getColors;
- (NSString*) toRequestJson: (NSString*) uuid;

@end

NS_ASSUME_NONNULL_END
