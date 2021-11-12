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
@property /*(unsafe_unretained,assign,atomic)*/ vector<Board::MoveRecord> *trialMoves;
@property int indexInMoveHistory;
@property int indexInTrialMoves;
@property Player perspective;
@property NSString *rules;
@property bool inTrial; // 试下
@property int xSize;
@property int ySize;

@end

@implementation Game

- (id) init: (NSString*) rules {
  self = [super init];
  _board = new Board();
  _initialStones = new vector<Move>();
  _moveHistory = new vector<Board::MoveRecord>();
  _trialMoves = new vector<Board::MoveRecord>();
  _indexInMoveHistory = int(_moveHistory->size() - 1);
  _indexInTrialMoves = int(_trialMoves->size() - 1);
  _inTrial = false;
  _rules = rules;
  _xSize = 19;
  _ySize = 19;
  return self;
}

- (void) dealloc {
  delete _board;
  delete _initialStones;
  delete _moveHistory;
  delete _trialMoves;
}

+ (bool) tryLocOfString: (NSString*) str :(Loc*) loc :(NSNumber*) xSize :(NSNumber*) ySize {
  bool suc = Location::tryOfString(string([str cStringUsingEncoding:NSUTF8StringEncoding]), xSize.intValue, ySize.intValue, *loc);
  return suc;
}

// MARK: - Game
- (void) makeMove:(Loc)loc :(Player)movePla {
  Board::MoveRecord record = _board->playMoveRecorded(loc, movePla);
  
  if (_inTrial) {
    if (_indexInTrialMoves < _trialMoves->size() - 1) {
      // in undo, remove the rest first
      _trialMoves->erase(_trialMoves->begin() + _indexInTrialMoves + 1, _trialMoves->end());
    }
    
    _trialMoves->push_back(record);
    _indexInTrialMoves = int(_trialMoves->size() - 1);
  } else {
    if (_indexInMoveHistory < _moveHistory->size() - 1) {
      // in undo and not in trial
      // TODO: If it's a loaded sgf, we shouldn't remove the rest, they should be locked.
      _moveHistory->erase(_moveHistory->begin() + _indexInMoveHistory + 1, _moveHistory->end());
    }
    _moveHistory->push_back(record);
    _indexInMoveHistory = int(_moveHistory->size() - 1);
  }
}

- (void) enterTrial {
  _inTrial = true;
}

- (void) exitTrial {
  _inTrial = false;
  
  for(auto it = _trialMoves->begin(); it != _trialMoves->end(); it++) {
    _board->undo(*it);
  }
  _trialMoves->clear();
  _indexInTrialMoves = int(_trialMoves->size() - 1);
}

/// return a bool indicate if can do more undo.
- (bool) undo {
  if (_inTrial) {
    auto iter = _trialMoves->begin() + _indexInTrialMoves;
    Board::MoveRecord record = *iter;
    _board->undo(record);
    
    _indexInTrialMoves--;
    if (_indexInTrialMoves == -1) {
      return false;
    }
    return true;
  } else {
    auto iter = _moveHistory->begin() + _indexInMoveHistory;
    auto record = *iter;
    _board->undo(record);
    
    _indexInMoveHistory--;
    
    if (_indexInMoveHistory == -1) {
      return false;
    }
    return true;
  }
}

