//
//  AVFound_rapper.h
//  Hue_saver
//
//  Created by オオタ イサオ on 2014/03/23.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVFound_rapper : NSObject
{
    AVAudioPlayer *audioPlayer;
}

-(id)initWithFile:(NSString *)soudFileName;
- (void)sound_ON;
@end
