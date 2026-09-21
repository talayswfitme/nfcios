#import <Foundation/Foundation.h>
#import <DCloudUniPlugin.h>
#import <CoreNFC/CoreNFC.h>

@interface PoscatNfc : DCUniPlugin <NFCNDEFReaderSessionDelegate>
@property (nonatomic, strong) NFCNDEFReaderSession *session;
@property (nonatomic, copy) DCUniPluginResultHandler resultCallback;
@property (nonatomic, assign) BOOL isWriteMode;
@property (nonatomic, copy) NSString *writePayload;
- (void)readNFC:(DCUniPluginMethod *)method;
- (void)writeNFC:(DCUniPluginMethod *)method;
@end
