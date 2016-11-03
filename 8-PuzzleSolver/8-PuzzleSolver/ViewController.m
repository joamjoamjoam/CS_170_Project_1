//
//  ViewController.m
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/26/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "ViewController.h"
#import "Node.h"

@interface ViewController ()

@end

// to do
// implement MAnhattan distance hn calc

// expanding is wrong maybe just the side = 3 moves type




@implementation ViewController
@synthesize debugConsoleTextView;
@synthesize pqueue;
@synthesize archive;
@synthesize closedList;

NSString* displayText = @"";
int currNodeIdentifier = -1;

// need to save and load pqueue, display text and currNodeID between segues and view changes.



- (void)viewDidLoad {
    [super viewDidLoad];
    
    pqueue = [[NSMutableArray alloc] initWithCapacity:0];
    closedList = [[NSMutableArray alloc] initWithCapacity:0];
    // holds all created nodes
    archive = [[NSMutableArray alloc] initWithCapacity:0];
    int nodesExpanded = 0;
    //NSArray* goalState = [[NSArray alloc] initWithObjects:@1,@2,@3,@4,@0,@5,@6,@7,@8, nil];
    // implement goal state passing
    // ask for goal state and initial state
    
    NSArray* goalStateTileOrder = [[NSArray alloc] initWithObjects:@0,@1,@2,@3,@4,@5,@6,@7,@8, nil];
    
    // initial board state p.s. @ makes int an object
    NSArray* initialTileOrder = [[NSArray alloc] initWithObjects:@1,@2,@0,@3,@4,@5,@6,@7,@8, nil];
    // teachers test hard
    //NSArray* initialTileOrder = [[NSArray alloc] initWithObjects:@4,@2,@8,@6,@0,@3,@7,@5,@1, nil];
    // teachers test easy
    //NSArray* initialTileOrder = [[NSArray alloc] initWithObjects:@1,@2,@3,@4,@0,@6,@7,@5,@8, nil];
    
    
    
    
    Node* root = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardStateTileOrder:initialTileOrder heuristicType:MISPLACED_TILE goalStateTileOrder: goalStateTileOrder andParentNode:nil];
    [self pushNodeToPQueue:root];
    [archive addObject:root];
    [self debugLog:[NSString stringWithFormat:@"Root = %@", root]];
    
    [self debugLog:@"Working ..."];
    
    while (![self isGoalStateForNode:[pqueue objectAtIndex:0]] || [pqueue count] == 0) {
        // when you pop off the node you are expanding you are destroying it like where does the child point to what parent now??
        Node* expandNode = [pqueue objectAtIndex:0];
        
        [closedList addObject:expandNode];
        [self popNodeFromPQueue];
        
        //[self debugLog:[NSString stringWithFormat:@"Node %d expanded with depth %.1f and hn %.1f",expandNode.nodeIdentifier,expandNode.depth, expandNode.hn]];
        
        expandNode.children = [self expandNode:expandNode];
        nodesExpanded++;
        
        for(Node* child in expandNode.children){
            // if boardstate doesnt exist in pqueue or closed list then add it to pqueue
            // else if it exists is depth+h(n) lower then replace it
            
            BOOL foundClosed = NO;
            BOOL foundPqueue = NO;
            
            for (int i = 0; i < [pqueue count]; i++) {
                if([child boardStateIsEqualToBoardStateOfNode:[pqueue objectAtIndex:i]]){
                    // child node found at i
                    foundPqueue = YES;
                    float costOfChild = child.depth + child.hn;
                    float costOfClosedChild = [[pqueue objectAtIndex:i] depth] + [[pqueue objectAtIndex:i] hn];
                    if(costOfChild < costOfClosedChild){
                        [pqueue removeObjectAtIndex:i];
                        [self pushNodeToPQueue:child];
                        //[self debugLog:[NSString stringWithFormat:@"Node %d was found in pqueue and replaced", child.nodeIdentifier]];
                    }
                    else{
                        //[self debugLog:[NSString stringWithFormat:@"Node %d was found in pqueue and ignored", child.nodeIdentifier]];
                    }
                }
            }
            
            for (int i = 0; i < [closedList count]; i++) {
                if([child boardStateIsEqualToBoardStateOfNode:[closedList objectAtIndex:i]]){
                    // child node found at i
                    foundClosed = YES;
                    float costOfChild = child.depth + child.hn;
                    float costOfClosedChild = [[closedList objectAtIndex:i] depth] + [[closedList objectAtIndex:i] hn];
                    if(costOfChild < costOfClosedChild){
                        [closedList removeObjectAtIndex:i]; // not sure if we should remove it
                        [self pushNodeToPQueue:child];
                        //[self debugLog:[NSString stringWithFormat:@"Node %d was found in closedList and replaced", child.nodeIdentifier]];
                    }
                    else{
                        //[self debugLog:[NSString stringWithFormat:@"Node %d was found in closedList and ignored", child.nodeIdentifier]];
                    }
                }
            }
            if(!foundClosed && !foundPqueue){
                [self pushNodeToPQueue:child];
            }
        }
    }
    
    if ([pqueue count] == 0) {
        // No solution Found
        [self debugLog:@"No Solution Found"];
    }
    else{
        Node* successNode = [pqueue objectAtIndex:0];
        //[self debugLog:[NSString stringWithFormat:@"Array = %@", pqueue]];
        // trace back node and show path
        [self debugLog:[NSString stringWithFormat:@"Solution found at node %d in %d Nodes at depth %.1f by expanding %d nodes", successNode.nodeIdentifier,currNodeIdentifier - 1, successNode.depth, nodesExpanded]];
        
        Node* solWalker = successNode;
        NSString* solutionPath = [[NSString alloc] initWithFormat:@"%d",solWalker.nodeIdentifier];
        while (solWalker.parent) {
            solutionPath =  [NSString stringWithFormat:@"%d, %@", solWalker.parent.nodeIdentifier, solutionPath];
            solWalker = solWalker.parent;
        }
        [self debugLog:[NSString stringWithFormat:@"Solution Path = %@",solutionPath]];
    }
    
    
    self.debugConsoleTextView.text = displayText;
}



