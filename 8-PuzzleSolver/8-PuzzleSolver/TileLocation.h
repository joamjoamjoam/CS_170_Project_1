//
//  TileLocation.h
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/29/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

// must conform to NSCopying

#import <Foundation/Foundation.h>

@interface TileLocation : NSObject <NSCopying>

@property int row;
@property int collumn;


- (id) initWithRow: (int) passedRow andCollumn: (int) passedCollumn;
- (NSString*) description;
@end
