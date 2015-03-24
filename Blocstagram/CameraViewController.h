//
//  CameraViewController.h
//  Blocstagram
//
//  Created by Peter Scheyer on 3/23/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//
#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;

@end
