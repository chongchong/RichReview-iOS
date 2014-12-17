//
//  DrawingView.m
//  RichReview
//
//  Created by dev on 11/18/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "DrawingView.h"
#import "MyBezierPath.h"
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
    NSMutableArray *mLayerArray;
    MyBezierPath  *mPath;
    NSMutableArray *mPathPoints;
    //    CGMutablePathRef mMutablePath;
    
    CGPoint lastTouch;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        _brushColor = DEFAULT_COLOR;
        _brushWidth = DEFAULT_WIDTH;
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        mPathArray = [[NSMutableArray alloc]init];
        
        mLayerArray = [[NSMutableArray alloc] init];
        [self createNewPath];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

- (void) createNewPath
{
    mPath = [[MyBezierPath alloc] initWithLineWidth: _brushWidth];
    //    [self setNeedsDisplay];
    //    mMutablePath = CGPathCreateMutable();
    //
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextAddPath(context, mMutablePath);
    //    CGContextSetLineCap(context, kCGLineCapRound);
    //    CGContextSetLineWidth(context, _brushWidth);
    //    CGContextSetStrokeColorWithColor(context, _brushColor.CGColor);
    //
    //    CGContextStrokePath(context);
}

- (void) flipPressureMode
{
    _pressureMode = !_pressureMode;
}

- (BOOL) getPressureMode
{
    return _pressureMode;
}

- (void) detectHover
{
    if (!_pressureMode) return;
    NSLog(@"current pressue is %f", mCurrentPressure);
    if (mCurrentPressure < PRESSURE_BENCHMARK)
    {
        if (!mHoverMode)
        {
            [self setHover: true];
        }
    }
    else if (mHoverMode)
    {
        [self setHover: false];
    }
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
    if (mPath != nil) [self endPathAndCreateLayer];
    
    for (CAShapeLayer *stroke in mLayerArray)
    {
        if (stroke){
            [stroke removeFromSuperlayer];
        }
    }
    [mLayerArray removeAllObjects];
    [self setNeedsDisplay];
}

- (void) undoLastStroke
{
    if (mPath != nil) [self endPathAndCreateLayer];
    CAShapeLayer *lastPathlayer = mLayerArray.lastObject;
    
    if (lastPathlayer)
    {
        [lastPathlayer removeFromSuperlayer];
        [mLayerArray removeObject:lastPathlayer];
        [self setNeedsDisplay];
        [mPathArray removeLastObject];
    }
}

- (void) replayLastStroke
{
    if (mPath != nil) [self endPathAndCreateLayer];
    CAShapeLayer *lastPathlayer = mLayerArray.lastObject;
    if (lastPathlayer)
    {
        [lastPathlayer removeFromSuperlayer];
    }
    MyBezierPath *lastPath = mPathArray.lastObject;
    UIBezierPath *replayStroke = [UIBezierPath bezierPath];
    if (lastPath)
    {
        for (NSValue *value in [lastPath getPoints])
        {
            CGPoint *point;
            [value getValue:point];
            [replayStroke moveToPoint:*point];
            [self setNeedsDisplay];
        }
    }
}

