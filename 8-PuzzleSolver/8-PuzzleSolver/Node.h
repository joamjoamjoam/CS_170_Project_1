//
//  Node.h
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/29/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

// must conform to NSCopying

#import <Foundation/Foundation.h>
#import "TileLocation.h"

@interface Node : NSObject <NSCopying>

typedef NS_ENUM(NSInteger, HEURISTIC)
{
    MANHATTAN_DISTANCE = 1,
    UNIFORM_COST_SEARCH,
    MISPLACED_TILE
};


@property float depth;
@property float hn;
@property NSArray* children;
@property NSArray* tileOrder;
@property NSMutableArray* boardState;
@property Node* parent;
@property int nodeIdentifier;
@property enum HEURISTIC hnType;
@property NSArray* goalStateTileOrder;




#pragma mark Initialization Methods

- (id) initWithIDNumber: (int) passedNodeIdentifier boardState: (NSMutableArray*) initBoardState heuristicType: (enum HEURISTIC) passedHn goalStateTileOrder: (NSArray *) passedGoalStateTileOrder andParentNode: (Node *) parentNode;

- (id) initWithIDNumber: (int) passedNodeIdentifier boardStateTileOrder: (NSArray*) initTileOrder  heuristicType: (enum HEURISTIC) passedHn goalStateTileOrder: (NSArray *) passedGoalStateTileOrder andParentNode: (Node *) parentNode;


#pragma mark My Helper Methods
- (int) valueForRow: (int) row andCollumn: (int) collumn;
- (TileLocation*) locationOfFreeTileInBoardState;
- (TileLocation*) locationOfTileForIntInBoardState: (int) numberToLocate;
- (TileLocation*) locationOfTileForIntInGoalState: (int) numberToLocate;
- (BOOL) boardStateIsEqualToBoardStateOfNode: (Node *) compareNode;

#pragma mark conformities to NSComparison
- (NSComparisonResult)compare:(Node *)otherNode;

#pragma mark Overriden Super Functions
- (NSString*) description;


@end
