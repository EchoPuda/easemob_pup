//
//  EasemobResponseHandler.h
//  easemob_plu
//
//  Created by 曾宪程 on 2019/9/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface EasemobResponseHandler : NSObject

@property (strong, nonatomic)FlutterMethodChannel *channel;

- (void)initEaseMob:(FlutterMethodCall*)call;

- (void)login:(FlutterMethodCall*)call;

- (void)logout:(FlutterMethodCall*)call;

@end

NS_ASSUME_NONNULL_END