- (void) drawRect:(CGRect)rect{
    [self.brushColor setStroke];
    [mPath stroke];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mCurrentPressure = mPreviousPressure = mPressure;
    self.currentPoint = self.previousPoint = self.previousPreviousPoint = DUMMY_CGPOINT;
    [[TouchManager GetTouchManager] addTouches:touches knownTouches:[event touchesForView:self] view:self];
    NSLog(@"Touch Began");
    @try
    {
        NSArray *theTrackedTouches = [[TouchManager GetTouchManager] getTrackedTouches];
        
        for(TrackedTouch *touch in theTrackedTouches)
        {
            self.currentPoint = touch.currentLocation;
            NSLog(@"Touch began is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
            self.previousPoint = touch.previousLocation;
            self.previousPreviousPoint = touch.previousLocation;
            mCurrentPressure = mPressure;
            
            [self detectHover];
            
        }
        // [self touchesMoved:touches withEvent:event];
        
        if (CGPointEqualToPoint(self.currentPoint, DUMMY_CGPOINT))
        {
            UITouch *touch = [touches anyObject];
            
            self.currentPoint = [touch locationInView:self];
            NSLog(@"Dummy touch began is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
            self.previousPoint = [touch previousLocationInView:self];
            self.previousPreviousPoint = self.previousPoint;
            
            CGFloat touchSize = [[touch valueForKey:@"pathMajorRadius"] floatValue];
            NSLog(@"touch size is %.2f", touchSize);
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
        
        UITouch *touch = [touches anyObject];
        CGFloat touchSize = [[touch valueForKey:@"pathMajorRadius"] floatValue];
        NSLog(@"touch size is %.2f", touchSize);
        
        for(TrackedTouch *touch in theTrackedTouches)
        {
            if([touches containsObject:touch.associatedTouch])
            {
                if (touch.isStylus && mHoverMode)
                {
                    [self setHover:false];
                }
                else if (touch.isStylus==NO && mHoverMode==NO)
                {
                    [self setHover:true];
                }
                if (mPath == nil){
                    NSLog(@"mPaht is nil");
                    [self createNewPath];
                }
                // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
                current = touch.currentTouchLocation;
                //current.y = self.bounds.size.height - touch.currentLocation.y;
                previous = touch.previousTouchLocation;
                //previous.y = self.bounds.size.height - touch.previousLocation.y;
                
                //if (CGPointEqualToPoint(self.previousPoint, DUMMY_CGPOINT)) self.previousPreviousPoint = previous;
                //else
                self.previousPreviousPoint = self.previousPoint;
                self.previousPoint = previous;
                self.currentPoint = current;
                //NSLog(@"Touch previous is (%f, %f)", self.previousPoint.x, self.previousPoint.y);
                NSLog(@"Touch move is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
                
                CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
                CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);
                
                [mPath moveToPoint:mid1];
                [mPath addQuadCurveToPoint:mid2 controlPoint:self.previousPoint];
                
                // to represent the finger movement, create a new path segment,
                // a quadratic bezier path from mid1 to mid2, using previous as a control point
                //                CGMutablePathRef subpath = CGPathCreateMutable();
                //                CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
                //                CGPathAddQuadCurveToPoint(subpath, NULL,
                //                                          self.previousPoint.x, self.previousPoint.y,
                //                                          mid2.x, mid2.y);
                //                CGPathAddPath(mMutablePath, NULL, subpath);
                //                CGPathRelease(subpath);
                
                CGRect bounds = CGPathGetBoundingBox(CGPathCreateCopy(mPath.bezierPath.CGPath));
                CGRect drawBox = CGRectInset(bounds, -2.0 * mPath.bezierPath.lineWidth, -2.0 * mPath.bezierPath.lineWidth);
                [self setNeedsDisplayInRect:drawBox];
                
                if (mPressure != mCurrentPressure)
                {
                    mCurrentPressure = mPressure;
                }
                mPreviousPressure = mCurrentPressure;
                mCurrentPressure = mPressure;
                
                [self detectHover];
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
        NSLog(@"Begin Touch end");
        if (mPath == nil) return;
        NSLog(@"mPath not nil");
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
                
                // to represent the finger movement, create a new path segment,
                // a quadratic bezier path from mid1 to mid2, using previous as a control point
                //                CGMutablePathRef subpath = CGPathCreateMutable();
                //                CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
                //                CGPathAddQuadCurveToPoint(subpath, NULL,
                //                                          self.previousPoint.x, self.previousPoint.y,
                //                                          mid2.x, mid2.y);
                //                CGPathAddPath(mMutablePath, NULL, subpath);
                //                CGPathRelease(subpath);
                
                
                CGRect bounds = CGPathGetBoundingBox(CGPathCreateCopy(mPath.bezierPath.CGPath));
                CGRect drawBox = CGRectInset(bounds, -2.0 * mPath.bezierPath.lineWidth, -2.0 * mPath.bezierPath.lineWidth);
                [self setNeedsDisplayInRect:drawBox];
                [self endPathAndCreateLayer];
                if (mPressure != mCurrentPressure)
                {
                    mCurrentPressure = mPressure;
                }
                mPreviousPressure = mCurrentPressure;
                mCurrentPressure = mPressure;
                
                [self detectHover];
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
    if (mPath != nil)
    {
        [self endPathAndCreateLayer];
        [self undoLastStroke];
    }
}

- (void) endPathAndCreateLayer
{
    [mPath moveToPoint:self.currentPoint];
    lastTouch = self.currentPoint;
    NSLog(@"Last location is (%f, %f)", self.currentPoint.x, self.currentPoint.y);
    CGRect bounds = CGPathGetBoundingBox(CGPathCreateCopy(mPath.bezierPath.CGPath));
    CGRect drawBox = CGRectInset(bounds, -2.0 * mPath.bezierPath.lineWidth, -2.0 * mPath.bezierPath.lineWidth);
    [self setNeedsDisplayInRect:drawBox];
    CAShapeLayer *line = [CAShapeLayer layer];
    
    line.path = mPath.bezierPath.CGPath;
    line.fillColor = nil;
    line.lineWidth = _brushWidth;
    line.opacity = 1;
    line.strokeColor = _brushColor.CGColor;
    line.lineCap = kCALineCapRound;
    line.shouldRasterize = YES;
    line.rasterizationScale = self.contentScaleFactor;
    [self.layer insertSublayer:line above: mLayerArray.lastObject];
    [mLayerArray addObject: line];
    
    //    CAShapeLayer *line = [CAShapeLayer layer];
    //
    //    line.path = mMutablePath;
    //    line.fillColor = nil;
    //    line.lineWidth = _brushWidth;
    //    line.opacity = 1;
    //    line.strokeColor = _brushColor.CGColor;
    //    line.lineCap = kCALineCapRound;
    //    line.shouldRasterize = YES;
    //    line.rasterizationScale = self.contentScaleFactor;
    //    [self.layer insertSublayer:line below:self.layer];
    //    [mLayerArray addObject: line];
    
    
    [mPathArray addObject: mPath];
    
    mPath = nil;
    //    CFRelease(mMutablePath);
    //    mMutablePath = nil;
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
