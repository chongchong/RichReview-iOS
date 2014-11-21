//
//  DrawingView.m
//  RichReview
//
//  Created by dev on 11/18/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "DrawingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DrawingView
{
    GLfixed mBrushWidth;
    CGFloat mPressure;          // recent pressure vaue from Wacom framwork.
    CGFloat mCurrentPressure;   // current pressure to draw a line.
    CGFloat mPreviousPressure;  // previous pressure value to draw a line.
    NSInteger mBrushSize;
    BOOL mHoverMode;
    
    
    NSMutableArray *mPathArray;
    UIBezierPath  *mPath;
    
    CGPoint lastTouch;
}


//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//
//    if (self) {
//        // NOTE: do not change the backgroundColor here, so it can be set in IB.
//        mPath = CGPathCreateMutable();
//        _brushWidth = DEFAULT_WIDTH;
//        _brushColor = DEFAULT_COLOR;
//        _empty = YES;
//        mPathArray = [[NSMutableArray alloc] init];
//    }
//
//    return self;
//}

- (id) initWithFrame:(CGRect)frame withBrushColor: (UIColor *)brushColor withBrushWidth: (CGFloat) brushWidth
{
    self = [super initWithFrame:frame];
    if (self){
        _brushColor = brushColor;
        _brushWidth = brushWidth;
        self.backgroundColor = [UIColor clearColor];
        
        mPathArray = [[NSMutableArray alloc]init];
    }
    return self;
    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        
        [[WacomManager getManager] registerForNotifications:self];
        
        _brushColor = DEFAULT_COLOR;
        _brushWidth = DEFAULT_WIDTH;
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        mPathArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void) setHover:(BOOL)inHoverMode
{
    mHoverMode = inHoverMode;
    if (mPath != nil) [self endPathAndCreateLayer];
    
    _brushWidth = mHoverMode? HOVER_BRUSH_WIDTH : DEFAULT_WIDTH;
    _brushColor = mHoverMode? HOVER_COLOR : DEFAULT_COLOR;
    [self createNewPath];
    NSLog(@"brush width is %f", _brushWidth);
}

- (void) flipHover
{
    [self setHover:!mHoverMode];
}

- (void) erase
{
    
}