#pragma mark My Helper Functions

- (void) debugLog: (NSString*) tmp{
    NSLog(@"%@",tmp);
    NSString* tmp2 = [@"\n > " stringByAppendingString:tmp];
    displayText = [displayText stringByAppendingString:tmp2];
}


// for 8 puzzle
- (NSArray*) createBoardStateWithTileOrderArray: (NSArray*) tileOrder{
    NSArray* row1 = [[NSArray alloc] initWithObjects:[tileOrder objectAtIndex:0],[tileOrder objectAtIndex:1],[tileOrder objectAtIndex:2], nil];
    NSArray* row2 = [[NSArray alloc] initWithObjects:[tileOrder objectAtIndex:3],[tileOrder objectAtIndex:4],[tileOrder objectAtIndex:5], nil];
    NSArray* row3 = [[NSArray alloc] initWithObjects:[tileOrder objectAtIndex:6],[tileOrder objectAtIndex:7],[tileOrder objectAtIndex:8], nil];
    
    return [[NSArray alloc] initWithObjects:row1,row2,row3, nil];
}
- (NSArray*) expandNode: (Node*) parent{
    // 3 possible states for free tile
    // corner = 2 possible moves
    // middle = 4 possible moves
    // side = 3 possible moves
    
    NSArray* returnChildrenArray = [[NSArray alloc] init];
    
    TileLocation* freeTileLocation = [parent locationOfFreeTileInBoardState];
    
    // generate nodes to add to children array
    // free tile is in a corner moves = 2
    if (freeTileLocation.row == 0 && freeTileLocation.collumn == 0) {
        // upper left corner
        
        NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:1]];
        
        NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:0]];
        
        Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType  goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        
        // add to pqueue here tmp
        //[self pushNodeToPQueue:move1ChildNode];
        //[self pushNodeToPQueue:move2ChildNode];
        
        [archive addObject:move1ChildNode];
        [archive addObject:move2ChildNode];
        
        
        return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode, nil];
        
    }
    else if(freeTileLocation.row == 0 && freeTileLocation.collumn == 2){
        // upper right corner
        NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:1]];
        
        NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:2]];
        
        Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        
        // add to pqueue here tmp
        //[self pushNodeToPQueue:move1ChildNode];
        //[self pushNodeToPQueue:move2ChildNode];
        
        [archive addObject:move1ChildNode];
        [archive addObject:move2ChildNode];
        
        return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode, nil];
    }
    else if(freeTileLocation.row == 2 && freeTileLocation.collumn == 0){
        // lower left corner
        
        NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:1]];
        
        NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:0]];
        
        Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        
        // add to pqueue here tmp
        //[self pushNodeToPQueue:move1ChildNode];
        //[self pushNodeToPQueue:move2ChildNode];
        
        [archive addObject:move1ChildNode];
        [archive addObject:move2ChildNode];
        
        return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode, nil];
    }
    else if(freeTileLocation.row == 2 && freeTileLocation.collumn == 2){
        // lower right corner
        
        NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:1]];
        
        NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:2]];
        
        Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        
        // add to pqueue here tmp
        //[self pushNodeToPQueue:move1ChildNode];
        //[self pushNodeToPQueue:move2ChildNode];
        
        [archive addObject:move1ChildNode];
        [archive addObject:move2ChildNode];
        
        return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode, nil];
    }
    else if(freeTileLocation.row == 1 && freeTileLocation.collumn == 1){
        // free tile is in the middle moves = 4
        
        NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:1]];
        
        NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:2]];
        
        NSMutableArray* move3BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move3BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:1]];
        
        NSMutableArray* move4BoardState = [self copyBoardState:parent.boardState];
        [self swapTilein:move4BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:0]];
        
        Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move3ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move3BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        Node* move4ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move4BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
        
        // add to pqueue here tmp
        //[self pushNodeToPQueue:move1ChildNode];
        //[self pushNodeToPQueue:move2ChildNode];
        //[self pushNodeToPQueue:move3ChildNode];
        //[self pushNodeToPQueue:move4ChildNode];
        
        [archive addObject:move1ChildNode];
        [archive addObject:move2ChildNode];
        [archive addObject:move3ChildNode];
        [archive addObject:move4ChildNode];
        
        return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode,move3ChildNode,move4ChildNode, nil];
    }
    else{
        // free tile is against a side moves = 3
        if(freeTileLocation.row == 0 && freeTileLocation.collumn == 1){
            // top side
            
            NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:1]];
            
            NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:0]];
            
            NSMutableArray* move3BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move3BoardState from:[[TileLocation alloc] initWithRow:0 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:2]];
            
            
            Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move3ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move3BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            
            // add to pqueue here tmp
            //[self pushNodeToPQueue:move1ChildNode];
            //[self pushNodeToPQueue:move2ChildNode];
            //[self pushNodeToPQueue:move3ChildNode];
            
            [archive addObject:move1ChildNode];
            [archive addObject:move2ChildNode];
            [archive addObject:move3ChildNode];
            
            return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode,move3ChildNode, nil];
        }
        else if(freeTileLocation.row == 1 && freeTileLocation.collumn == 2){
            // right side
            
            NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:2]];
            
            NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:1]];
            
            NSMutableArray* move3BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move3BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:2] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:2]];
            
            
            Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move3ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move3BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            
            // add to pqueue here tmp
            //[self pushNodeToPQueue:move1ChildNode];
            //[self pushNodeToPQueue:move2ChildNode];
            //[self pushNodeToPQueue:move3ChildNode];
            
            [archive addObject:move1ChildNode];
            [archive addObject:move2ChildNode];
            [archive addObject:move3ChildNode];
            
            return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode,move3ChildNode, nil];
            
        }
        else if(freeTileLocation.row == 2 && freeTileLocation.collumn == 1){
            // bottom side
            
            NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:2]];
            
            NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:1]];
            
            NSMutableArray* move3BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move3BoardState from:[[TileLocation alloc] initWithRow:2 andCollumn:1] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:0]];
            
            
            Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move3ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move3BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            
            // add to pqueue here tmp
            //[self pushNodeToPQueue:move1ChildNode];
            //[self pushNodeToPQueue:move2ChildNode];
            //[self pushNodeToPQueue:move3ChildNode];
            
            [archive addObject:move1ChildNode];
            [archive addObject:move2ChildNode];
            [archive addObject:move3ChildNode];
            
            return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode,move3ChildNode, nil];
        }
        else if(freeTileLocation.row == 1 && freeTileLocation.collumn == 0){
            // left side
            //[self displayBoardstate:parent.boardState];
            NSMutableArray* move1BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move1BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:0 andCollumn:0]];
            
            //[self debugLog:@"after move 1 parent = "];
            //[self displayBoardstate:parent.boardState];
            //[self debugLog:@"after move 1 move = "];
            //[self displayBoardstate:move1BoardState];
            
            NSMutableArray* move2BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move2BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:1 andCollumn:1]];
            
            //[self debugLog:@"after move 2 parent = "];
            //[self displayBoardstate:parent.boardState];
            //[self debugLog:@"after move 2 move = "];
            //[self displayBoardstate:move2BoardState];
            
            NSMutableArray* move3BoardState = [self copyBoardState:parent.boardState];
            [self swapTilein:move3BoardState from:[[TileLocation alloc] initWithRow:1 andCollumn:0] toLocation:[[TileLocation alloc] initWithRow:2 andCollumn:0]];
            
            //[self debugLog:@"after move 3 parent = "];
            //[self displayBoardstate:parent.boardState];
            //[self debugLog:@"after move 3 move = "];
            //[self displayBoardstate:move3BoardState];
            
            Node* move1ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move1BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move2ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move2BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            Node* move3ChildNode = [[Node alloc] initWithIDNumber: [self assignNewNodeID] boardState:move3BoardState heuristicType:parent.hnType goalStateTileOrder: parent.goalStateTileOrder andParentNode:parent];
            
            //[self debugLog:@"Passed move 2 board state"];
            //[self displayBoardstate:move2ChildNode.boardState];
            //[self debugLog:[NSString stringWithFormat:@"Tile 2 -> %@", move2ChildNode.tileOrder]];
            
            // add to pqueue here tmp
            //[self pushNodeToPQueue:move1ChildNode];
            //[self pushNodeToPQueue:move2ChildNode];
            //[self pushNodeToPQueue:move3ChildNode];
            
            [archive addObject:move1ChildNode];
            [archive addObject:move2ChildNode];
            [archive addObject:move3ChildNode];
            
            return [[NSArray alloc] initWithObjects:move1ChildNode, move2ChildNode,move3ChildNode, nil];
        }
        else{
            [self debugLog:@"Never Should Run"];
        }
    }
    [self debugLog:@"Should Never Run"];
    return returnChildrenArray;
}




