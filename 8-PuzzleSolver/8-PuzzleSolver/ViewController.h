//
//  ViewController.h
//  8-PuzzleSolver
//
//  Created by Trent Callan on 10/26/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *debugConsoleTextView;
@property NSMutableArray* pqueue;
@property NSMutableArray* closedList;
@property NSMutableArray* archive;

@end

