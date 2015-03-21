//
//  LikeButton.h
//  Blocstagram
//
//  Created by Peter Scheyer on 3/20/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked           =0,
    LikeStateLiking             =1,
    LikeStateLiked              =2,
    LikeStateUnliking           =3
};

@interface LikeButton : UIButton

//the current state of the like button. Setting to LikeButtonNotLiked or Liked will display a heart or empty heart respectively. liking/unliking will display an activity indicator and disable button taps 'till set to liked or not liked.

@property (nonatomic, assign) LikeState likeButtonState;

@end
