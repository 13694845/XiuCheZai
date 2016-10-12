//
//  ChatMessage.m
//  XiuCheZai
//
//  Created by QSH on 16/10/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatMessage.h"

static NSString *const kIsSend = @"isSend";

static NSString *const kType = @"type";
static NSString *const kContent = @"content";
static NSString *const kPlayTime = @"playTime";

static NSString *const kSenderTime = @"senderTime";
static NSString *const kSenderId = @"senderId";
static NSString *const kSenderName = @"senderName";
static NSString *const kReceiverId = @"receiverId";
static NSString *const kReceiverName = @"receiverName";

@implementation ChatMessage

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _isSend = [aDecoder decodeBoolForKey:kIsSend];
        
        _type = [aDecoder decodeObjectForKey:kType];
        _content = [aDecoder decodeObjectForKey:kContent];
        _playTime = [aDecoder decodeObjectForKey:kPlayTime];
        
        _senderTime = [aDecoder decodeObjectForKey:kSenderTime];
        _senderId = [aDecoder decodeObjectForKey:kSenderId];
        _senderName = [aDecoder decodeObjectForKey:kSenderName];
        _receiverId = [aDecoder decodeObjectForKey:kReceiverId];
        _receiverName = [aDecoder decodeObjectForKey:kReceiverName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.isSend forKey:kIsSend];
    
    [aCoder encodeObject:self.type forKey:kType];
    [aCoder encodeObject:self.content forKey:kContent];
    [aCoder encodeObject:self.playTime forKey:kPlayTime];
    
    [aCoder encodeObject:self.senderTime forKey:kSenderTime];
    [aCoder encodeObject:self.senderId forKey:kSenderId];
    [aCoder encodeObject:self.senderName forKey:kSenderName];
    [aCoder encodeObject:self.receiverId forKey:kReceiverId];
    [aCoder encodeObject:self.receiverName forKey:kReceiverName];
}

@end
