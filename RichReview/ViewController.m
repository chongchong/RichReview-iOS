//
//  ViewController.m
//  RichReview
//
//  Created by dev on 11/18/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "ViewController.h"
#import "DiscoveryPopoverViewController.h"

#define BATTERY_PERCENTAGE_SEGMENT 3
@interface ViewController ()

@end

@implementation ViewController
{
    
    IBOutlet UIButton *ConnectButton;
    DiscoveryPopoverViewController *mDiscoveredTable;
    UIPopoverController * mPopoverController;
}

////////////////////////////////////////////////////////////////////////////////
// Function:showPopover
// Notes: registers for discovery related callbacks and sets up the window to show discovery
// status and results.
- (IBAction)showPopover:(UIView *)sender
{
    if(mDiscoveredTable == nil)
    {
        mDiscoveredTable = [[DiscoveryPopoverViewController alloc] init];
    }
    
    //allocates and sizes the window.
    if(!mPopoverController)
    {
        mPopoverController =  [[UIPopoverController alloc] initWithContentViewController:mDiscoveredTable];
        mPopoverController.popoverContentSize = CGSizeMake(280., 320.);
        mPopoverController.delegate = self;
    }
    
    // initiates discovery
    [[WacomManager getManager] startDeviceDiscovery];
    
    // shows the discovery popover.
    [mPopoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}


////////////////////////////////////////////////////////////////////////////////
// Function: viewDidLoad
// Notes: does basic setup of the demo app main screen
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[WacomManager getManager] registerForNotifications:self];
    
    [_toolBar setTitle:@"" forSegmentAtIndex:BATTERY_PERCENTAGE_SEGMENT];
    [_versionLabel setText:[[WacomManager getManager] getSDKVersion]];
    [[TouchManager GetTouchManager] setHandedness:eh_Right];
    [[TouchManager GetTouchManager] setTouchRejectionEnabled:NO];
    
    // sample pdf image
    NSString* imagePath = [ [ NSBundle mainBundle] pathForResource:@"000" ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    CGRect frame = imageView.frame;
    float imgFactor = frame.size.height / frame.size.width;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width - 40;
    frame.size.height = frame.size.width * imgFactor;
    imageView.frame = frame;
    _contentView = [[UIView alloc] init];
    _contentView.frame = frame;
    _scrollView.contentSize = _contentView.frame.size;
    
    _dV = [[DrawingView alloc] initWithFrame:frame];
    _dV.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_dV];
    [_scrollView sendSubviewToBack:_dV];

    [_scrollView addSubview:imageView ];
    [_scrollView sendSubviewToBack:imageView ];
    
    [_scrollView addSubview:_contentView ];
    [_scrollView sendSubviewToBack:_contentView ];
    
    for (UIGestureRecognizer *gestureRecognizer in _scrollView.gestureRecognizers) {
        if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
            panGR.minimumNumberOfTouches = 2;
            panGR.maximumNumberOfTouches = 2;
            panGR.cancelsTouchesInView = YES;
        }
        else
        {
            gestureRecognizer.delaysTouchesBegan = NO;
        }
    }
    //[[TouchManager GetTouchManager] setTimingOffset:300];
    //NSLog(@"%d",[[TouchManager GetTouchManager] timingOffset]);
}


////////////////////////////////////////////////////////////////////////////////
// Function: didReceiveMemoryWarning
// Notes: calls the super did receive memory warning and does basically nothing else.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