- (void) swapTilein: (NSMutableArray*) boardState from: (TileLocation*) start toLocation: (TileLocation*) end{
    //[self debugLog:@"start"];
    //[self displayBoardstate:boardState];
    
    NSNumber* from = [[boardState objectAtIndex:start.row] objectAtIndex:start.collumn];
    NSNumber* to = [[boardState objectAtIndex:end.row] objectAtIndex:end.collumn];
    
    [[boardState objectAtIndex:start.row] replaceObjectAtIndex:start.collumn withObject:to];
    [[boardState objectAtIndex:end.row] replaceObjectAtIndex:end.collumn withObject:from];
    
    //[self debugLog:@"end function"];
    //[self displayBoardstate:boardState];
    
}

- (void) displayBoardstate: (NSMutableArray*) boardState{
    [self debugLog:[[NSString alloc] initWithFormat:@"\n%@ %@ %@\n%@ %@ %@\n%@ %@ %@",[[boardState objectAtIndex:0]objectAtIndex:0],[[boardState objectAtIndex:0]objectAtIndex:1],[[boardState objectAtIndex:0]objectAtIndex:2],[[boardState objectAtIndex:1]objectAtIndex:0],[[boardState objectAtIndex:1]objectAtIndex:1],[[boardState objectAtIndex:1]objectAtIndex:2],[[boardState objectAtIndex:2]objectAtIndex:0],[[boardState objectAtIndex:2]objectAtIndex:1],[[boardState objectAtIndex:2]objectAtIndex:2]]];
}

