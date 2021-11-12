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

+ (bool) tryLocOfString: (NSString*) str :(Loc*) loc :(NSNumber*) xSize :(NSNumber*) ySize;

- (id) init: (NSString*) rules;

- (void) makeMove: (Loc) loc :(Player) movePla;
- (void) undo;
- (void) replay;
- (void) reset;
- (void) newGame: (UInt8) handicap;

- (NSArray*) getColors;
- (NSNumber*) getLastMove;
- (NSString*) toRequestJson: (NSString*) uuid;

@end

NS_ASSUME_NONNULL_END
