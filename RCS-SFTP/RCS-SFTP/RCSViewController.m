//
//  RCSViewController.m
//  RCSSCP
//
//  Created by Ryan Spring on 6/3/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import "RCSViewController.h"
#import "RCS_SCPRequest.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface RCSViewController ()

@property (nonatomic,weak) IBOutlet UITextField* addressInput;
@property (nonatomic,weak) IBOutlet UITextField* usernameInput;
@property (nonatomic,weak) IBOutlet UITextField* passwordInput;

@property (nonatomic,weak) IBOutlet UITextField* uploadName;

@property (nonatomic,strong) RCS_SCPRequest* request;
@property (nonatomic,strong) NSData* data;

-(IBAction)addUploadItem:(id)sender;
-(IBAction)transferItem:(id)sender;

@end

@implementation RCSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.uploadName.userInteractionEnabled = NO;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Handlers
-(IBAction)addUploadItem:(id)sender {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc]init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    self.uploadName.userInteractionEnabled = YES;

}

-(IBAction)transferItem:(id)sender {
    if(self.data != nil) {
        
        self.request = [[RCS_SCPRequest alloc]initWithHostname:self.addressInput.text Username:self.usernameInput.text Password:self.passwordInput.text];
        self.request.delegate = self;
        
        NSLog(@"Delegate set");
        
        [self.request startUpload:self.data toPath:self.uploadName.text];
    }
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

#pragma mark - UIImagePicker Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.data =  UIImageJPEGRepresentation(pickedImage, 0.7);
    self.usernameInput.userInteractionEnabled = YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