- (void) drawRect:(CGRect)rect{
    [self.brushColor setStroke];
    [mPath stroke];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mPath == nil){
        NSLog(@"mPaht is nil");
        [self createNewPath];
    }
    
    NSLog(@"Touch Began");
    self.currentPoint = self.previousPoint = self.previousPreviousPoint = DUMMY_CGPOINT;
    [[TouchManager GetTouchManager] addTouches:touches knownTouches:[event touchesForView:self] view:self];
    @try
    {
        NSArray *theTrackedTouches = [[TouchManager GetTouchManager] getTrackedTouches];
        //if ([theTrackedTouches count]==0) [self touchesCancelled:touches withEvent:event];
        for(TrackedTouch *touch in theTrackedTouches)
        {
                self.currentPoint = touch.currentLocation;
                NSLog(@"Touch began is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
                self.previousPoint = touch.previousLocation;
                self.previousPreviousPoint = touch.previousLocation;
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Uh-oh");
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try
    {
        CGPoint current, previous;
        [[TouchManager GetTouchManager] moveTouches:touches  knownTouches:[event touchesForView:self] view:self];
        NSArray *theTrackedTouches = [[TouchManager GetTouchManager] getTrackedTouches];
        for(TrackedTouch *touch in theTrackedTouches)
        {
            if([touches containsObject:touch.associatedTouch])
            {
                
                // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
                current = touch.currentTouchLocation;
                //current.y = self.bounds.size.height - touch.currentLocation.y;
                previous = touch.previousTouchLocation;
                //previous.y = self.bounds.size.height - touch.previousLocation.y;
                
                //if (CGPointEqualToPoint(self.previousPoint, DUMMY_CGPOINT)) self.previousPreviousPoint = previous;
               // else
                    self.previousPreviousPoint = self.previousPoint;
                self.previousPoint = previous;
                self.currentPoint = current;
                //NSLog(@"Touch previous is (%f, %f)", self.previousPoint.x, self.previousPoint.y);
                //NSLog(@"Touch move is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
                
                CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
                CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);
                
                [mPath moveToPoint:mid1];
                [mPath addQuadCurveToPoint:mid2 controlPoint:self.previousPoint];
                
                
                [self setNeedsDisplay];
            }
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Uh-oh");
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try
    {
        CGPoint current, previous;
        [[TouchManager GetTouchManager] moveTouches:touches  knownTouches:[event touchesForView:self] view:self];
        NSArray *theTrackedTouches = [[TouchManager GetTouchManager] getTrackedTouches];
        for(TrackedTouch *touch in theTrackedTouches)
        {
            if([touches containsObject:touch.associatedTouch])
            {
                
                // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
                current = touch.currentTouchLocation;
                //current.y = self.bounds.size.height - touch.currentLocation.y;
                previous = touch.previousTouchLocation;
                //previous.y = self.bounds.size.height - touch.previousLocation.y;
                
                self.previousPreviousPoint = self.previousPoint;
                self.previousPoint = previous;
                self.currentPoint = current;
                
                self.previousPreviousPoint = self.previousPoint;
                self.previousPoint = previous;
                self.currentPoint = current;
                
                CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
                CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);
                
                [mPath moveToPoint:mid1];
                [mPath addQuadCurveToPoint:mid2 controlPoint:self.previousPoint];
                
                [self setNeedsDisplay];
                [self endPathAndCreateLayer];
            }
        }
        NSLog(@"Touch end");
    }
    @catch (NSException *exception) {
        NSLog(@"uh oh in touchEnd %@ %@",[exception name] ,[exception reason]);
    }
    
    [[TouchManager GetTouchManager] removeTouches:touches knownTouches:[event touchesForView:self] view:self];
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch cancelled");
    [[TouchManager GetTouchManager] removeTouches:touches knownTouches:[event touchesForView:self] view:self];
}

- (void) createNewPath
{
    mPath = [UIBezierPath bezierPath];
    mPath.lineWidth = _brushWidth;
    mPath.lineCapStyle = kCGLineCapRound;
}

- (void) endPathAndCreateLayer
{
    [mPath moveToPoint:self.currentPoint];
    lastTouch = self.currentPoint;
    NSLog(@"Last location is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
    CAShapeLayer *line = [CAShapeLayer layer];
    
    line.path = mPath.CGPath;
    line.fillColor = nil;
    line.lineWidth = _brushWidth;
    line.opacity = 1;
    line.strokeColor = _brushColor.CGColor;
    line.lineCap = kCALineCapRound;
    line.shouldRasterize = YES;
    line.rasterizationScale = self.contentScaleFactor;
    [self.layer insertSublayer:line below:self.layer];
    
    [mPathArray addObject: mPath];
    
    mPath = nil;
}

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

/// notification when pressure or other event is received from the Wacom SDK
- (void) stylusEvent:(WacomStylusEvent *)stylusEvent
{
    
    switch ([stylusEvent getType])
    {
        case eStylusEventType_PressureChange:
            
            mPressure = [stylusEvent getPressure];
            break;
        case eStylusEventType_ButtonReleased:
        {
            //NSString *title     = @"Button released";
            NSString *message = nil;
            switch ([stylusEvent getButton])
            {
                case 2:
                {
                    message = @"Button 2 released";
                }
                    break;
                case 1:
                {
                    [self setHover:false];
                    message = @"Button 1 released.";
                }
                    break;
                default:
                    break;
            }
            //			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            //			[alertView show];
            
            
        }
            break;
            
        case eStylusEventType_ButtonPressed:
        {
            //NSString *title = @"Button Clicked";
            NSString *message = nil;
            switch ([stylusEvent getButton])
            {
                case 2:
                {
                    message = @"Button 2 clicked";
                }
                    break;
                case 1:
                {
                    [self setHover:true];
                    message = @"Button 1 Clicked.";
                }
                    break;
                default:
                    break;
            }
            //			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            //			[alertView show];
            
            
        }
            break;
        case eStylusEventType_MACAddressAvaiable:
            break;
        case eStylusEventType_BatteryLevelChanged:
            
        default:
            break;
    }
}

@end
