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
#define HOVER_COLOR                 [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]
#define DEFAULT_WIDTH               1.0f
#define DEFAULT_BACKGROUND_COLOR    [UIColor whiteColor]
#define HOVER_BRUSH_WIDTH            30.0f
#define DUMMY_CGPOINT               CGPointMake(-1,-1)

@interface DrawingView : UIView <WacomStylusEventCallback>

@property (nonatomic, strong) UIColor *brushColor;
@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) BOOL empty;

@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) CGPoint previousPreviousPoint;


- (id) initWithFrame:(CGRect)frame withBrushColor: (UIColor *)brushColor withBrushWidth: (CGFloat) brushWidth;

/// a callback method for the Wacom SDK that provides pressure data among other things.
-(void)stylusEvent:(WacomStylusEvent *)stylusEvent;

/// Set hover mode
-(void)setHover:(BOOL)inHoverMode;
-(void)flipHover;

/// clears the screen.
-(void)erase;

- (void) endPathAndCreateLayer;


@end
