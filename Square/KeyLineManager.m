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

- (KeyLine*)initWithView:(UIView*)theView onChannel:(int)_channel ofKey:(int)keyID {
    int tag= _channel*KEY_SLOT_COUNT+keyID;
    if (1==_channel || 4==_channel) {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(BASE_LOC_X+_channel*32, BASE_DISAPPEAR_LOC_Y, 32.0, 8.0)];
        image.image = [UIImage imageNamed:@"KEYB0.png"];
    } else {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(BASE_LOC_X+_channel*32, BASE_DISAPPEAR_LOC_Y, 32.0, 8.0)];
        image.image = [UIImage imageNamed:@"KEYA0.png"];
    }
    image.tag = tag;
    self->tagID = tag;
    self->gView = theView;
    self->channel = _channel;
    self->isShort = true;
    self->stage = 0;
    for (int i=0; i<MAX_IMAGE_STAGE; i++) {
        self->bloom[i] = NULL;
    }
    
    for (int i=0; i<12; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Note_Click1_2.ojt%d.png", i];
        self->bloom[i] = [[UIImageView alloc]initWithFrame:CGRectMake(BASE_LOC_X+_channel*32, BASE_DISAPPEAR_LOC_Y, 82.0, 58.0)];
        self->bloom[i].image = [UIImage imageNamed:fileName];
        self->bloom[i].tag = tag*2000+i;
        self->bloom[i].backgroundColor = [UIColor blackColor] ;
        [theView addSubview:bloom[i]];
    }
    self->touch = [[UIImageView alloc]initWithFrame:CGRectMake(BASE_LOC_X+_channel*32,
            BASE_DISAPPEAR_LOC_Y, 32.0, 256.0)];
    self->touch.image = [UIImage imageNamed:@"KEYA_show.png"];
    self->touch.tag = tag*2000+151;
    
    [self reset];
    [theView addSubview:image];
    [theView addSubview:touch];
    
    return self;
}
- (void) reset {
    dx=BASE_LOC_X + channel*32, dy=BASE_DISAPPEAR_LOC_Y;
    image.center = CGPointMake(dx, dy);
    touch.center = CGPointMake(dx, dy);
    for (int i=0; i<12; i++) {
        bloom[i].center = CGPointMake(dx, dy);
    }
    stage=0;
    isShow=false;
}
- (void)move:(float)speed {
    if (stage==0) {
        self->dy = self->dy+speed;
        image.center = CGPointMake(self->dx, self->dy);
//        image.center = CGPointMake(self->dx, self->dy);  //貌似这里写两行.center能出两个图
    }if (self->dy>BASE_LOC_ENDFRONT_Y) {
        if (stage==0) {
            image.center = CGPointMake(BASE_LOC_X+channel*32, BASE_DISAPPEAR_LOC_Y);
            bloom[0].center = CGPointMake(self->dx, self->dy);
            touch.center = CGPointMake(self->dx, self->dy-128);
        } else if (stage<12) {
            if (stage==2) touch.center = CGPointMake(BASE_LOC_X+channel*32, BASE_DISAPPEAR_LOC_Y);
            bloom[stage-1].center = CGPointMake(BASE_LOC_X+channel*32, BASE_DISAPPEAR_LOC_Y);
            bloom[stage].center = CGPointMake(self->dx, self->dy);
        } else { //stage==12
            [self reset];
            return;
        }
        stage++;
    }
}
- (void)show {
    dx=BASE_LOC_X + channel*32, dy=BASE_START_LOC_Y;
    isShow=true;
    image.center = CGPointMake(dx, dy);
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
    
    for (int i=0; i<6; i++) {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            keys[i][j]= [[KeyLine alloc] initWithView:theView onChannel:i ofKey:j];
        }
    }
    speed = 7;
    
    return self;
}
//- (bool)newCommingOnChannel:(int)channel;

- (bool) newCommingOnChannel:(int)channel {
    int iid = [self getActorFromChannel:channel];
    if (100 == iid) {
        NSLog(@"failed!!!!");
        return false;
    }
    [keys[channel][iid] show ];
    return true;
}

- (void)animate {
    for (int i=0; i<END_FRONT_COUNT; i++) {
        endFront[i].center = CGPointMake(BASE_LOC_X, BASE_DISAPPEAR_LOC_Y);
    }
    endFront[(curEndFront++)%END_FRONT_COUNT].center = CGPointMake(BASE_LOC_X+85, BASE_LOC_ENDFRONT_Y);

    //核心驱动
    for (int i=0; i<6; i++) {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            if (!keys[i][j]->isShow) continue;
            [keys[i][j] move:speed];
        }
    }
    
    return;
}

- (int)getActorFromChannel:(int)channel {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            if (!(keys[channel][j]->isShow)) return j;
        }
    return 100;
}
@end
