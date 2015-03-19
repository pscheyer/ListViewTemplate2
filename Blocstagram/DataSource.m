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
#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing; //like Sprite!
@property (nonatomic, assign) BOOL isLoadingOlderItems; //like... our thing that was like sprite!
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, assign) BOOL thereIsNoDataForParameters;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

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
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            [self populateDataWithParameters:nil completionHandler:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                    
                });
            });
        }
    }
    
    return self;
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        //got a token, populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}




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

#pragma mark pull-to-refresh and infinite scroll

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO;
    self.thereIsNoDataForParameters = [self checkDataForImages:self.mediaItems];
    
    if (self.isRefreshing == NO && self.thereIsNoDataForParameters == NO) { //YOU HAVE YOUR SPRITE ALREADY, SIR
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        
        
        NSDictionary *parameters = @{@"min_id": minID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) { //YOU HAVE YOUR THING SIMILAR TO OUR THING LIKE SPRITE ALREADY SIR DON'T PUSH ME
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};
        
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

-(BOOL)checkDataForImages:(NSArray *)data {
    if (data == nil) {
        NSLog(@"NoData in images table");
        return NO;
    } else {
        return YES;
    }
    
}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {

        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                         [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                         
                                         if (completionHandler) {
                                             completionHandler(nil);
                                         }
                                     }
                                 }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (completionHandler) {
                                         completionHandler(error);
                                     }
                                 }];
        
    }
}

#pragma mark Parser for JSON from Instagram

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            //this next line procs the error requested in the assignment if commented and pull to refresh is run twice.
//            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        //this was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
    }else if (parameters[@"max_id"]) {
        //this was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            //disable infinite scroll as there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        NSLog(@"infinite scroll loading");
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        
        
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    if (tmpMediaItems.count > 0) {
        //write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
    }
}

- (void) downloadImageForMediaItem:(Media *)mediaItem {
    if  (mediaItem.mediaURL && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;

        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if ([responseObject isKindOfClass:[UIImage class]]) {
                                         mediaItem.image = responseObject;
                                         mediaItem.downloadState = MediaDownloadStateHasImage;
                                         NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                         NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                         [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                     } else {
                                         mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                     }
                                 }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"Error downloading image: %@", error);
                                     
                                     
                                     mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                     
                                     if ([error.domain isEqualToString:NSURLErrorDomain]){
                                         //a networking problem has occurred
                                         if (error.code == NSURLErrorTimedOut ||
                                             error.code == NSURLErrorCancelled ||
                                             error.code == NSURLErrorCannotConnectToHost||
                                             error.code == NSURLErrorNetworkConnectionLost ||
                                             error.code == NSURLErrorNotConnectedToInternet ||
                                             error.code == kCFURLErrorInternationalRoamingOff ||
                                             error.code == kCFURLErrorCallIsActive ||
                                             error.code == kCFURLErrorDataNotAllowed ||
                                             error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                             
                                             //it might work if we try agaime
                                             mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                         }
                                     }
                                 }];
        
    }
}

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
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



@end
