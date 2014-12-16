//
//  CanvasView.h
//  RichReview
//
//  Created by dev on 12/15/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomDevice/WacomDeviceFramework.h>
#import "DrawingView.h"

@interface CanvasView : UIView <WacomStylusEventCallback>

- (void) flipHover;
- (void) setHover:(bool) isHover;

- (void) erase;

- (void) undoLastStroke;

- (void) flipPressureMode;
- (bool) getPressureMode;

@end
