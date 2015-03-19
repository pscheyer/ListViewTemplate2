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
#import "MediaFullScreenViewController.h"
#import "MediaFullScreenAnimator.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>


@property (nonatomic, weak) UIImageView *lastTappedImageView;


@end

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    if ([DataSource sharedInstance].mediaItems != nil) {
        [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];
        NSLog(@"Cache found, checking for new images...");
    }
    
    
}

- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
        NSLog(@"Pull-to-refresh triggered...");
    }];
}

- (void) infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
//    NSLog(@"Scroll...");
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1) {
        //the very last cell is on-screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self infiniteScrollIfNecessary];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return self.images.count;
    return [self items].count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self;
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

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    if(item.image) {
        return 350;
    } else {
        return 150;
    }
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
    return [[DataSource sharedInstance] mediaItems];
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


#pragma mark - MediaTableViewCellDelegate

- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    
    
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    fullScreenVC.transitioningDelegate = self;
    fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void) cell:(MediaTableViewCell *)cell didTwoFingerTapImageView:(UIImageView *)imageView {

    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}




//
//    
//    

//}
@end
