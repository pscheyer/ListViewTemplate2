//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Peter Scheyer on 2/22/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

+(CGFloat) heightForMediaItem: (Media *)mediaItem width:(CGFloat)width;

@end
