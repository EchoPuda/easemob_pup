//
//  EasemobResponseHandler.m
//  easemob_plu
//
//  Created by 曾宪程 on 2019/9/16.
//

#import "EasemobResponseHandler.h"
#import <HyphenateLite/HyphenateLite.h>

@interface EasemobResponseHandler()<EMClientDelegate, EMMultiDevicesDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate>

@end

@implementation EasemobResponseHandler

- (id)init
{
    self = [super init];
    if (self) {
        [self _initHelper];
    }
    return self;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init

- (void)_initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

}

- (void)initEaseMob:(FlutterMethodCall*)call result:(FlutterResult)result{
    //初始化环信
    EMOptions *options = [EMOptions optionsWithAppkey:call.arguments[@"appKey"]];
    [options setIsAutoLogin:[call.arguments[@"autoLogin"] boolValue]];
    [options setIsAutoDownloadThumbnail:[call.arguments[@"autoDownloadThumbnail"] boolValue]];
    [options setIsAutoTransferMessageAttachments:[call.arguments[@"autoTransferMessageAttachments"] boolValue]];
#pragma mark  要修改
    //开发：banyunbangBLilyDevelopment
    //生产: banyunbangBLilyDisturtion
    options.apnsCertName = @"app_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    result(@"success");
}


- (void)login:(FlutterMethodCall*)call{
    //登录
    NSString *username = call.arguments[@"userName"];
    NSString *password = call.arguments[@"password"];
    
    [[EMClient sharedClient]loginWithUsername:username password:password completion:^(NSString *aUsername, EMError *aError) {
        [self.channel invokeMethod:@"loginListener" arguments:!aError ? @"success" : @"error"];
    }];
}

//EMContactManagerDelegate
- (void)friendshipDidAddByUser:(NSString *)aUsername{
    [self onContactListener:aUsername andType:0];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage{
    [self onContactInvitedListener:aUsername andMessage:aMessage];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername{
    [self onContactListener:aUsername andType:1];
}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername{
    //同意
    [self onContactListener:aUsername andType:2];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername{
    [self onContactListener:aUsername andType:3];
}

/**
 * 退出登录
 */

- (void)logout:(FlutterMethodCall*)call{
    [[EMClient sharedClient] logout:YES];
}

/**
 * 发送文本消息
 */
- (void)sendTextMessage:(FlutterMethodCall*)call{
    NSString *tmpStr = call.arguments[@"content"];
    NSString *toChatUsername = call.arguments[@"toChatUsername"];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:tmpStr];
    NSInteger chatType = [call.arguments[@"chatType"] integerValue];
    EMChatType type = chatType == 0 ? EMChatTypeChat: chatType == 1 ? EMChatTypeGroupChat : EMChatTypeChatRoom;
    [self sendMessageWithBody:textBody ext:nil chatType:type toName:toChatUsername];
}
/**
 * 发送语音消息
 */
- (void)sendVoiceMessage:(FlutterMethodCall*)call{
    NSString *filePath = call.arguments[@"filePath"];
    NSString *fileName = [[filePath componentsSeparatedByString:@"/"] lastObject];
    NSInteger length = [call.arguments[@"length"] integerValue];
    NSString *toChatUsername = call.arguments[@"toChatUsername"];
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc]initWithLocalPath:filePath displayName:fileName];
    voiceBody.duration = (int)length;
    NSInteger chatType = [call.arguments[@"chatType"] integerValue];
    EMChatType type = chatType == 0 ? EMChatTypeChat: chatType == 1 ? EMChatTypeGroupChat : EMChatTypeChatRoom;
    [self sendMessageWithBody:voiceBody ext:nil chatType:type toName:toChatUsername];
}
/**
 * 发送图片消息
 */
- (void)sendImageMessage:(FlutterMethodCall*)call{
    NSString *imagePath = call.arguments[@"imagePath"];
    BOOL originally = NO;
    if (call.arguments[@"originally"] != nil) {
        originally = [call.arguments[@"originally"] boolValue];
    }
    NSString *toChatUsername = call.arguments[@"toChatUsername"];
    NSString *imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    EMImageMessageBody *imageBody = [[EMImageMessageBody alloc]initWithLocalPath:imagePath displayName:imageName];
    imageBody.compressionRatio = originally ? 1.0 : 0.6;
    NSInteger chatType = [call.arguments[@"chatType"] integerValue];
    EMChatType type = chatType == 0 ? EMChatTypeChat: chatType == 1 ? EMChatTypeGroupChat : EMChatTypeChatRoom;
    [self sendMessageWithBody:imageBody ext:nil chatType:type toName:toChatUsername];
}

