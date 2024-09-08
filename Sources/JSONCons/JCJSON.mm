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
        auto string = _json.as_string();
        return [NSString stringWithUTF8String:string.c_str()];
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

- (JCJSON *)queryWithString:(NSString *)string error:(NSError **)error {
    try {
        jsoncons::json result = jsoncons::jsonpath::json_query(_json, string.UTF8String);
        return [[JCJSON alloc] initWithJSON:result];
    } catch (const std::exception& e) {
        if (error) {
            NSString *errorDescription = [NSString stringWithUTF8String:e.what()];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
            *error = [NSError errorWithDomain:JCJSONErrorDomain code:JCJSONErrorFailedToQueryJSON userInfo:userInfo];
        }
        return nil;
    }
}

@end
