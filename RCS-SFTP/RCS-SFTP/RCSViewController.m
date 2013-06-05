//
//  RCSViewController.m
//  RCSSCP
//
//  Created by Ryan Spring on 6/3/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import "RCSViewController.h"
#import "RCS_SCPRequest.h"

@interface RCSViewController ()

@property (nonatomic,weak) IBOutlet UITextField* addressInput;
@property (nonatomic,weak) IBOutlet UITextField* usernameInput;
@property (nonatomic,weak) IBOutlet UITextField* passwordInput;

@property (nonatomic,weak) IBOutlet UITextField* uploadName;


@property (nonatomic,strong) RCS_SCPRequest* request;
@end

@implementation RCSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    char* text = "Hi there, this is cool.";
    
    NSMutableData* data = [NSMutableData dataWithBytes:text length:strlen(text)];
    
    self.addressInput.text = @"192.168.1.1";
    self.usernameInput.text = @"rcspring";
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - RCSSCPRequestDelegate
-(void)RCS_SCPRequestFailedWithError:(NSError *)error {
    NSLog(@"Error %@",error);
}

-(void)RCS_SCPRequestDownloadCompleted:(NSData *)data {
    NSLog(@"Have data of size %d",data.length);
}

-(void)RCS_SCPRequestUploadCompleted {
    NSLog(@"Upload completed");
}
@end
