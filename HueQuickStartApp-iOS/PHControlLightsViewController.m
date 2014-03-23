/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import "PHAppDelegate.h"

#import <HueSDK_iOS/HueSDK.h>
#import "SEManager.h"
#import <CoreMotion/CoreMotion.h>
#define MAX_HUE 65535

@interface PHControlLightsViewController()
{
    NSArray *hueArray;
    NSArray *huebrightArray;
    NSNumber *curbright;
    NSNumber     *curColor;
    CMMotionManager *motionManager;
}

@property (nonatomic,weak) IBOutlet UILabel *bridgeMacLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeLastHeartbeatLabel;
@property (nonatomic,weak) IBOutlet UIButton *randomLightsButton;

@end


@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Find bridge" style:UIBarButtonItemStylePlain target:self action:@selector(findNewBridgeButtonAction)];
    
    self.navigationItem.title = @"QuickStart";
    
    [self noLocalConnection];
    
    // Red, Blue, Green, Purple
    hueArray = @[[NSNumber numberWithInt:0], [NSNumber numberWithInt:43690], [NSNumber numberWithInt:24845], [NSNumber numberWithInt:54613]];
    huebrightArray = @[[NSNumber numberWithInt:50], [NSNumber numberWithInt:100] ,[NSNumber numberWithInt:150]];
    curbright = huebrightArray[0];
    curColor = hueArray[1];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // You have to declair CMMotionManager *motionManager; somewhere else
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 0.1;
    
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    
    [motionManager startAccelerometerUpdatesToQueue:currentQueue
                                        withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                            CMAcceleration acceleration = accelerometerData.acceleration;
                                            double accv = acceleration.x*acceleration.x + acceleration.y *acceleration.y + acceleration.z*acceleration.z;
                                            accv = sqrt(accv);
                                            if (accv > 1.1 && accv <= 1.8) {
                                                [[SEManager sharedManager] playSound:@"SlowSabr.wav"];
                                                curbright = huebrightArray[0];
                                                [self ColoursOfConnectLights];
                                            }
                                            if (accv > 1.8 && accv <= 2.5) {
                                                [[SEManager sharedManager] playSound:@"Swing02.wav"];
                                                 curbright = huebrightArray[1];
                                                [self ColoursOfConnectLights];
                                            }
                                            else if (accv > 2.5){
                                                [[SEManager sharedManager] playSound:@"LSwall02.WAV"];
                                                [self black_Lights];
                                                 curbright = huebrightArray[2];
                                                [self ColoursOfConnectLights];
                                                
                                            }
                                            NSLog(@"%f",accv);
                                                                                      NSLog(@"%f, %f, %f", acceleration.x, acceleration.y, acceleration.z);
                                        }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [motionManager stopAccelerometerUpdates];
    [super viewWillDisappear:animated];
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
// シェイク開始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake)  {
        NSLog(@"Motion began");
       
        //[[SEManager sharedManager] playSound:@"Swing02.wav"];
        // [self ColoursOfConnectLights];
    }
}

// シェイク完了
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        NSLog(@"Motion ended");
        
    }
}


- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.text = @"Not connected";
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.text = @"Not connected";
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeMacLabel.text = @"Not connected";
    [self.bridgeMacLabel setEnabled:NO];
    
    [self.randomLightsButton setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.text = cache.bridgeConfiguration.ipaddress;
        
        // Set the mac adress of the bridge
        self.bridgeMacLabel.text = cache.bridgeConfiguration.mac;
        
        // Check if we are connected to the bridge right now
        if (UIAppDelegate.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            //comm
            [self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.text = @"Waiting...";
            [self.randomLightsButton setEnabled:NO];
        }
    }
}

- (void)black_Lights
{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:curColor];
        [lightState setBrightness:[NSNumber numberWithInt:0]];
        [lightState setSaturation:[NSNumber numberWithInt:0]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }

}

- (void)ColoursOfConnectLights
{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        srand((unsigned)time(NULL));
        
        int n = random() % [hueArray count];
        
        [lightState setHue:curColor];
        [lightState setBrightness:curbright];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
    
}

- (IBAction)selectOtherBridge:(id)sender{
    [UIAppDelegate searchForBridgeLocal];
}

- (IBAction)segmentChange:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: //blue
            curColor = hueArray[0];
            break;
        case 1: //red
            curColor = hueArray[1];
            break;
        case 2: //green
            curColor = hueArray[2];
            break;
        case 3: //purple
            curColor = hueArray[3];
            break;
        default:
             curColor = hueArray[3];
            break;
    }
}

- (IBAction)start_light:(id)sender
{
    [self black_Lights];
    [[SEManager sharedManager] playSound:@"SaberOn.wav"];
    [self ColoursOfConnectLights];
}

- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}

- (void)findNewBridgeButtonAction{
    [UIAppDelegate searchForBridgeLocal];
}

@end