- (bool) replay {
  if (_inTrial) {
    auto iter = _trialMoves->begin() + _indexInTrialMoves;
    Board::MoveRecord record = *iter;
    _board->playMoveRecorded(record.loc, record.pla);
    
    _indexInTrialMoves++;
    if (_indexInTrialMoves == _trialMoves->size() - 1) {
      return false;
    }
    return true;
    
  } else {
    auto iter = _moveHistory->begin() + _indexInMoveHistory + 1;
    Board::MoveRecord record = *iter;
    _board->playMoveRecorded(record.loc, record.pla);
    
    _indexInMoveHistory++;
    if (_indexInMoveHistory == _moveHistory->size() - 1) {
      return false;
    }
    return true;
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

- (void) newGame:(UInt8)handicap {
  // Cleanup
  [self reset];
  
  NSArray *initStones = [[NSArray alloc] initWithObjects: @(Location::getLoc(3, 3, _xSize)),
                         @(Location::getLoc(3, 15, _xSize)), @(Location::getLoc(15, 3, _xSize)),
                         @(Location::getLoc(15, 15, _xSize)), @(Location::getLoc(3, 9, _xSize)),
                         @(Location::getLoc(9, 15, _xSize)), @(Location::getLoc(15, 9, _xSize)),
                         @(Location::getLoc(9, 3, _xSize)), @(Location::getLoc(9, 9, _xSize)),
                         nil];
  
  for (int i=0; i < handicap; i++) {
    Loc loc = [initStones[i] shortValue];
    Move move = Move(loc, P_BLACK);
    _initialStones->push_back(move);
    _board->setStone(loc, P_BLACK);
  }
}

- (NSArray*) getColors {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  for (int i=0; i < _board->MAX_ARR_SIZE; i++) {
    [array addObject: [NSNumber numberWithInt: _board->colors[i]]];
  }
  return [array copy];
}

- (NSNumber*) getLastMove {
  if (_moveHistory->empty() && _trialMoves->empty()) {
    return [[NSNumber alloc] initWithShort: -1];
  } else {
    vector<Board::MoveRecord>::iterator end;
    
    if (_inTrial) {
      end = _trialMoves->begin() + _indexInTrialMoves;
    } else {
      end = _moveHistory->begin() + _indexInMoveHistory;
    }
    auto record = *end;
    return [[NSNumber alloc] initWithShort: record.loc];
  }
}

// MARK: - Request Json
/// example: [["W","P5"],["B","P6"]]
- (NSArray*) getMoves {
  NSMutableArray *moves = [[NSMutableArray alloc] init];
  if (_indexInMoveHistory == -1) {
    // undo to the very beginning
    return [moves copy];
  }
  auto end = _moveHistory->begin() + _indexInMoveHistory;
  for (auto it = _moveHistory->begin(); it <= end; ++it) {
    NSString *player = [[NSString alloc] initWithCString: PlayerIO::playerToStringShort(it->pla).c_str() encoding:NSUTF8StringEncoding];
    NSString *cord = [[NSString alloc] initWithCString: Location::toString(it->loc, _xSize, _ySize).c_str() encoding:NSUTF8StringEncoding];
    NSArray *move = [[NSArray alloc] initWithObjects: player, cord, nil];
    [moves addObject:move];
  }
  
  if (_indexInTrialMoves == -1) {
    return [moves copy];
  }
  
  // add the trial moves
  end = _trialMoves->begin() + _indexInTrialMoves;
  for (auto it = _trialMoves->begin(); it <= end; ++it) {
    NSString *player = [[NSString alloc] initWithCString: PlayerIO::playerToStringShort(it->pla).c_str() encoding:NSUTF8StringEncoding];
    NSString *cord = [[NSString alloc] initWithCString: Location::toString(it->loc, _xSize, _ySize).c_str() encoding:NSUTF8StringEncoding];
    NSArray *move = [[NSArray alloc] initWithObjects: player, cord, nil];
    [moves addObject:move];
  }
  
  return [moves copy];
}

- (NSArray*) getInitStones {
  NSMutableArray *stones = [[NSMutableArray alloc] init];
  for (vector<Move>::iterator it = _initialStones->begin();
       it != _initialStones->end(); ++it) {
    NSString *player = [[NSString alloc] initWithCString: PlayerIO::playerToStringShort(it->pla).c_str() encoding:NSUTF8StringEncoding];
    NSString *cord = [[NSString alloc] initWithCString: Location::toString(it->loc, _xSize, _ySize).c_str() encoding:NSUTF8StringEncoding];
    NSArray *stone = [[NSArray alloc] initWithObjects: player, cord, nil];
    [stones addObject:stone];
  }
  
  return [stones copy];
}

- (NSString*) toRequestJson: (NSString*) uuid {
  NSArray* moves = [self getMoves];
  NSArray* initStones = [self getInitStones];
  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        uuid, @"id",
                        moves, @"moves",
                        initStones, @"initialStones",
                        _rules, @"rules",
                        [NSNumber numberWithInt: _xSize], @"boardXSize",
                        [NSNumber numberWithInt: _ySize], @"boardYSize",
                        nil];
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
