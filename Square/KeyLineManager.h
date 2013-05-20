//
//  KeyLineManager.h
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import "SquareAppDelegate.h"
#define MAX_IMAGE_STAGE 12
#define BASE_LOC_X 400
#define BASE_START_LOC_Y 65
#define BASE_DISAPPEAR_LOC_Y -100
#define BASE_LOC_ENDFRONT_Y 518
@interface KeyLine:NSObject {
    UIImageView *image;
    //UIImageView *bloom[MAX_IMAGE_STAGE];  //TODO:FIXME:属于channel，not key
    //UIImageView *touch;
    @public bool isShow;
    float dx,dy;
    int tagID;
    int channel;
    UIView* gView;
    bool isShort;
    int keyType;
    //int stage;
}
- (KeyLine*)initWithView:(UIView*)theView ofID:(int)_id ofType:(int)keyType;
- (void)reset;
- (int)move:(float)speed;
- (void)showOnChannel:(int)_channel;
@end

#define CHANNEL_COUNT 6
@interface ChannelMgr:NSObject {
    UIImageView *bloom[CHANNEL_COUNT][MAX_IMAGE_STAGE];  //TODO:PNG原始图片不透明?
    UIImageView *touch[CHANNEL_COUNT];
    int stage[CHANNEL_COUNT];
}
- (ChannelMgr*)initWithView:(UIView*)theView;
- (void)touch:(int)channel;
- (void)animate;

@end

#define KEY_SLOT_COUNT 125
#define END_FRONT_COUNT 2
@interface KeyLineManager:NSObject {
    //in motion
    float speed;
    
    //key池
    KeyLine* keyA[KEY_SLOT_COUNT];
    KeyLine* keyB[KEY_SLOT_COUNT];
    int keyAPtr, keyBPtr;
    
    //底部红色闪耀动画
    UIImageView *endFront[END_FRONT_COUNT];
    int curEndFront;
    
    //on touch的bloom动画
    ChannelMgr* channelMgr;
}
- (KeyLineManager*) initWithView:(UIView*)theView;
- (bool) newCommingOnChannel:(int)channel;
- (void)animate ;


@end