- (void) pushNodeToPQueue: (Node *) node{
    [pqueue addObject:node];
    [pqueue sortUsingSelector:@selector(compare:)];
}

- (void) popNodeFromPQueue{
    [pqueue removeObjectAtIndex:0];
}

- (int) assignNewNodeID{
    return ++currNodeIdentifier;
}

- (NSMutableArray *) copyBoardState: (NSMutableArray *) boardStateToCopy{
    NSMutableArray* row1 = [[NSMutableArray alloc] initWithArray:[boardStateToCopy objectAtIndex:0] copyItems:YES];
    NSMutableArray* row2 = [[NSMutableArray alloc] initWithArray:[boardStateToCopy objectAtIndex:1] copyItems:YES];
    NSMutableArray* row3 = [[NSMutableArray alloc] initWithArray:[boardStateToCopy objectAtIndex:2] copyItems:YES];
    
    return [[NSMutableArray alloc] initWithObjects:row1,row2,row3, nil];
}

- (BOOL) isGoalStateForNode: (Node *) nodeToTest{
    
    for(int i = 0; i < [nodeToTest.tileOrder count]; i++){
        if ([[nodeToTest.tileOrder objectAtIndex:i] intValue] != [[nodeToTest.goalStateTileOrder objectAtIndex:i] intValue]) {
            return NO;
        }
    }
    
    return YES;
}
@end
