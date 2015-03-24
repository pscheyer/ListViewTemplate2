//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Peter Scheyer on 3/15/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaFullScreenViewController;

@protocol MediaFullScreenViewControllerDelegate <NSObject>

- (void) cell:(MediaFullScreenViewController *)cell didPressShareButtonOnImageView:(UIImageView *)imageView;

@end

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, strong) Media *media;


- (instancetype) initWithMedia:(Media *)media;

- (void) centerScrollView;

- (void) recalculateZoomScale;

@end
