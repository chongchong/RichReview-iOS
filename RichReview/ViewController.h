//
//  ViewController.h
//  RichReview
//
//  Created by dev on 11/18/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLKit/GLKView.h"
#import "DrawingView.h"
#import <WacomDevice/WacomDeviceFramework.h>
@interface ViewController : UIViewController <UIPopoverControllerDelegate, WacomDiscoveryCallback, WacomStylusEventCallback>

@property (retain, nonatomic) IBOutlet UISegmentedControl *toolBar;
- (IBAction)SegControlPerformAction:(id)sender;
- (IBAction)showPrivacyMessage:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UISegmentedControl *HandednessControl;
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;

//@property (retain, nonatomic) IBOutlet GLKView *glview;

@property (retain, nonatomic) IBOutlet DrawingView *dV;

//WacomDiscoveryCallback

///notification method for when a device is connected.
- (void) deviceConnected:(WacomDevice *)device;

///notification method for when a device is disconnected.
- (void) deviceDisconnected:(WacomDevice *)device;

///notification method for when a device is discovered.
- (void) deviceDiscovered:(WacomDevice *)device;


///notification method for when device discovery is not possible because bluetooth is powered off.
///this allows one to pop up a warning dialog to let the user know to turn on bluetooth.
- (void) discoveryStatePoweredOff;

//WacomStylusEventCallback
///notification method for when a new stylus event is ready.
-(void)stylusEvent:(WacomStylusEvent *)stylusEvent;
@end