////////////////////////////////////////////////////////////////////////////////
// Function: toggleTouchRejection
// Notes: enables or disables touch rejection based on the previous state.
-(void) toggleTouchRejection
{
    NSString *message   = nil;
    NSString *title     = @"Touch Rejection";
    
    if([TouchManager GetTouchManager].touchRejectionEnabled == YES)
    {
        [[TouchManager GetTouchManager] setTouchRejectionEnabled: NO];
    }
    else
    {
        [[TouchManager GetTouchManager] setTouchRejectionEnabled: YES];
    }
    
    if([TouchManager GetTouchManager].touchRejectionEnabled == YES)
        message = @"You have turned ON touch rejection.";
    else
        message = @"You have turned OFF touch rejection.";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

////////////////////////////////////////////////////////////////////////////////
// Function: toggleTouchRejection
// Notes: enables or disables touch rejection based on the previous state.
-(IBAction)showPrivacyMessage:(UIButton *)sender
{
    NSString *message   = nil;
    NSString *title     = @"Privacy Info";
    
    message = @"This app does not collect information about its users. Only previous pairings are stored and they are stored locally. This app does not phone home.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}



////////////////////////////////////////////////////////////////////////////////
// Function: SegControlPerformAction
// Notes: controls pairing, toggles touch rejection, and erases the screen when the
// segmented control is clicked.
- (IBAction)SegControlPerformAction:(UISegmentedControl *)sender
{
    
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            // Initiates the pairing mode popover.
            [self showPopover:sender];
            break;
        case 1:
            // Toggles touch rejection on and off.
            [self toggleTouchRejection];
            break;
        case 2:
            // Clears the screen
            [_dV erase];
            break;
        case 3:
            [_dV undoLastStroke];
        default:
            break;
    };
    
}




////////////////////////////////////////////////////////////////////////////////
// Function: SegControlSetHandedness
// Notes: controls pairing, toggles touch rejection, and erases the screen when the
// segmented control is clicked.
- (IBAction)SegControlSetHandedness:(UISegmentedControl *)sender
{
    
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            // Initiates the pairing mode popover.
            [[TouchManager GetTouchManager] setHandedness:eh_Left];
            break;
        case 1:
            // Clears the screen
            [[TouchManager GetTouchManager] setHandedness:eh_Right];
            break;
        default:
            break;
    };
    
}


////////////////////////////////////////////////////////////////////////////////
// Function: ToggleHoverOn
// Notes: When holding the button, the pen drawing will be recognized as hovering.
- (IBAction)ToggleHoverOn:(UIButton *)sender
{
    [_dV  setHover:true];
}

////////////////////////////////////////////////////////////////////////////////
// Function: ToggleHoverOff
// Notes: When releasing the button, the pen drawing will be recognized as drawing.
- (IBAction)ToggleHoverOff:(UIButton *)sender
{
    [_dV setHover:false];
}

- (IBAction)FlipHoverMode:(id)sender
{
    [_dV  flipHover];
}


// For prototype debugging
- (IBAction) FlipPressureMode:(UIButton *)sender
{
    NSString *message   = nil;
    NSString *title     = @"Pressure sensitive";
    if([_dV getPressureMode])
        message = @"You have turned OFF Pressure Sensitive.";
    else
        message = @"You have turned ON Pressure Sensitive.";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];

    [_dV  flipPressureMode];
}

////////////////////////////////////////////////////////////////////////////////
// Function:deviceDiscovered
// Notes: just add the device to the discovered table. demonstrates signal strength
-(void) deviceDiscovered:(WacomDevice *)device
{
    //	NSLog(@"signal strength %i", [device getSignalStrength]);
    [mDiscoveredTable addDevice:device];
}



////////////////////////////////////////////////////////////////////////////////
// Function:deviceConnected
// Notes: update the device table then dismiss the popover.
-(void) deviceConnected:(WacomDevice *)device
{
    [mDiscoveredTable updateDevices:device];
}



////////////////////////////////////////////////////////////////////////////////
// Function:deviceDisconnected
// Notes: remove the device then dismiss the popover
-(void)deviceDisconnected:(WacomDevice *)device
{
    [mDiscoveredTable removeDevice:device];
    [_toolBar setTitle:@"" forSegmentAtIndex:BATTERY_PERCENTAGE_SEGMENT];
    
}



////////////////////////////////////////////////////////////////////////////////
// Function: discoveryStatePoweredOff
// Notes: if the power is off, it pops a warning dialog.
-(void)discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}



////////////////////////////////////////////////////////////////////////////////
// Function:stylusEvent
// Notes: update the battery status segment in the tool bar.
-(void)stylusEvent:(WacomStylusEvent *)stylusEvent
{
    switch ([stylusEvent getType])
    {
        case eStylusEventType_BatteryLevelChanged:
            [_toolBar setTitle:[NSString stringWithFormat:@"%lu%%", [stylusEvent getBatteryLevel] ] forSegmentAtIndex:BATTERY_PERCENTAGE_SEGMENT];
        default:
            break;
    }
}


@end
