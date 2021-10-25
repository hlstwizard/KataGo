//
//  gtp.h
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/29.
//

#ifndef gtp_h
#define gtp_h

#include "../game/board.h"
#include "../game/boardhistory.h"
#include "../game/rules.h"
#include "../search/asyncbot.h"
#include "../core/config_parser.h"


struct GTPEngine {
    struct AnalyzeArgs {
        bool analyzing = false;
        bool lz = false;
        bool kata = false;
        int minMoves = 0;
        int maxMoves = 10000000;
        bool showOwnership = false;
        bool showOwnershipStdev = false;
        bool showPVVisits = false;
        double secondsPerReport = TimeControls::UNLIMITED_TIME_DEFAULT;
        std::vector<int> avoidMoveUntilByLocBlack;
        std::vector<int> avoidMoveUntilByLocWhite;
    };
    
    GTPEngine(const GTPEngine&) = delete;
    GTPEngine& operator=(const GTPEngine&) = delete;
    const std::string nnModelFile;
    const bool assumeMultipleStartingBlackMovesAreHandicap;
    const int analysisPVLen;
    const bool preventEncore;
    
    const double dynamicPlayoutDoublingAdvantageCapPerOppLead;
    double staticPlayoutDoublingAdvantage;
    bool staticPDATakesPrecedence;
    double normalAvoidRepeatedPatternUtility;
    double handicapAvoidRepeatedPatternUtility;
    
    double genmoveWideRootNoise;
    double analysisWideRootNoise;
    bool genmoveAntiMirror;
    bool analysisAntiMirror;
    
    NNEvaluator* nnEval;
    AsyncBot* bot;
    Rules currentRules; //Should always be the same as the rules in bot, if bot is not NULL.
    
    //Stores the params we want to be using during genmoves or analysis
    SearchParams params;
    
    TimeControls bTimeControls;
    TimeControls wTimeControls;
    
    //This move history doesn't get cleared upon consecutive moves by the same side, and is used
    //for undo, whereas the one in search does.
    Board initialBoard;
    Player initialPla;
    std::vector<Move> moveHistory;
    
    std::vector<double> recentWinLossValues;
    double lastSearchFactor;
    double desiredDynamicPDAForWhite;
    bool avoidMYTDaggerHack;
    std::unique_ptr<PatternBonusTable> patternBonusTable;
    
    Player perspective;
    
    double genmoveTimeSum;
    
    GTPEngine(
              const std::string& modelFile, SearchParams initialParams, Rules initialRules,
              bool assumeMultiBlackHandicap, bool prevtEncore,
              double dynamicPDACapPerOppLead, double staticPDA, bool staticPDAPrecedence,
              double normAvoidRepeatedPatternUtility, double hcapAvoidRepeatedPatternUtility,
              bool avoidDagger,
              double genmoveWRN, double analysisWRN,
              bool genmoveAntiMir, bool analysisAntiMir,
              Player persp, int pvLen,
              std::unique_ptr<PatternBonusTable>&& pbTable
              );
    ~GTPEngine();
    void stopAndWait();
    Rules getCurrentRules();
    void clearStatsForNewGame();
    
    void setOrResetBoardSize(ConfigParser& cfg, Logger& logger, Rand& seedRand, int boardXSize, int boardYSize, bool loggingToStderr);
    
    void setPositionAndRules(Player pla, const Board& board, const BoardHistory& h, const Board& newInitialBoard, Player newInitialPla, const std::vector<Move> newMoveHistory);
    
    void clearBoard();
    
    bool setPosition(const std::vector<Move>& initialStones);
    
    void updateKomiIfNew(float newKomi);
    
    void setStaticPlayoutDoublingAdvantage(double d);
    void setAnalysisWideRootNoise(double x);
    void setRootPolicyTemperature(double x);
    void setNumSearchThreads(int numThreads);
    void updateDynamicPDA();
    
    bool play(Loc loc, Player pla);
    bool undo();
    bool setRulesNotIncludingKomi(Rules newRules, std::string& error);
    void ponder();
    void filterZeroVisitMoves(const AnalyzeArgs& args, std::vector<AnalysisData> buf);
    std::function<void(const Search* search)> getAnalyzeCallback(Player pla, AnalyzeArgs args);
    void genMove(
      Player pla,
      Logger& logger, double searchFactorWhenWinningThreshold, double searchFactorWhenWinning,
      enabled_t cleanupBeforePass, enabled_t friendlyPass, bool ogsChatToStderr,
      bool allowResignation, double resignThreshold, int resignConsecTurns, double resignMinScoreDifference,
      bool logSearchInfo, bool debug, bool playChosenMove,
      std::string& response, bool& responseIsError, bool& maybeStartPondering,
      AnalyzeArgs args);
    void clearCache();
    void placeFixedHandicap(int n, std::string& response, bool& responseIsError);
    void placeFreeHandicap(int n, std::string& response, bool& responseIsError, Rand& rand);
    void analyze(Player pla, AnalyzeArgs args);
    void computeAnticipatedWinnerAndScore(Player& winner, double& finalWhiteMinusBlackScore);
    std::vector<bool> computeAnticipatedStatuses();
    std::string rawNN(int whichSymmetry);
    SearchParams getParams();
    void setParams(SearchParams p);
    
    static AnalyzeArgs parseAnalyzeCommand(
                                           const std::string& command,
                                           const std::vector<std::string>& pieces,
                                           Player& pla,
                                           bool& parseFailed,
                                           GTPEngine* engine);
};

#endif /* gtp_h */
