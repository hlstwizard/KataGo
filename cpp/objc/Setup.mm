//
//  Setup.m
//  KatagoObjC
//
//  Created by 黄轶明 on 2021/10/22.
//

#import "Setup.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <board.h>
#import <nninputs.h>
#pragma clang diagnostic pop


@implementation Setup

+ (void) setup {
    Board::initHash();
    ScoreValue::initTables();
}

@end
