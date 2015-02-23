//
//  ImagesTabViewController.m
//  Blocstagram
//
//  Created by Peter Scheyer on 2/15/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"

@implementation ImagesTableViewController

#pragma mark - Table view data source


- (id)initWithStyle:(UITableViewStyle)style
{
    
    NSMutableArray *work_array = [[NSMutableArray alloc] initWithArray:[DataSource sharedInstance].mediaItems];
    _item = work_array;
    self = [super initWithStyle:style];
    if(self) {
        //custom initialization
        //        self.images = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    for (int i = 1; i <=10; i++) {
    //        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
    //        UIImage *image = [UIImage imageNamed:imageName];
    //        if (image) {
    //            [self.images addObject:image];
    //        }
    //    }
    
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return self.images.count;
    return [self items].count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Original build w/o MediaTableViewCell- just displays images, requires other changes in tableView return and elsewhere.
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
//    
//    //configure the cell
//    static NSInteger imageViewTag = 1234;
//    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:imageViewTag];
//    
//    if (!imageView) {
//        //this is a new cell, doesn't have an imageview yet
//        imageView = [[UIImageView alloc] init];
//        imageView.contentMode = UIViewContentModeScaleToFill;
//        
//        imageView.frame = cell.contentView.bounds;
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        
//        imageView.tag = imageViewTag;
//        [cell.contentView addSubview:imageView];
//    }
//    
////    UIImage *image = self.images[indexPath.row];
////    imageView.image = image;
//    Media *item = [self items][indexPath.row];
//    imageView.image = item.image;
    
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.mediaItem = [self items][indexPath.row];
    
    return cell;
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UIImage *image = self.images[indexPath.row];
    Media *item = [self items][indexPath.row];
    
    
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}



-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //return YES- to be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //handles delete action, may need revision of not only delete but has other options- like share or something.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *work_array = [[NSMutableArray alloc] initWithArray:[self items]];
        [work_array removeObjectAtIndex:indexPath.row];
        _item= work_array;
        //update View

//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        
    }
    
    NSLog(@"Deleted row.");

}

-(void)removeObjectFromImagesAtIndex:(NSUInteger)index {
    
}

-(NSArray *) items {
    return _item;
}


@end
