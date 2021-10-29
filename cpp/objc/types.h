//
//  types.h
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/20.
//

#ifndef types_h
#define types_h

typedef short Loc;
typedef int8_t Player;
typedef int8_t Color;

typedef struct {
    Player owner;        //Owner of chain
    short num_locs;      //Number of stones in chain
    short num_liberties; //Number of liberties in chain
} ChainData;

typedef struct {
    Player pla;
    Loc loc;
    Loc ko_loc;
    uint8_t capDirs; //First 4 bits indicate directions of capture, fifth bit indicates suicide
} MoveRecord;

typedef struct {
    uint64_t hash0;
    uint64_t hash1;
} KHash128; // as Hash128 is in the global namespace


#endif /* types_h */
