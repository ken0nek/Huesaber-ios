//
//  AVFound_rapper.m
//  Hue_saver
//
//  Created by オオタ イサオ on 2014/03/23.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "AVFound_rapper.h"

@implementation AVFound_rapper

-(id)initWithFile:(NSString *)soudFileName
{
    id ret = [super init];
    if(ret!=nil)
    {
        audioPlayer = [self getAVAudioPlayer:soudFileName];
        [audioPlayer prepareToPlay];
    }
    
    return ret;
}

- (void)sound_ON
{
   
    [audioPlayer play];
}

- (id)getAVAudioPlayer:(NSString*)soudFileName;
{
    AVAudioPlayer *player=nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:soudFileName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    if(url){
        NSError *err = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    }
    
    return player;
    
}

@end
