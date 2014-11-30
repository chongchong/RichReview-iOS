//
//  MyBezierPath.h
//  RichReview
//
//  Created by Chong Wang on 11/27/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBezierPath  : NSObject

@property (nonatomic, assign) UIBezierPath *bezierPath;

- (id) initWithLineWidth: (CGFloat) lineWidth;
- (void) setLineWidth: (CGFloat) lineWidth;
- (void) moveToPoint:(CGPoint)point;
- (void) addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;

- (NSMutableArray *) getPoints;

@end
