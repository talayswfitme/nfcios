#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DCUniPluginStatus) {
    DCUniPluginStatusOk = 0,
    DCUniPluginStatusError = 1
};

typedef void (^DCUniPluginResultHandler)(id result);

@interface DCUniPluginMethod : NSObject
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, copy) DCUniPluginResultHandler resultCallback;
@end

@interface DCUniPluginResult : NSObject
+ (instancetype)resultWithStatus:(DCUniPluginStatus)status messageAsString:(NSString *)message;
+ (instancetype)resultWithStatus:(DCUniPluginStatus)status messageAsDictionary:(NSDictionary *)message;
@end

@interface DCUniPlugin : NSObject
@end
