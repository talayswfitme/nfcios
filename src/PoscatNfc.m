#import "PoscatNfc.h"

@implementation PoscatNfc

- (void)readNFC:(DCUniPluginMethod *)method {
    self.resultCallback = method.resultCallback;
    self.isWriteMode = NO;
    [self beginSessionWithAlert:method.args[@"alertMsg"] ?: @"请将会员卡贴到手机背面"];
}

- (void)writeNFC:(DCUniPluginMethod *)method {
    self.resultCallback = method.resultCallback;
    self.isWriteMode = YES;
    self.writePayload = [NSString stringWithFormat:@"%@", method.args[@"writeData"] ?: @""];
    [self beginSessionWithAlert:method.args[@"alertMsg"] ?: @"请将空白会员卡贴到手机背面"];
}

- (void)beginSessionWithAlert:(NSString *)alert {
    if (@available(iOS 11.0, *)) {
        self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:NO];
        self.session.alertMessage = alert;
        [self.session beginSession];
    } else if (self.resultCallback) {
        self.resultCallback([DCUniPluginResult resultWithStatus:DCUniPluginStatusError messageAsString:@"系统版本过低，不支持 NFC"]);
    }
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages {
    if (self.isWriteMode) return;
    NFCNDEFPayload *payload = messages.firstObject.records.firstObject;
    NSString *cardID = [[NSString alloc] initWithData:payload.payload encoding:NSUTF8StringEncoding] ?: @"";
    if (self.resultCallback) {
        self.resultCallback([DCUniPluginResult resultWithStatus:DCUniPluginStatusOk messageAsDictionary:@{ @"success": @YES, @"cardId": cardID }]);
    }
    [session invalidateSession];
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof NFCTag *> *)tags API_AVAILABLE(ios(13.0)) {
    if (tags.count == 0) return;
    id tag = tags.firstObject;
    if (![tag respondsToSelector:@selector(queryNDEFStatusWithCompletionHandler:)]) {
        [session invalidateSessionWithErrorMessage:@"该卡不支持 NDEF"];
        return;
    }
    [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError *error) {
        if (error || status == NFCNDEFStatusNotSupported) {
            [session invalidateSessionWithErrorMessage:@"该卡不支持 NDEF"];
            return;
        }
        if (!self.isWriteMode) {
            [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage *message, NSError *readError) {
                NFCNDEFPayload *payload = message.records.firstObject;
                NSString *cardID = [[NSString alloc] initWithData:payload.payload encoding:NSUTF8StringEncoding] ?: @"";
                if (self.resultCallback) {
                    DCUniPluginStatus resultStatus = readError ? DCUniPluginStatusError : DCUniPluginStatusOk;
                    NSDictionary *data = readError ? @{} : @{ @"success": @YES, @"cardId": cardID };
                    self.resultCallback([DCUniPluginResult resultWithStatus:resultStatus messageAsDictionary:data]);
                }
                [session invalidateSession];
            }];
        } else {
            NFCNDEFPayload *record = [NFCNDEFPayload wellKnownTypeTextPayloadWithString:self.writePayload locale:@"zh-CN"];
            NFCNDEFMessage *message = [[NFCNDEFMessage alloc] initWithRecords:@[record]];
            [tag writeNDEFMessage:message completionHandler:^(NSError *writeError) {
                if (self.resultCallback) {
                    DCUniPluginStatus resultStatus = writeError ? DCUniPluginStatusError : DCUniPluginStatusOk;
                    NSDictionary *data = writeError ? @{} : @{ @"success": @YES, @"cardId": self.writePayload ?: @"" };
                    self.resultCallback([DCUniPluginResult resultWithStatus:resultStatus messageAsDictionary:data]);
                }
                [session invalidateSession];
            }];
        }
    }];
}

- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session {}

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
    if (error && self.resultCallback) {
        self.resultCallback([DCUniPluginResult resultWithStatus:DCUniPluginStatusError messageAsString:error.localizedDescription]);
    }
    self.session = nil;
}

@end
