//
//  DrawingView.h
//  RichReview
//
//  Created by dev on 11/18/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomDevice/WacomDeviceFramework.h>

#define DEFAULT_COLOR               [UIColor blackColor]
#define HOVER_COLOR                 [UIColor colorWithRed:0 green:0 blue:0.6 alpha:0.2]
#define DEFAULT_WIDTH               1.0f
#define DEFAULT_BACKGROUND_COLOR    [UIColor whiteColor]
#define HOVER_BRUSH_WIDTH           30.0f
#define DUMMY_CGPOINT               CGPointMake(-1,-1)
#define PRESSURE_BENCHMARK          300
#define DUMMY_PRESSURE              2000

@interface DrawingView : UIView <WacomStylusEventCallback>

@property (nonatomic, strong) UIColor *brushColor;
@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) BOOL empty;

@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) CGPoint previousPreviousPoint;

@property(nonatomic,assign)  BOOL pressureMode;

/// a callback method for the Wacom SDK that provides pressure data among other things.
- (void) stylusEvent:(WacomStylusEvent *)stylusEvent;

/// Set hover mode
- (void) setHover:(BOOL)inHoverMode;
- (void) flipHover;

/// clears the screen.
- (void) erase;

- (void) undoLastStroke;

- (void) endPathAndCreateLayer;

// this one does not work yet.
- (void) replayLastStroke;

- (void) detectHover;

- (void) flipPressureMode;
- (BOOL) getPressureMode;

@end
