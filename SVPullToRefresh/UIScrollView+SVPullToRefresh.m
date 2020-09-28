//
//  UmbrellaRefreshView.m
//  Forecast Bar for iOS
//
//  Created by Derek Johnson on 11/10/15.
//  Copyright © 2015 Real Casual Games, LLC. All rights reserved.
//

#import "UmbrellaRefreshView.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface UIColor (Ext)

- (BOOL) colorIsLight;

@end

@implementation UIColor (Ext)

- (BOOL) colorIsLight {
    CGFloat colorBrightness = 0;
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    
    if(colorSpaceModel == kCGColorSpaceModelRGB){
        const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
        
        colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    } else {
        [self getWhite:&colorBrightness alpha:0];
    }
    
    return (colorBrightness >= .5f);
}

@end

@implementation UmbrellaRefreshView

-(instancetype)initWithFrame:(CGRect)frame onColor:(UIColor*) backgroundColorLocal {
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    self.layer.cornerRadius = 8.0f;
    
    umbrella = [[UIImageView alloc] initWithFrame: CGRectMake(10, 5, 40, 40)];
    umbrellaLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, 160, 40)];
    umbrellaSubLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 25, 160, 20)];

    [umbrellaLabel setText:@"Pull to Refresh"];
    
    
    umbrella.isAccessibilityElement = NO;
    umbrellaLabel.isAccessibilityElement = NO;
    umbrellaSubLabel.isAccessibilityElement = NO;
        
    NSDateFormatter *formatter;
   
    
    formatter = [[NSDateFormatter alloc] init];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setLocale:[NSLocale currentLocale]];
    [formatter2 setDateStyle:NSDateFormatterNoStyle];
    [formatter2 setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString2 = [formatter2 stringFromDate:[NSDate date]];
    NSRange amRange = [dateString2 rangeOfString:[formatter2 AMSymbol]];
    NSRange pmRange = [dateString2 rangeOfString:[formatter2 PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    
    if([[AppDelegate sharedDefaults] boolForKey:@"use_24_hour_clock"] || is24h) {
        [formatter setDateFormat:@"M/d @ HH:mm "];
    } else {
        [formatter setDateFormat:@"M/d @ h:mma "];
    }
    
    NSNumber *time = [[AppDelegate sharedDefaults] objectForKey:@"last_updated_time"];
    NSTimeInterval interval = [time doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    dateString = [formatter stringFromDate:date];

    [umbrellaSubLabel setText:[NSString stringWithFormat:@"Updated %@", dateString]];
    [umbrellaSubLabel setFont:[UIFont systemFontOfSize:9]];
    
    [self refreshColor:backgroundColor];
    
    [self addSubview:umbrella];
    [self addSubview:umbrellaLabel];
    [self addSubview:umbrellaSubLabel];

    return self;
}

-(void) refreshColor:(UIColor*) backgroundColorLocal {
    self.backgroundColor = backgroundColorLocal;
    
    if([backgroundColor colorIsLight]) {
        [umbrella setImage:[UIImage imageNamed:@"umbrella"]];
        [umbrellaLabel setTextColor:[UIColor blackColor]];
        [umbrellaSubLabel setTextColor:[UIColor blackColor]];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    } else {
        [umbrella setImage:[UIImage imageNamed:@"umbrella_white"]];
        [umbrellaLabel setTextColor:[UIColor whiteColor]];
        [umbrellaSubLabel setTextColor:[UIColor whiteColor]];
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    }
    
    umbrella.accessibilityIgnoresInvertColors = YES;
}

-(void) refreshStateUpdated:(NSNumber*) state {
    ViewController* vc = ((AppDelegate*) [[UIApplication sharedApplication] delegate]).panelController;
    float viewWidth = vc.viewSize;
    BOOL isMultitaskMode = viewWidth == 320 || viewWidth == 375 || viewWidth == 438 || viewWidth == 490 ||viewWidth == 504 || viewWidth == 507 || viewWidth == 551 || viewWidth == 557 || viewWidth == 585 || viewWidth == 639 || viewWidth == 678 || viewWidth == 782 || viewWidth == 834 || viewWidth == 850 || viewWidth == 981;


    float width = isMultitaskMode ? viewWidth : [[UIScreen mainScreen]bounds].size.width;
    
    if([state intValue] == SVPullToRefreshStateTriggered) {
//        umbrellaSubLabel.text = nil;

        [UIView animateWithDuration:0.1
                         animations:^{
                             self.frame = CGRectMake((width - 205) / 2, 0, 205, 50);
//                             [umbrellaLabel setFrame:CGRectMake(50, 5, 160, 40)];

                         }
                         completion:^(BOOL finished){
                             umbrellaLabel.text = @"Release to Refresh";
                         }];

    } else if([state intValue] == SVPullToRefreshStateLoading) {
//        [umbrellaLabel setFrame:CGRectMake(50, 5, 160, 40)];
        umbrellaLabel.text = @"Loading...";
//        umbrellaSubLabel.text = nil;
//        self.frame = CGRectMake(0, 0, 140, 50);
    } else if([state intValue] == SVPullToRefreshStateStopped) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setLocale:[NSLocale currentLocale]];
        [formatter2 setDateStyle:NSDateFormatterNoStyle];
        [formatter2 setTimeStyle:NSDateFormatterShortStyle];
        
        NSString *dateString2 = [formatter2 stringFromDate:[NSDate date]];
        NSRange amRange = [dateString2 rangeOfString:[formatter2 AMSymbol]];
        NSRange pmRange = [dateString2 rangeOfString:[formatter2 PMSymbol]];
        BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
        
        if([[AppDelegate sharedDefaults] boolForKey:@"use_24_hour_clock"] || is24h) {
            [formatter setDateFormat:@"M/d @ HH:mm "];
        } else {
            [formatter setDateFormat:@"M/d @ h:mma "];
        }
        
        NSNumber *time = [[AppDelegate sharedDefaults] objectForKey:@"last_updated_time"];
        NSTimeInterval interval = [time doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
        dateString = [formatter stringFromDate:date];
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.frame = CGRectMake((width - 180) / 2, 0, 180, 50);
                             [umbrellaLabel setFrame:CGRectMake(50, 0, 160, 40)];
                             umbrellaLabel.text = @"Pull to Refresh";
                             umbrellaSubLabel.text = [NSString stringWithFormat:@"Updated %@", dateString];
                         }
                         completion:^(BOOL finished){
                                ViewController* vc = ((AppDelegate*) [[UIApplication sharedApplication] delegate]).panelController;
                                if ([AppDelegate isNotchedDevice]) {
                                        vc.scrollView.contentInset = UIEdgeInsetsMake(25, 0, 0, 0);
                                        [vc.scrollView scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:NO];                                                    
                                } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                        vc.scrollView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
                                        [vc.scrollView scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:NO];
                                } else {
                                    [vc.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                                }
                        
                                [vc.scrollView.pullToRefreshView stopAnimating];
                                [vc setLoadingViewVisibility:NO isUpdating:NO];

                         }
         ];
    }
}

@end
