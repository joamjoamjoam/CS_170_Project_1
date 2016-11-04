//
//  Node.m
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/29/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//



#import "Node.h"

@implementation Node
@synthesize depth;
@synthesize children;
@synthesize hn;
@synthesize boardState;
@synthesize tileOrder;
@synthesize parent;
@synthesize hnType;
@synthesize goalStateTileOrder;
@synthesize nodeIdentifier;
@synthesize creationDate;


- (id) initWithIDNumber: (int) passedNodeIdentifier boardState: (NSMutableArray*) initBoardState heuristicType: (enum HEURISTIC) passedHn goalStateTileOrder: (NSArray *) passedGoalStateTileOrder andParentNode: (Node *) parentNode{
    self = [super init];
    
    if (self){
        self.hnType = passedHn;
        self.nodeIdentifier = passedNodeIdentifier;
        self.parent = parentNode;
        self.goalStateTileOrder = passedGoalStateTileOrder;
        self.boardState = initBoardState;
        self.creationDate = [NSDate date];
        self.depth = parentNode.depth + 1;
        self.tileOrder = [self createTileArrayFromBoardState:initBoardState];
        self.children = [[NSArray alloc] init];
        
        self.hn = [self calculateHeuristicUsingHeuristicType:self.hnType];
    }
    
    return self;
}

- (id) initWithIDNumber: (int) passedNodeIdentifier boardStateTileOrder: (NSArray*) initTileOrder  heuristicType: (enum HEURISTIC) passedHn goalStateTileOrder: (NSArray *) passedGoalStateTileOrder andParentNode: (Node *) parentNode{
    self = [super init];
    
    if (self){
        self.parent = parentNode;
        self.hnType = passedHn;
        self.nodeIdentifier = passedNodeIdentifier;
        self.tileOrder = initTileOrder;
        self.creationDate = [NSDate date];
        self.children = [[NSArray alloc] init];
        self.goalStateTileOrder = passedGoalStateTileOrder;
        if(parent){
            self.depth = parentNode.depth + 1;
        }
        else{
            self.depth = 0; // root node depth = 0
        }
        
        
        self.boardState = [self createBoardStateWithTileOrderArray:initTileOrder];
        
        self.hn = [self calculateHeuristicUsingHeuristicType:hnType];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    // Copying code here.
    Node* copy = [[[self class] allocWithZone:zone] init];
    
    if (copy){
        
        // primitives
        [copy setDepth:self.depth];
        [copy setHn:self.hn];
        [copy setNodeIdentifier:self.nodeIdentifier];
        [copy setHnType:self.hnType];
        
        // objects
        [copy setChildren:[self.children copyWithZone:zone]];
        [copy setBoardState:[self.boardState copyWithZone:zone]];
        [copy setTileOrder:[self.tileOrder copyWithZone:zone]];
        [copy setParent:[self.parent copyWithZone:zone]];
        [copy setGoalStateTileOrder:[self.goalStateTileOrder copyWithZone:zone]];
    }
    
    return copy;
}

- (int) valueForRow: (int) row andCollumn: (int) collumn{
    int value = [[[boardState objectAtIndex:row] objectAtIndex:collumn] intValue];
    return value;
}

- (BOOL) boardStateIsEqualToBoardStateOfNode: (Node *) compareNode{
    return [tileOrder isEqualToArray:compareNode.tileOrder];
}

- (NSComparisonResult)compare:(Node *)otherNode{
    // A* comparison is sort pqueue in ascending depth + hn Values
    /*if ((self.hn + self.depth) < (otherNode.hn + otherNode.depth))
        return NSOrderedAscending;
    else if ((self.hn + self.depth) > (otherNode.hn + otherNode.depth))
        return NSOrderedDescending;
    
    return NSOrderedSame;*/
    
    BOOL currentNodeisMoreRecent = [[creationDate earlierDate:otherNode.creationDate] isEqualToDate: creationDate];
    
    if ((self.hn + self.depth) < (otherNode.hn + otherNode.depth)){
        return NSOrderedAscending;
    }
    else if ((self.hn + self.depth) > (otherNode.hn + otherNode.depth)){
        return NSOrderedDescending;
    }
    else{
        if(!currentNodeisMoreRecent){
            return NSOrderedAscending;
        }
        else{
            return NSOrderedDescending;
        }
        
    }
    return NSOrderedSame;
}




- (TileLocation*) locationOfFreeTileInBoardState{
    TileLocation* freeTileLocation;
    for(int i = 0; i < [self.boardState count]; i++){
        for (int j = 0; j < [[self.boardState objectAtIndex:i] count]; j++) {
            if ([[[self.boardState objectAtIndex:i] objectAtIndex:j] intValue] == 0) {
                //NSLog(@"free tile found");
                freeTileLocation = [[TileLocation alloc] initWithRow:i andCollumn:j];
                return freeTileLocation;
            }
        }
    }
    return freeTileLocation;
}

- (TileLocation*) locationOfTileForIntInBoardState: (int) numberToLocate{
    TileLocation* tileLocation;
    for(int i = 0; i < [self.boardState count]; i++){
        for (int j = 0; j < [[self.boardState objectAtIndex:i] count]; j++) {
            if ([[[self.boardState objectAtIndex:i] objectAtIndex:j] intValue] == 0) {
                //NSLog(@"free tile found");
                tileLocation = [[TileLocation alloc] initWithRow:i andCollumn:j];
                return tileLocation;
            }
        }
    }
    return tileLocation;
}

- (TileLocation*) locationOfTileForIntInGoalState: (int) numberToLocate{
    TileLocation* numberLocation = nil;
    if (numberToLocate >= 0 && numberToLocate < [goalStateTileOrder count]) {
        for (int i = 0; i < [goalStateTileOrder count]; i++) {
            if(numberToLocate == [[goalStateTileOrder objectAtIndex:i] intValue]){
                int row = i/[[boardState objectAtIndex:0] count];
                int collumn = i % [boardState count];
                numberLocation = [[TileLocation alloc] initWithRow:row andCollumn:collumn];
            }
        }
    }
    else{
        NSLog(@"Number to find is out of puzzle range");
    }
    return numberLocation;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"\nNode %d with parent %d, hn %.1f, depth %.1f, date %@ and boardstate \n%@ %@ %@\n%@ %@ %@\n%@ %@ %@",nodeIdentifier, [parent nodeIdentifier], hn, depth, creationDate,[[boardState objectAtIndex:0]objectAtIndex:0],[[boardState objectAtIndex:0]objectAtIndex:1],[[boardState objectAtIndex:0]objectAtIndex:2],[[boardState objectAtIndex:1]objectAtIndex:0],[[boardState objectAtIndex:1]objectAtIndex:1],[[boardState objectAtIndex:1]objectAtIndex:2],[[boardState objectAtIndex:2]objectAtIndex:0],[[boardState objectAtIndex:2]objectAtIndex:1],[[boardState objectAtIndex:2]objectAtIndex:2]];
    
    
    //[[NSString alloc] initWithFormat:@"%@ %@ %@\n%@ %@ %@\n%@ %@ %@",[[boardState objectAtIndex:0]objectAtIndex:0],[[boardState objectAtIndex:0]objectAtIndex:1],[[boardState objectAtIndex:0]objectAtIndex:2],[[boardState objectAtIndex:1]objectAtIndex:0],[[boardState objectAtIndex:1]objectAtIndex:1],[[boardState objectAtIndex:1]objectAtIndex:2],[[boardState objectAtIndex:2]objectAtIndex:0],[[boardState objectAtIndex:2]objectAtIndex:1],[[boardState objectAtIndex:2]objectAtIndex:2]];
}






