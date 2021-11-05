//
//  Game.m
//  katago
//
//  Created by 黄轶明 on 2021/11/4.
//

#import "Game.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <board.h>
#import <boardhistory.h>
#pragma clang diagnostic pop

using namespace std;


@interface Game ()

@property Board board;
@property vector<Move> initialStones;
@property vector<Move> moveHistory;
@property Player perspective;
@property NSString *rules;
@property int xSize;
@property int ySize;

@end

@implementation Game

- (id) init: (NSString*) rules {
  self = [super init];
  _rules = rules;
  _xSize = 19;
  _ySize = 19;
  return self;
}

// MARK: - Game
- (bool) makeMove:(Loc)loc :(Player)movePla {
  bool suc = _board.playMove(loc, movePla, false);
  if (suc) {
    Move m = Move(loc, movePla);
    _moveHistory.push_back(m);
  }
  return suc;
}

- (NSArray*) getColors {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  for (int i=0; i < _board.MAX_ARR_SIZE; i++) {
    [array addObject: [NSNumber numberWithInt: _board.colors[i]]];
  }
  return [array copy];
}

// MARK: - Request Json
/// example: [["W","P5"],["B","P6"]]
- (NSString*) toMovesJson {
  NSMutableArray *moves = [[NSMutableArray alloc] init];
  for (vector<Move>::iterator it = _moveHistory.begin();
       it != _moveHistory.end(); ++it) {
    NSString *player = [[NSString alloc] initWithCString: PlayerIO::playerToStringShort(it->pla).c_str() encoding:NSUTF8StringEncoding];
    NSString *cord = [[NSString alloc] initWithCString: Location::toString(it->loc, _xSize, _ySize).c_str() encoding:NSUTF8StringEncoding];
    NSArray *move = [[NSArray alloc] initWithObjects: player, cord, nil];
    [moves addObject:move];
  }
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:moves options:kNilOptions error:&error];
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString*) toRequestJson {
  NSString* requestId = [[[NSUUID alloc] init] UUIDString];
  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        requestId, @"id",
                        [self toMovesJson], @"moves",
                        nil];
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
