//
//  Media.h
//  Blocstagram
//
//  Created by Peter Scheyer on 2/18/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;

@interface Media : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

- (instancetype) initWithDictionary: (NSDictionary *)mediaDictionary;



@end
