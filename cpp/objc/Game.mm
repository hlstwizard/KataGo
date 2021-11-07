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

@property /*(unsafe_unretained,assign,atomic)*/ Board *board;
@property /*(unsafe_unretained,assign,atomic)*/ vector<Move> *initialStones;
@property /*(unsafe_unretained,assign,atomic)*/ vector<Move> *moveHistory;
@property Player perspective;
@property NSString *rules;
@property int xSize;
@property int ySize;

@end

@implementation Game

- (id) init: (NSString*) rules {
  self = [super init];
  _board = new Board();
  _initialStones = new vector<Move>();
  _moveHistory = new vector<Move>();
  _rules = rules;
  _xSize = 19;
  _ySize = 19;
  return self;
}

- (void) dealloc {
  delete _board;
  delete _initialStones;
  delete _moveHistory;
}

+ (bool) tryLocOfString: (NSString*) str :(Loc*) loc :(NSNumber*) xSize :(NSNumber*) ySize {
  bool suc = Location::tryOfString(string([str cStringUsingEncoding:NSUTF8StringEncoding]), xSize.intValue, ySize.intValue, *loc);
  return suc;
}

// MARK: - Game
- (bool) makeMove:(Loc)loc :(Player)movePla {
  bool suc = _board->playMove(loc, movePla, false);
  if (suc) {
    Move m = Move(loc, movePla);
    _moveHistory->push_back(m);
  }
  return suc;
}

- (bool) makeMoveWithCoord: (NSString*) coord :(Player) movePla {
  Loc loc;
  Location::tryOfString(string([coord cStringUsingEncoding:NSUTF8StringEncoding]), _xSize, _ySize, loc);
  return [self makeMove:loc :movePla];
}

- (bool) reset {
  
}

- (NSArray*) getColors {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  for (int i=0; i < _board->MAX_ARR_SIZE; i++) {
    [array addObject: [NSNumber numberWithInt: _board->colors[i]]];
  }
  return [array copy];
}

// MARK: - Request Json
/// example: [["W","P5"],["B","P6"]]
- (NSArray*) getMoves {
  NSMutableArray *moves = [[NSMutableArray alloc] init];
  for (vector<Move>::iterator it = _moveHistory->begin();
       it != _moveHistory->end(); ++it) {
    NSString *player = [[NSString alloc] initWithCString: PlayerIO::playerToStringShort(it->pla).c_str() encoding:NSUTF8StringEncoding];
    NSString *cord = [[NSString alloc] initWithCString: Location::toString(it->loc, _xSize, _ySize).c_str() encoding:NSUTF8StringEncoding];
    NSArray *move = [[NSArray alloc] initWithObjects: player, cord, nil];
    [moves addObject:move];
  }
  
  return [moves copy];
}

- (NSString*) toRequestJson: (NSString*) uuid {
  NSArray* moves = [self getMoves];
  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        uuid, @"id",
                        moves, @"moves",
                        _rules, @"rules",
                        [NSNumber numberWithInt: _xSize], @"boardXSize",
                        [NSNumber numberWithInt: _ySize], @"boardYSize",
                        nil];
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
