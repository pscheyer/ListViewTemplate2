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
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
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

    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
//        _item = [DataSource sharedInstance].mediaItems;
        //
//                NSMutableArray *work_array = [[NSMutableArray alloc] initWithArray:[self items]];
//                [work_array removeObjectAtIndex:indexPath.row];
//                _item= work_array;
                //update View
        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView reloadData];
        
    }
    
    NSLog(@"Deleted row.");
    
}

-(void)removeObjectFromImagesAtIndex:(NSUInteger)index {
    
}

-(NSArray *) items {
    return _item;
}

#pragma mark Key-Value Observations

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        
        //we know mediaItems changed, lets check the change
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            //someone set a brand new images array.
            [self.tableView reloadData];
            
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            //we have an incremental change- inserted, deleted, replaced images
            
            //get a list of the indices that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            //convert NSIndexSet to NSArray of NSIndexPaths (used in table view animation methods)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            //call 'beginUpdates' to tell the table view we're going to make changes
            [self.tableView beginUpdates];
            
            //tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            //tell the table view that we're done telling it about changes, complete the animation.
            
            [self.tableView endUpdates];
        }
        
    }
}


- (void) dealloc
{
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
}


@end
