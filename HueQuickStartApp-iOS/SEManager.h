//
//  SEManager.h
//  Hue_saver
//
//  Created by オオタ イサオ on 2014/03/23.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEManager : NSObject
{
      NSMutableArray *soundArray;
}

@property(nonatomic) float soundVolume;

+ (SEManager *)sharedManager;
- (void)playSound:(NSString *)soundName;

@end
