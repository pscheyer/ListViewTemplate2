//
//  UserTests.m
//  Blocstagram
//
//  Created by Peter Scheyer on 3/27/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "User.h"
#import "Comment.h"
#import "Media.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testThatInitializationWorksUser {
    
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"username": @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(testUser.profilePictureURL, [NSURL URLWithString:sourceDictionary[@"profile_picture"]], @"The profile picture should be equal");
}
- (void)testThatInitializationWorksComment {
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"text" : @"Sample Comment"};
    
    Comment *testComment = [[Comment alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testComment.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testComment.text, sourceDictionary[@"text"], @"The text should be equal");
}

-(void)testThatInitializationWorksMedia {
    
    NSDictionary *userSourceDictionary = @{@"id": @"8675309",
                                       @"username": @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    
    
    NSDictionary *commentSourceDictionary = @{@"id": @"8675309",
                                       @"text" : @"Sample Comment"};
    
    NSDictionary  *captionSourceDictionary = @{@"text": @"lalala"};
    
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"user": userSourceDictionary,
                                       @"url" : @"http://www.example.com/example.jpg",
//                                       @"images" : @"lala",
                                       @"standard_resolution": @"Resolution!",
                                       @"caption" : captionSourceDictionary,
                                       @"comments" : commentSourceDictionary};
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    
    //user for testing
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary[@"user"]];
    
    
    // image string for testing
    NSString *standardResolutionImageURLString = sourceDictionary[@"images"][@"standard_resolution"][@"url"];
    NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
    
    //comment array for testing
    NSMutableArray *testCommentArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *commentDictionary in sourceDictionary[@"comments"][@"data"]) {
        Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
        [testCommentArray addObject:comment];
    }
    
    //caption dictionary for testing
    
    NSDictionary *testCaptionDictionary = sourceDictionary[@"caption"];
    
    //caption might be null if they haven't bothered
    NSString *testOutputCaption = [[NSString alloc] init];
    
    if ([testCaptionDictionary isKindOfClass:[NSDictionary class]]) {
        testOutputCaption = testCaptionDictionary[@"text"];
    } else {
        testOutputCaption = @"";
    }
    
    //id number test
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    
    //user tests
    XCTAssertEqualObjects(testMedia.user.idNumber, testUser.idNumber, @"The user ID number should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, testUser.userName, @"The user username should be equal");
    XCTAssertEqualObjects(testMedia.user.fullName, testUser.fullName, @"The user fullName should be equal");
    XCTAssertEqualObjects(testMedia.user.profilePicture, testUser.profilePicture, @"The profile picture should be equal");
    
    //mediaURL test
    XCTAssertEqualObjects(testMedia.mediaURL, standardResolutionImageURL, @"The mediaURL should be equal");

    //caption test
    XCTAssertEqualObjects(testMedia.caption, testOutputCaption, @"The caption should be equal");
    
    //comments test
    XCTAssertEqualObjects(testMedia.comments, testCommentArray, @"The comments should be equal");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
