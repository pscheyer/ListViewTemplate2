//
//  ImagesTabViewController.m
//  Blocstagram
//
//  Created by Peter Scheyer on 2/15/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "ImagesTableViewController.h"

@implementation ImagesTableViewController

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    //configure the cell
    static NSInteger imageViewTag = 1234;
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        //this is a new cell, doesn't have an imageview yet
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        imageView.frame = cell.contentView.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
    }
    
    UIImage *image = self.images[indexPath.row];
    imageView.image = image;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.images[indexPath.row];
    return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self) {
        //custom initialization
        self.images = [NSMutableArray array];
    }
    return self;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //return YES- to be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //handles delete action, may need revision of not only delete but has other options- like share or something.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *work_array = [NSMutableArray arrayWithArray:self.images];
        [work_array removeObjectAtIndex:indexPath.row];
        self.images = [NSMutableArray arrayWithArray:work_array];
//        [[NSUserDefaults standardUserDefaults] setObject:self.images forKey:<#(NSString *)#>]
        //update View
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    NSLog(@"Deleted row.");
    [self.tableView reloadData];
}

-(void)removeObjectFromImagesAtIndex:(NSUInteger)index {
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 1; i <=10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [self.images addObject:image];
        }
    }
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
    
}

@end
