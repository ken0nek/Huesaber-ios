/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import <UIKit/UIKit.h>

@interface PHControlLightsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

- (IBAction)segmentChange:(UISegmentedControl *)sender;

@end