- (void)addMessageListener:(FlutterMethodCall*)call{
    //注册监听
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

/*!
 *  会话列表发生变化
 */
- (void)conversationListDidUpdate:(NSArray *)aConversationList{
    
}

#pragma mark - Message

/*!
 *  收到消息
 */
- (void)messagesDidReceive:(NSArray *)aMessages{
    [self onMessageReceived:aMessages];
}

/*!
 *  收到Cmd消息
 */
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages{
    [self onMessageReceived:aCmdMessages];
}

/*!
 *  收到已读回执
 */
- (void)messagesDidRead:(NSArray *)aMessages{
    
}

/*!
 *  收到消息送达回执
 */
- (void)messagesDidDeliver:(NSArray *)aMessages{
    
}

/*!
 *  收到消息撤回
 */
- (void)messagesDidRecall:(NSArray *)aMessages{
    
}

/*!
 *  消息状态发生变化
 */
- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError{
    
}

/*!
 *  消息附件状态发生改变
 */
- (void)messageAttachmentStatusDidChange:(EMMessage *)aMessage
                                   error:(EMError *)aError{
    
}

//获取聊天记录
- (void)getAllMessages:(FlutterMethodCall*)call result:(FlutterResult)result{
    EMConversationType type = [call.arguments[@"chatType"]integerValue] == 0 ? EMConversationTypeChat : [call.arguments[@"chatType"]integerValue] == 1 ? EMConversationTypeGroupChat : EMConversationTypeChatRoom ;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:call.arguments[@"username"] type:type createIfNotExist:NO];
    [conversation loadMessagesStartFromId:@"" count:1000 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < aMessages.count; i++) {
            EMMessage *message = aMessages[i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            EMChatType chatType = message.chatType;
            dic[@"chatType"] = @(chatType);
            EMMessageBodyType type = message.body.type;
            switch (type) {
                case EMMessageBodyTypeText:
                {
                    dic[@"type"] = @"TXT";
                    EMTextMessageBody *textBody = (EMTextMessageBody*)message.body;
                    dic[@"body"] = textBody.text;
                }
                    break;
                case EMMessageBodyTypeImage:
                {
                    dic[@"type"] = @"IMAGE";
                    EMImageMessageBody *imageBody = (EMImageMessageBody*)message.body;
                    //此处有问题 后面需要修改
                    dic[@"image"]  = imageBody.thumbnailRemotePath;
                    dic[@"body"] = imageBody.thumbnailLocalPath;
                }
                    break;
                case EMMessageBodyTypeVoice:
                {
                    dic[@"type"] = @"VOICE";
                    EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)message.body;
                    dic[@"body"] = voiceBody.localPath;
                }
                    break;
                case EMMessageBodyTypeCmd:
                    dic[@"type"] = @"CMD";
                    break;
                case EMMessageBodyTypeFile:
                    dic[@"type"] = @"FILE";
                    break;
                case EMMessageBodyTypeVideo:
                    dic[@"type"] = @"VIDEO";
                    break;
                case EMMessageBodyTypeLocation:
                    dic[@"type"] = @"LOCATION";
                    break;
                default:
                    break;
            }
            dic[@"msgId"] = message.messageId;
            dic[@"fromUser"] = message.from;
            dic[@"toUser"] = message.to;
            dic[@"time"] = @(message.localTime);
            [array addObject:dic];
        }
        result(array);
    }];
}



- (void)onContactListener:(NSString*)username andType:(NSInteger)type{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"type"] = @(type);
    [self.channel invokeMethod:@"contactListener" arguments:params];
}

- (void)onContactInvitedListener:(NSString*)username andMessage:(NSString*)message{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"reason"] = message;
    [self.channel invokeMethod:@"contactInvitedListener" arguments:params];
}

- (void)sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary *)aExt chatType:(EMChatType)type toName:(NSString*)toName
{
    if (![EMClient sharedClient].options.isAutoTransferMessageAttachments) {
        [self.channel invokeMethod:@"msgSendState" arguments:@"error"];
        return;
    }
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = toName;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:aBody ext:aExt];
    message.chatType = type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        [self.channel invokeMethod:@"msgSendState" arguments:!error ? @"success" : @"error"];
    }];
}

- (void)onMessageReceived:(NSArray*)messages{
    for (int i = 0; i < messages.count; i++) {
        EMMessage *message = messages[i];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"chatType"] = @(message.chatType);
        EMMessageBodyType type = message.body.type;
        switch (type) {
            case EMMessageBodyTypeText:
            {
                dic[@"type"] = @"TXT";
                EMTextMessageBody *textBody = (EMTextMessageBody*)message.body;
                dic[@"body"] = textBody.text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                dic[@"type"] = @"IMAGE";
                EMImageMessageBody *imageBody = (EMImageMessageBody*)message.body;
                //此处有问题 后面需要修改
                dic[@"image"]  = imageBody.thumbnailRemotePath;
                dic[@"body"] = imageBody.thumbnailLocalPath;
            }
                break;
                case EMMessageBodyTypeVoice:
            {
                dic[@"type"] = @"VOICE";
                EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)message.body;
                dic[@"body"] = voiceBody.localPath;
            }
                break;
            case EMMessageBodyTypeCmd:
                dic[@"type"] = @"CMD";
                break;
            case EMMessageBodyTypeFile:
                dic[@"type"] = @"FILE";
                break;
            case EMMessageBodyTypeVideo:
                dic[@"type"] = @"VIDEO";
                break;
            case EMMessageBodyTypeLocation:
                dic[@"type"] = @"LOCATION";
                break;
            default:
                break;
        }
    }
}

@end
