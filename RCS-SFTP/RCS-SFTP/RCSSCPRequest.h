//
//  RCSSCPRequest.h
//  RCSSCP
//
//  Created by Ryan Spring on 6/3/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCS-SCPRequestDelegate <NSObject>

-(void)RCSSCPRequestFailedWithError:(NSError*)error;
-(void)RCSSCPRequestDownloadCompleted:(NSData*)data;
-(void)RCSSCPRequestUploadCompleted;

@end

@interface RCS-SCPRequest : NSObject

@property (nonatomic,weak) id<RCS-SCPRequestDelegate> delegate;

-(id)initWithHostname:(NSString*)hostname Username:(NSString*)username Password:(NSString*)password;
-(void)startDownload:(NSMutableData*)data fromPath:(NSString*)path;
-(void)startUpload:(NSData*)data toPath:(NSString*)path;

@end
