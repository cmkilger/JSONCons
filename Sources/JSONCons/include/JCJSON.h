//
//  JCJSON.h
//  JSONCons
//
//  Created by Cory Kilger on 9/7/24.
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(JSONErrorDomain)
extern NSString * _Nonnull const JCJSONErrorDomain;

typedef NS_ENUM(NSInteger, JCJSONError) {
    JCJSONErrorFailedToParseJSON NS_SWIFT_NAME(failedToParseJSON) = 1001,
    JCJSONErrorFailedToQueryJSON NS_SWIFT_NAME(failedToQueryJSON),
} NS_SWIFT_NAME(JSONError);

typedef NS_ENUM(NSInteger, JCJSONType) {
    JCJSONTypeNull NS_SWIFT_NAME(null),
    JCJSONTypeBool NS_SWIFT_NAME(boolean),
    JCJSONTypeInteger NS_SWIFT_NAME(integer),
    JCJSONTypeDouble NS_SWIFT_NAME(double),
    JCJSONTypeString NS_SWIFT_NAME(string),
    JCJSONTypeArray NS_SWIFT_NAME(array),
    JCJSONTypeObject NS_SWIFT_NAME(object)
} NS_SWIFT_NAME(JSONType);

NS_SWIFT_NAME(JSON)
__attribute__((objc_subclassing_restricted))
@interface JCJSON : NSObject

@property (assign, readonly) JCJSONType type;

@property (strong, readonly, nullable) NSNull *nullValue;
@property (assign, readonly) BOOL booleanValue;
@property (assign, readonly) NSInteger integerValue;
@property (assign, readonly) double doubleValue;
@property (strong, readonly, nullable) NSString *stringValue;
@property (strong, readonly, nullable) NSArray<JCJSON *> *arrayValue;
@property (strong, readonly, nullable) NSDictionary<NSString *, JCJSON *> *objectValue;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithData:(nonnull NSData *)data error:(NSError * _Nullable * _Nullable)error;

- (nullable JCJSON *)queryWithString:(nonnull NSString *)string error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(query(_:));

@end
