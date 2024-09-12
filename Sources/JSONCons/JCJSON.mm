//
//  JCJSON.m
//  JSONCons
//
//  Created by Cory Kilger on 9/7/24.
//

#import "JCJSON.h"

#import <jsoncons/json.hpp>
#import <jsoncons/json_filter.hpp>
#import <jsoncons_ext/jsonpath/jsonpath.hpp>

NSString * const JCJSONErrorDomain = @"JCJSONErrorDomain";

@interface JCJSON ()

@property (nonatomic, assign) jsoncons::json json;

@end

@implementation JCJSON

- (instancetype)initWithJSON:(jsoncons::json)json {
    self = [super init];
    if (self) {
        self.json = json;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)error {
    self = [super init];
    if (self) {
        const char *jsonBytes = (const char *)[data bytes];
        std::size_t length = [data length];
        std::string jsonString(jsonBytes, length);
        try {
            self.json = jsoncons::json::parse(jsonString);
        } catch (const std::exception& e) {
            if (error) {
                NSString *errorDescription = [NSString stringWithFormat:@"Error parsing JSON: %s", e.what()];
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
                *error = [NSError errorWithDomain:JCJSONErrorDomain code:JCJSONErrorFailedToParseJSON userInfo:userInfo];
            }
            return nil;
        }
    }
    return self;
}

- (nullable instancetype)initWithJSONString:(nonnull NSString *)string error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (self) {
        try {
            self.json = jsoncons::json::parse([string UTF8String]);
        } catch (const std::exception& e) {
            if (error) {
                NSString *errorDescription = [NSString stringWithFormat:@"Error parsing JSON: %s", e.what()];
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
                *error = [NSError errorWithDomain:JCJSONErrorDomain code:JCJSONErrorFailedToParseJSON userInfo:userInfo];
            }
            return nil;
        }
    }
    return self;
}

+ (nonnull instancetype)null {
    static JCJSON *null = [[JCJSON alloc] initWithJSON:jsoncons::json::null()];
    return null;
}

- (nonnull instancetype)initWithBooleanValue:(BOOL)value {
    jsoncons::json json(value);
    return [self initWithJSON:json];
}

- (nonnull instancetype)initWithIntegerValue:(NSInteger)value {
    jsoncons::json json(value);
    return [self initWithJSON:json];
}

- (nonnull instancetype)initWithDoubleValue:(double)value {
    jsoncons::json json(value);
    return [self initWithJSON:json];
}

- (nonnull instancetype)initWithStringValue:(nonnull NSString *)value {
    jsoncons::json json([value UTF8String]);
    return [self initWithJSON:json];
}

- (nonnull instancetype)initWithArrayValue:(nonnull NSArray<JCJSON *> *)value {
    jsoncons::json json(jsoncons::json_array_arg);
    for (JCJSON *item in value) {
        json.push_back(item->_json);
    }
    return [self initWithJSON:json];
}

- (nonnull instancetype)initWithObjectValue:(nonnull NSDictionary<NSString *, JCJSON *> *)value {
    jsoncons::json json;
    for (NSString *key in value) {
        json.insert_or_assign([key UTF8String], value[key]->_json);
    }
    return [self initWithJSON:json];
}

- (JCJSONType)type {
    switch (_json.type()) {
        case jsoncons::json_type::null_value:
            return JCJSONTypeNull;
        case jsoncons::json_type::bool_value:
            return JCJSONTypeBool;
        case jsoncons::json_type::int64_value:
        case jsoncons::json_type::uint64_value:
            return JCJSONTypeInteger;
        case jsoncons::json_type::half_value:
        case jsoncons::json_type::double_value:
            return JCJSONTypeDouble;
        case jsoncons::json_type::string_value:
        case jsoncons::json_type::byte_string_value:
            return JCJSONTypeString;
        case jsoncons::json_type::array_value:
            return JCJSONTypeArray;
        case jsoncons::json_type::object_value:
            return JCJSONTypeObject;
    }
}

- (id)value {
    switch (_json.type()) {
        case jsoncons::json_type::null_value:
            return [NSNull null];
        case jsoncons::json_type::bool_value:
            return [[NSNumber alloc] initWithBool:_json.as_bool()];
        case jsoncons::json_type::int64_value:
            return [[NSDecimalNumber alloc] initWithInteger:_json.as_integer<NSInteger>()];
        case jsoncons::json_type::uint64_value:
            return [[NSDecimalNumber alloc] initWithUnsignedInteger:_json.as_integer<NSUInteger>()];
        case jsoncons::json_type::half_value:
        case jsoncons::json_type::double_value:
            return [[NSDecimalNumber alloc] initWithDouble:_json.as_double()];
        case jsoncons::json_type::string_value:
        case jsoncons::json_type::byte_string_value:
            return [self stringValue];
        case jsoncons::json_type::array_value:
            return [self arrayValue];
        case jsoncons::json_type::object_value:
            return [self objectValue];
    }
}

- (NSNull *)nullValue {
    try {
        return _json.is_null() ? [NSNull null] : nil;
    } catch (const std::exception& e) {
        return nil;
    }
}

- (BOOL)booleanValue {
    try {
        return _json.as_bool();
    } catch (const std::exception& e) {
        return false;
    }
}

- (NSInteger)integerValue {
    try {
        return _json.as_integer<NSInteger>();
    } catch (const std::exception& e) {
        return 0;
    }
}

- (double)doubleValue {
    try {
        return _json.as_double();
    } catch (const std::exception& e) {
        return 0;
    }
}

- (NSString *)stringValue {
    try {
        return [[NSString alloc] initWithUTF8String:_json.as_cstring()];
    } catch (const std::exception& e) {
        return nil;
    }
}

- (NSArray<JCJSON *> *)arrayValue {
    try {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:_json.size()];
        for (const auto& jsonItem : _json.array_range()) {
            [array addObject:[[JCJSON alloc] initWithJSON:jsonItem]];
        }
        return array;
    } catch (const std::exception& e) {
        return nil;
    }
}

- (NSDictionary<NSString *, JCJSON *> *)objectValue {
    try {
        NSMutableDictionary *object = [[NSMutableDictionary alloc] initWithCapacity:_json.size()];
        for (const auto& item : _json.object_range()) {
            NSString *key = [NSString stringWithUTF8String:item.key().c_str()];
            JCJSON *value = [[JCJSON alloc] initWithJSON:item.value()];
            [object setObject:value forKey:key];
        }
        return object;
    } catch (const std::exception& e) {
        return nil;
    }
}

- (NSData *)serializedData {
    std::string jsonString;
    _json.dump(jsonString);
    NSString *nsJsonString = [[NSString alloc] initWithUTF8String:jsonString.c_str()];
    return [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];
}

- (JCJSON *)queryWithString:(NSString *)string error:(NSError **)error {
    try {
        jsoncons::json result = jsoncons::jsonpath::json_query(_json, string.UTF8String);
        return [[JCJSON alloc] initWithJSON:result];
    } catch (const std::exception& e) {
        if (error) {
            NSString *errorDescription = [[NSString alloc] initWithFormat:@"path: '%@' failed: %@", string, [[NSString alloc] initWithUTF8String:e.what()]];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
            *error = [NSError errorWithDomain:JCJSONErrorDomain code:JCJSONErrorFailedToQueryJSON userInfo:userInfo];
        }
        return nil;
    }
}

@end
