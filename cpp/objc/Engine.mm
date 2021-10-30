//
//  Engine.m
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/28.
//

#import "Engine.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <core/global.h>
#import <neuralnet/nninputs.h>
#import <search/searchparams.h>
#import <command/gtp.h>
#import <game/board.h>
#import <program/setup.h>
#pragma clang diagnostic pop

struct GTPEngine;

@interface Engine ()

@property (readonly) GTPEngine *engine;

@end

@implementation Engine

- (id) init:(NSString *)modelFile {
  self = [super init];
  
  ConfigParser cfg;
  Logger logger;
  Rand seedRand;
  
  NSLog(@"Start Engine...");
  
  //Defaults to 7.5 komi, gtp will generally override this
  const bool loadKomiFromCfg = false;
  Rules initialRules;
  
  NSLog(@"Using default initialRules, %s", initialRules.toStringNoKomiMaybeNice().c_str());
  
  bool isForcingKomi = false;
  float forcedKomi = 0;
  
  SearchParams initialParams;
  initialParams.conservativePass = true;
  initialParams.fillDameBeforePass = true;
  
  // Disable pondering for now.
  const bool ponderingEnabled = false;
  const enabled_t cleanupBeforePass = enabled_t::Auto;
  const enabled_t friendlyPass = enabled_t::Auto;
  initialParams.numThreads = 4;
  NSLog(@"Using default SearchParams, %d threads.", initialParams.numThreads);
  
  const bool allowResignation = false;
  const double resignThreshold = -1.0;
  
  const int resignConsecTurns = 3;
  const double resignMinScoreDifference = -1e10;
  
  const double searchFactorWhenWinning = 1.0;
  const double searchFactorWhenWinningThreshold = 1.0;
  const bool ogsChatToStderr = false;
  const int analysisPVLen = 13;
  const bool assumeMultipleStartingBlackMovesAreHandicap = true;
  const bool preventEncore = true;
  const double dynamicPlayoutDoublingAdvantageCapPerOppLead = 0.045;
  
  double staticPlayoutDoublingAdvantage = initialParams.playoutDoublingAdvantage;
  const bool staticPDATakesPrecedence = false;
  const bool avoidMYTDaggerHack = false;
  
  const double normalAvoidRepeatedPatternUtility = initialParams.avoidRepeatedPatternUtility;
  const double handicapAvoidRepeatedPatternUtility = 0.005;
  
  int defaultBoardXSize = 19;
  int defaultBoardYSize = 19;
  
  // TODO: - Easy to debug
#ifdef DEBUG
  const bool forDeterministicTesting = true;
#else
  const bool forDeterministicTesting = false;
#endif
  
  if(forDeterministicTesting)
    seedRand.init("forDeterministicTesting");
  
  const double genmoveWideRootNoise = initialParams.wideRootNoise;
  const double analysisWideRootNoise = Setup::DEFAULT_ANALYSIS_WIDE_ROOT_NOISE;
  const bool analysisAntiMirror = initialParams.antiMirror;
  const bool genmoveAntiMirror = true;
  
  std::unique_ptr<PatternBonusTable> patternBonusTable = nullptr;
  {
    std::vector<std::unique_ptr<PatternBonusTable>> tables = Setup::loadAvoidSgfPatternBonusTables(cfg,logger);
    assert(tables.size() == 1);
    patternBonusTable = std::move(tables[0]);
  }
  Player perspective = P_BLACK;
  const std::string nnModelFile = std::string([modelFile UTF8String]);
  _engine = new GTPEngine(nnModelFile,initialParams,initialRules,
                          assumeMultipleStartingBlackMovesAreHandicap,preventEncore,
                          dynamicPlayoutDoublingAdvantageCapPerOppLead,
                          staticPlayoutDoublingAdvantage,staticPDATakesPrecedence,
                          normalAvoidRepeatedPatternUtility, handicapAvoidRepeatedPatternUtility,
                          avoidMYTDaggerHack,
                          genmoveWideRootNoise,analysisWideRootNoise,
                          genmoveAntiMirror,analysisAntiMirror,
                          perspective,analysisPVLen,
                          std::move(patternBonusTable));
  
  _engine->setOrResetBoardSize(cfg,logger,seedRand,defaultBoardXSize,defaultBoardYSize,false);
  
  double mainTime = 1.0;
  double byoYomiTime = 5.0;
  int byoYomiPeriods = 5;
  TimeControls tc = TimeControls::canadianOrByoYomiTime(mainTime,byoYomiTime,byoYomiPeriods,1);
  _engine->bTimeControls = tc;
  _engine->wTimeControls = tc;
  
  NSLog(@"Loaded modelfile : %@", modelFile);
  NSLog(@"Model name: %s", (_engine->nnEval == NULL ? std::string().c_str() : _engine->nnEval->getInternalModelName().c_str()));
  NSLog(@"GTP ready, beginning main protocol loop");
  
  return self;
}

- (NSArray*) getColors {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  
  for (int i=0; i<Board::MAX_ARR_SIZE; i++) {
    [array addObject: @(_engine->bot->getRootBoard().colors[i])];
  }
  return [array copy];
}


- (int)genmove:(Player) pla {
  Logger logger;
  std::string response;
  bool responseIsError = false;
  bool maybeStartPondering = false;
  
  int result = -99;
  
  _engine->genMove(
                   pla,
                   logger,1.0,1.0, enabled_t::Auto,enabled_t::Auto, false, false,-1.0,3, -1e10,
                   true,true,false,
                   response,responseIsError,maybeStartPondering,
                   GTPEngine::AnalyzeArgs()
                   );
  
  if(responseIsError)
    return result;
  else if (response == "resign")
    return -1;
  else
    return Location::ofString(response, _engine->initialBoard.x_size, _engine->initialBoard.y_size);
}

- (bool) play:(Loc)loc :(Player)pla {
  return _engine->play(loc, pla);
}

- (bool) set_position:(NSArray*) pairs {
  std::vector<Move> initialStones;
  for (id pair in pairs) {
    NSArray* _pair = pair;
    NSNumber* loc = _pair[0];
    NSNumber* pla = _pair[1];
    
    initialStones.push_back(Move([loc intValue], [pla intValue]));
  }
  
  return _engine->setPosition(initialStones);
}

- (bool) undo {
  return _engine->undo();
}

- (void)dealloc {
  if (_engine) {
    delete _engine;
  }
  _engine = nil;
}

@end
