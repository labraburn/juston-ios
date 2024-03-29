//
//  Created by Anton Spivak
//

#import "NSException+O42.h"

NSErrorDomain const O42ExceptionErrorDomain = @"O42ExceptionErrorDomain";

@implementation NSException (NSError)

- (NSError *)o42_error {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.name forKey:@"NSExceptionName"];
    [userInfo setValue:(self.reason ?: @"") forKey:@"NSExceptionReason"];
    [userInfo setValue:self.callStackReturnAddresses forKey:@"NSExceptionCallStackReturnAddresses"];
    [userInfo setValue:self.callStackSymbols forKey:@"NSExceptionCallStackSymbols"];
    [userInfo setValue:(self.userInfo ?: @{}) forKey:@"NSExceptionUserInfo"];
    
    return [NSError errorWithDomain:O42ExceptionErrorDomain code:0 userInfo:@{
        NSUnderlyingErrorKey : self,
        NSDebugDescriptionErrorKey : [userInfo copy],
        NSLocalizedFailureReasonErrorKey : self.reason ?: @""
    }];
}

+ (void)o42_raiseExceptionWithName:(NSExceptionName)name
                            reason:(nullable NSString *)reason
                          userInfo:(nullable NSDictionary *)userInfo
{
    [[NSException exceptionWithName:name reason:reason userInfo:userInfo] raise];
}

@end
