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

@property (nonatomic,strong) RCS_SCPRequest* request;
@end

@implementation RCSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    char* text = "Hi there, this is cool.";
    
    NSMutableData* data = [NSMutableData dataWithBytes:text length:strlen(text)];
    
    
    
    self.request = [[RCS_SCPRequest alloc]initWithHostname:@"192.168.8.105" Username:@"root" Password:@"smartlink"];
    self.request.delegate = self;
    
    [self.request startUpload:data toPath:@"rizzo.poo"];
    //[self.request startDownload:data fromPath:@"install.log"];
    
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
