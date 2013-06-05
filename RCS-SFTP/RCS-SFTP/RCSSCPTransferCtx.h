//
//  RCSSCPTransferCtx.h
//  RCSSCP
//
//  Created by Ryan Spring on 6/4/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libssh2.h"
#import "libssh2_config.h"

@interface RCSSCPTransferCtx : NSObject

@property (nonatomic,assign) LIBSSH2_CHANNEL* channel;
@property (nonatomic,assign) LIBSSH2_SESSION* session;
@property (nonatomic,assign) int sock;
@property (nonatomic,assign) NSInteger direction;

@property (nonatomic,strong) NSMutableData* data;
@property (nonatomic,strong) NSString* path;
@property (nonatomic,strong) dispatch_queue_t sockQueue;
@property (nonatomic,strong) dispatch_queue_t mainQueue;


@end
