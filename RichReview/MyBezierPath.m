//
//  MyBezierPath.m
//  RichReview
//
//  Created by Chong Wang on 11/27/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "MyBezierPath.h"

@implementation MyBezierPath
{
    NSMutableArray *pointsArray;
}

- (id) initWithLineWidth: (CGFloat) lineWidth
{
    self = [super init];
    
    if (self)
    {
        _bezierPath = [[UIBezierPath bezierPath] copy];
        _bezierPath.lineCapStyle = kCGLineCapRound;
        _bezierPath.lineWidth = lineWidth;
        pointsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) moveToPoint:(CGPoint)point
{
    [pointsArray addObject: [NSValue valueWithCGPoint:point]];
    [self.bezierPath moveToPoint:point];
}

- (void) addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint
{
    [pointsArray addObject: [NSValue valueWithCGPoint:endPoint]];
    [_bezierPath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
}

- (void) setLineWidth: (CGFloat) lineWidth
{
    [_bezierPath setLineWidth:lineWidth];
}

- (NSMutableArray *) getPoints
{
    return pointsArray;
}

- (void) stroke
{
    [_bezierPath stroke];
}

@end
