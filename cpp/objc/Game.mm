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
@property /*(unsafe_unretained,assign,atomic)*/ vector<Board::MoveRecord> *moveHistory;
@property vector<Board::MoveRecord>::size_type indexInMoveHistory;
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
  _moveHistory = new vector<Board::MoveRecord>();
  _rules = rules;
  _indexInMoveHistory = _moveHistory->size();
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
- (void) makeMove:(Loc)loc :(Player)movePla {
  Board::MoveRecord record = _board->playMoveRecorded(loc, movePla);
  _moveHistory->push_back(record);
  // TODO:  Trial Move, we probably need another vector to store trial moves
  _indexInMoveHistory = _moveHistory->size() - 1;
}

- (void) undo {
  if (_moveHistory != nil) {
    // This is already the beginning.
    if (_indexInMoveHistory == -1) {
      return;
    }
    auto iter = _moveHistory->begin() + _indexInMoveHistory;
    auto record = *iter;
    _board->undo(record);
    _indexInMoveHistory--;
  }
}

- (void) replay {
  if (_moveHistory != nil) {
    // This is already the end.
    if (_indexInMoveHistory == _moveHistory->size() - 1) {
      return;
    }
    auto iter = _moveHistory->begin() + _indexInMoveHistory + 1;
    auto record = *iter;
    _board->playMoveRecorded(record.loc, record.pla);
    _indexInMoveHistory++;
  }
}

- (void) reset {
  _initialStones->clear();
  _moveHistory->clear();
  if (_board) {
    delete _board;
  }
  _board = new Board();
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
  for (vector<Board::MoveRecord>::iterator it = _moveHistory->begin();
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