- (NSMutableArray*) createBoardStateWithTileOrderArray: (NSArray*) initTileOrder{
    NSMutableArray* row1 = [[NSMutableArray alloc] initWithObjects:[tileOrder objectAtIndex:0],[initTileOrder objectAtIndex:1],[initTileOrder objectAtIndex:2], nil];
    NSMutableArray* row2 = [[NSMutableArray alloc] initWithObjects:[initTileOrder objectAtIndex:3],[initTileOrder objectAtIndex:4],[initTileOrder objectAtIndex:5], nil];
    NSMutableArray* row3 = [[NSMutableArray alloc] initWithObjects:[initTileOrder objectAtIndex:6],[initTileOrder objectAtIndex:7],[initTileOrder objectAtIndex:8], nil];
    
    return [[NSMutableArray alloc] initWithObjects:row1,row2,row3, nil];
}

- (NSArray*) createTileArrayFromBoardState: (NSMutableArray*) initBoardState{
    NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int row = 0; row < [initBoardState count]; row++){
        for (int collumn = 0; collumn < [[initBoardState objectAtIndex:row] count] ; collumn++) {
            [tmp addObject:[[initBoardState objectAtIndex: row] objectAtIndex:collumn]];
        }
    }
    
    return [[NSArray alloc] initWithArray:[tmp copy] copyItems:YES];
}

- (float) calculateHeuristicUsingHeuristicType: (enum HEURISTIC) heuristic{
    float calculatedHn = 0;
    
    switch (heuristic) {
        case MISPLACED_TILE:
        {
            float misplacedTile = 0;
            for(int i = 0; i < [tileOrder count]; i++){
                if ([[tileOrder objectAtIndex:i] intValue] != [[goalStateTileOrder objectAtIndex:i] intValue]) {
                    misplacedTile++;
                }
            }
            
            calculatedHn = misplacedTile;
            
            //NSLog(@"Heuristic for Node %d with ft loc %@ using Misplaced Tile = %.1f", nodeIdentifier, [self locationOfFreeTileForNode:self], calculatedHn);
            
            break;
        }
            
        case UNIFORM_COST_SEARCH:
            calculatedHn = 0;
            
            //NSLog(@"Heuristic for Node %d with ft loc %@  using UCS = %.1f", nodeIdentifier, [self locationOfFreeTileForNode:self], calculatedHn);
            
            break;
            
            
        case MANHATTAN_DISTANCE:
            calculatedHn = 0;
            for (int row = 0; row < [boardState  count]; row++) {
                for (int collumn = 0; collumn < [[boardState objectAtIndex:0] count]; collumn++) {
                    int tile = [[[boardState objectAtIndex:row] objectAtIndex:collumn] intValue];
                    
                    if(tile > 0){
                        TileLocation* numberLocationInGoalState = [self locationOfTileForIntInGoalState:tile];
                        
                        int targetRow = numberLocationInGoalState.row;
                        int targetCollumn = numberLocationInGoalState.collumn;
                        
                        int drow = row - targetRow;
                        int dcollumn = collumn - targetCollumn;
                    
                        calculatedHn += (abs(drow) + abs(dcollumn));
                    }
                }
            }
            
            //NSLog(@"Heuristic for Node %d with ft loc %@  using Manhattan Distance = %.1f", nodeIdentifier, [self locationOfFreeTileForNode:self], calculatedHn);
            
            break;
            
            
        default:
            NSLog(@"Never Used.");
            break;
    }
    
    
    
    return calculatedHn;
}

@end
