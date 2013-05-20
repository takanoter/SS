//
//  KeyLineManager.m
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "KeyLineManager.h"
#import "SquareViewController.h"
#import "SquareAppDelegate.h"

@implementation KeyLine
- (KeyLine*)initWithView:(UIView*)theView ofID:(int)_id ofType:(int)_keyType{
    
    if (_keyType == 2) {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y, 32.0, 8.0)];
        image.image = [UIImage imageNamed:@"KEYA0.png"];
    } else {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y, 32.0, 8.0)];
        image.image = [UIImage imageNamed:@"KEYB0.png"];
    }
    image.tag = _keyType*1000024+_id;
    self->tagID = _keyType*1000024+_id;
    self->gView = theView;
    self->isShort = true;
    self->keyType = _keyType;

    [self reset];
    [theView addSubview:image];
    
    return self;
}
- (void) reset {
    dx=BASE_LOC_X, dy=BASE_DISAPPEAR_LOC_Y;
    image.center = CGPointMake(dx, dy);
    isShow=false;
}
- (int)move:(float)speed {
    self->dy = self->dy+speed;
    image.center = CGPointMake(self->dx, self->dy);
//  image.center = CGPointMake(self->dx, self->dy);  //貌似这里写两行.center能出两个图
    if (self->dy>BASE_LOC_ENDFRONT_Y) {
        [self reset];
        return self->channel;
    }
    return -1;
}
- (void)showOnChannel:(int)_channel {
    self->dx=BASE_LOC_X + _channel*32, self->dy=BASE_START_LOC_Y;
    self->isShow=true;
    self->channel = _channel;
    self->image.center = CGPointMake(dx, dy);
}
@end

@implementation ChannelMgr
- (ChannelMgr*)initWithView:(UIView*)theView
{
    for (int i=0; i<CHANNEL_COUNT; i++) {
        for (int j=0; j<MAX_IMAGE_STAGE; j++) {
            NSString *fileName = [NSString stringWithFormat:@"Note_Click1_2.ojt%d.png", j];
            self->bloom[i][j] = [[UIImageView alloc]initWithFrame:CGRectMake(BASE_LOC_X+i*32, BASE_DISAPPEAR_LOC_Y, 82.0, 58.0)];
            self->bloom[i][j].image = [UIImage imageNamed:fileName];
            self->bloom[i][j].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
            self->bloom[i][j].tag = 5000+i*MAX_IMAGE_STAGE + j;
            //self->bloom[i][j].backgroundColor = [UIColor blackColor];
            [theView addSubview:bloom[i][j]];
        }
        
        self->touch[i] = [[UIImageView alloc]initWithFrame:CGRectMake(BASE_LOC_X+i*32,
                                                                      BASE_DISAPPEAR_LOC_Y, 32.0, 256.0)];
        self->touch[i].image = [UIImage imageNamed:@"KEYA_show.png"];
        self->touch[i].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
        self->touch[i].tag = 50000 + i;
        self->touch[i].alpha = 0.7;
        [theView addSubview:touch[i]];
        
        self->stage[i]=-1;
    }
    return self;
}
- (void)touch:(int)channel
{
    if ((self->stage[channel]!=-1)
        && (self->stage[channel]!=MAX_IMAGE_STAGE)) {
        self->bloom[channel][stage[channel]].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
    }
    self->stage[channel]=0;
}

- (void)animate
{
    for (int i=0; i<CHANNEL_COUNT; i++) {
        if (self->stage[i]==-1) continue;
        if (self->stage[i]==0) {
            self->bloom[i][0].center = CGPointMake(BASE_LOC_X+i*32, BASE_LOC_ENDFRONT_Y);
            self->touch[i].center = CGPointMake(BASE_LOC_X+i*32, BASE_LOC_ENDFRONT_Y-128);
        } else {
            self->bloom[i][self->stage[i]-1].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
            self->bloom[i][self->stage[i]].center = CGPointMake(BASE_LOC_X+i*32, BASE_LOC_ENDFRONT_Y);
            if (self->stage[i]==3) {
                touch[i].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
            }
        }
        
        if ((++self->stage[i])==MAX_IMAGE_STAGE) {
            self->bloom[i][MAX_IMAGE_STAGE-1].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
            self->stage[i]=-1;
        }
    }
}

@end

@implementation KeyLineManager
- (KeyLineManager*) initWithView:(UIView*)theView {
    for (int i=0; i<END_FRONT_COUNT; i++) {
        NSString *fileName = [NSString stringWithFormat:@"EndFront_%d.png", i]; //190*20p (retina?)
        self->endFront[i] = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                         BASE_LOC_X, BASE_DISAPPEAR_LOC_Y, 202.0, 58.0)];
        self->endFront[i].image = [UIImage imageNamed:fileName];
        self->endFront[i].tag = 20000+i;
        [theView addSubview:endFront[i]];
    }
    curEndFront=0;
    
    for (int i=0; i<KEY_SLOT_COUNT; i++) {
        keyA[i]= [[KeyLine alloc] initWithView:theView ofID:i ofType:1];
        keyB[i]= [[KeyLine alloc] initWithView:theView ofID:i ofType:2];
    }
    speed = 7;
    channelMgr = [[ChannelMgr alloc] initWithView:theView];

    return self;
}

- (bool) newCommingOnChannel:(int)channel {
    if ((channel==1) || (channel==4)) {
        for (int i=0; i<KEY_SLOT_COUNT; i++) {
            if (!keyA[i]->isShow) {
                [keyA[i] showOnChannel:channel];
                return true;
            }
        }
        return false;
    } else {
        for (int i=0; i<KEY_SLOT_COUNT; i++) {
            if (!keyB[i]->isShow) {
                [keyB[i] showOnChannel:channel];
                return true;
            }
        }
        return false;
    }
    return false;
}

- (void)animate {
    for (int i=0; i<END_FRONT_COUNT; i++) {
        endFront[i].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
    }
    endFront[(curEndFront++)%END_FRONT_COUNT].center = CGPointMake(BASE_LOC_X+85, BASE_LOC_ENDFRONT_Y);

    //核心驱动
    for (int i=0; i<KEY_SLOT_COUNT; i++) {
        if (!keyA[i]->isShow) continue;
        int channel = [keyA[i] move:speed];
        if (channel != -1) {
            [channelMgr touch:channel];
        }
    }
    for (int i=0; i<KEY_SLOT_COUNT; i++) {
        if (!keyB[i]->isShow) continue;
        int channel = [keyB[i] move:speed];
        if (channel != -1) {
            [channelMgr touch:channel];
        }
    }
    [channelMgr animate];
    return;
}
@end
