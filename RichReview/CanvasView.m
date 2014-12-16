//
//  CanvasView.m
//  RichReview
//
//  Created by dev on 12/15/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "CanvasView.h"

@implementation CanvasView
{
    DrawingView *drawingView;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [[WacomManager getManager] registerForNotifications:self];
        
        
        NSURL *imgUrl=[[NSURL alloc] initWithString:@"http://www.regionalkinetics.com/local-docs/satloff-first%20page.JPG"];
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        UIImage *img = [UIImage imageWithData:imgData];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        
        [self addSubview:imageView ];
        [self sendSubviewToBack:imageView ];
        
        drawingView = [[DrawingView alloc]init];
        [self insertSubview:drawingView aboveSubview:imageView];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [drawingView touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [drawingView touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [drawingView touchesEnded:touches withEvent:event];
}

- (void) flipHover
{
    [drawingView flipHover];
}
- (void) setHover:(bool) isHover
{
    [drawingView setHover:isHover];
}

- (void) erase
{
    [drawingView erase];
}

- (void) undoLastStroke
{
    [drawingView undoLastStroke];
}

- (void) flipPressureMode
{
    [drawingView flipPressureMode];
}

- (bool) getPressureMode;
{
    return drawingView.pressureMode;
}


/// notification when pressure or other event is received from the Wacom SDK
- (void) stylusEvent:(WacomStylusEvent *)stylusEvent
{
    [drawingView stylusEvent:stylusEvent];
}


@end
