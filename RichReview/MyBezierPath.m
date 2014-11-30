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
    self.bezierPath = [UIBezierPath bezierPath];
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    self.bezierPath.lineWidth = lineWidth;
    
    pointsArray = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) moveToPoint:(CGPoint)point
{
    [pointsArray addObject: [NSValue valueWithCGPoint:point]];
    [_bezierPath moveToPoint:point];
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

@end
