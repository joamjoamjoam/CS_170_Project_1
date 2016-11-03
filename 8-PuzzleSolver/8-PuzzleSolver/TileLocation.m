//
//  tileLocation.m
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/29/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "TileLocation.h"

@implementation TileLocation

@synthesize row;
@synthesize collumn;


- (id) initWithRow: (int) passedRow andCollumn: (int) passedCollumn{
    self = [super init];
    
    if (self){
        self.row = passedRow;
        self.collumn = passedCollumn;
    }
    

    
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"(%d,%d)",row,collumn];
}

- (id)copyWithZone:(NSZone *)zone{
    TileLocation* copy = [[[self class] allocWithZone:zone] init];
    
    if(copy){
        [copy setRow:self.row];
        [copy setCollumn:self.collumn];
    }
    return copy;
}
@end
