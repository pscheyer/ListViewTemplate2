//
//  DataSource.m
//  Blocstagram
//
//  Created by Peter Scheyer on 2/18/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing; //like Sprite!
@property (nonatomic, assign) BOOL isLoadingOlderItems; //like... our thing that was like sprite!

@end

@implementation DataSource

+ (NSString *) instagramClientID {
    return @"f9d8cced4fb94a89801ee4bf91f3682d";
}

+(instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init{
    self = [super init];
    
    if (self) {
//        [self addRandomData];
        [self registerForAccessTokenNotification];
    }
    
    return self;
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        //got a token, populate the initial data
        [self populateDataWithParameters:nil];
    }];
}

#pragma mark Generative Code- commented out

//- (void) addRandomData {
//    NSMutableArray *randomMediaItem = [NSMutableArray array];
//    
//    for(int i = 1; i <= 10; i++) {
//        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
//        UIImage *image = [UIImage imageNamed:imageName];
//        
//        if(image) {
//            Media *media = [[Media alloc] init];
//            media.user = [self randomUser];
//            media.image = image;
//            
//            NSUInteger commentCount = arc4random_uniform(10);
//            NSMutableArray *randomComments = [NSMutableArray array];
//            
//            for (int i = 0; i <= commentCount; i++) {
//                Comment *randomComment = [self randomComment];
//                [randomComments addObject:randomComment];
//            }
//            
//            media.comments = randomComments;
//            
//            [randomMediaItem addObject:media];
//        }
//    }
//    
//    
//    self.mediaItems = randomMediaItem;
//}
//
//-(User *) randomUser {
//    User *user = [[User alloc] init];
//    
//    user.userName = [self randomStringOfLength:arc4random_uniform(10)];
//    
//    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
//    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
//    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
//    
//    return user;
//}
//
//-(Comment *) randomComment {
//    Comment *comment = [[Comment alloc] init];
//    
//    comment.from = [self randomUser];
//    
//    NSUInteger wordCount = arc4random_uniform(20);
//    
//    NSMutableString *randomSentence = [[NSMutableString alloc] init];
//    
//    for (int i = 0; i <= wordCount; i++) {
//        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
//        [randomSentence appendFormat:@"%@ ", randomWord];
//    }
//    
//    comment.text = randomSentence;
//    
//    return comment;
//}
//
//- (NSString *) randomSentenceWithMaximumNumberOfWords:(NSUInteger) len {
//    NSString *sentence = [[NSString alloc] init];
//    
//    NSUInteger wordCount = arc4random_uniform(20);
//    
//    NSMutableString *randomSentence = [[NSMutableString alloc] init];
//    
//    for (int i = 0; i <= wordCount; i++) {
//        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
//        [randomSentence appendFormat:@"%@ ", randomWord];
//    }
//    
//    sentence = randomSentence;
//    
//    return sentence;
//}
//
//- (NSString *) randomStringOfLength:(NSUInteger) len {
//    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
//    
//    NSMutableString *s = [NSMutableString string];
//    for (NSUInteger i = 0U; i < len; i++) {
//        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
//        unichar c = [alphabet characterAtIndex:r];
//        [s appendFormat:@"%C", c];
//    }
//    return [NSString stringWithString:s];
//}

//- (void) removeDataAtRow:(NSUInteger) row {
//    NSMutableArray *arrayWithoutMediaItem = [[NSMutableArray alloc] initWithArray:_mediaItems];
//    [arrayWithoutMediaItem removeObjectAtIndex:row];
//    
//    self.mediaItems = arrayWithoutMediaItem;
//}


#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
//    [_mediaItems removeObject:item];
}

#pragma mark pull-to-refresh and inifinite scroll

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isRefreshing == NO) { //YOU HAVE YOUR SPRITE ALREADY, SIR
        self.isRefreshing = YES;
        //Generative Code calls
//        Media *media = [[Media alloc] init];
//        media.user = [self randomUser];
//        media.image = [UIImage imageNamed:@"10.jpg"];
//        media.caption = [self randomSentenceWithMaximumNumberOfWords:7];
//        
//        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
//        [mutableArrayWithKVO insertObject:media atIndex:0];
        
        //adding images here
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO) { //YOU HAVE YOUR THING SIMILAR TO OUR THING LIKE SPRITE ALREADY SIR DON'T PUSH ME
        self.isLoadingOlderItems = YES;
        
        //generative code calls
//        Media *media = [[Media alloc] init];
//        media.user = [self randomUser];
//        media.image = [UIImage imageNamed:@"1.jpg"];
//        media.caption = [self randomSentenceWithMaximumNumberOfWords:7];
//        
//        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
//        [mutableArrayWithKVO addObject:media];
//
        
        //adding images here
        
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void) populateDataWithParameters:(NSDictionary *)parameters {
    if (self.accessToken) {
        //only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //do the network request in the background, so the UI doesn't lock up.
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                //if dictionary contains {count:50}, append '&count=50' to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                NSError *jsonError;
                NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                
                if (feedDictionary) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //done networking, go back to main thread
                        [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                    });
                }
            }
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}



@end
