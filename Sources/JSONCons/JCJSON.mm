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

#include <functional> // For std::hash
#include <string_view> // For std::string_view

NSString * const JCJSONErrorDomain = @"JCJSONErrorDomain";

@interface JCJSON ()

@property (nonatomic, assign) jsoncons::json json;

@property (nonatomic, strong) id native;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JCJSON

static inline jsoncons::json convertValue(id value, NSDateFormatter *dateFormatter) {
    if ([value isKindOfClass:[JCJSON class]]) {
        [value loadJSON];
        return ((JCJSON *)value)->_json;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)value;
        if (strcmp([number objCType], @encode(BOOL)) == 0) {
            return jsoncons::json(number.boolValue);
        } else if (strcmp([number objCType], @encode(NSInteger)) == 0 || strcmp([number objCType], @encode(NSUInteger)) == 0) {
            return jsoncons::json(number.integerValue);
        } else if (strcmp([number objCType], @encode(double)) == 0) {
            return jsoncons::json(number.doubleValue);
        }
    }
    if ([value isKindOfClass:[NSString class]]) {
        return jsoncons::json([value UTF8String]);
    }
    if ([value isKindOfClass:[NSArray class]]) {
        jsoncons::json json(jsoncons::json_array_arg);
        for (id item in value) {
            json.push_back(convertValue(item, dateFormatter));
        }
        return json;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        jsoncons::json json;
        for (NSString *key in value) {
            json.insert_or_assign([key UTF8String], convertValue(value[key], dateFormatter));
        }
        return json;
    }
    if ([value isKindOfClass:[NSDate class]] && dateFormatter) {
        return jsoncons::json([[dateFormatter stringFromDate:(NSDate *)value] UTF8String]);
    }
    return jsoncons::json::null();
}

- (instancetype)initWithValue:(id)value {
    return [self initWithValue:value dateFormatter:nil];
}

- (instancetype)initWithValue:(id)value dateFormatter:(NSDateFormatter *)dateFormatter {
    if ([value isKindOfClass:[JCJSON class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        return [self initWithNativeValue:value dateFormatter:dateFormatter];
    }
    self = [super init];
    if (self) {
        _json = convertValue(value, dateFormatter);
    }
    return self;
}

- (instancetype)initWithJSON:(jsoncons::json)json {
    self = [super init];
    if (self) {
        _json = json;
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
            _json = jsoncons::json::parse(jsonString);
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
            _json = jsoncons::json::parse([string UTF8String]);
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
    return [self initWithNativeValue:value dateFormatter:nil];
}

- (nonnull instancetype)initWithObjectValue:(nonnull NSDictionary *)value {
    return [self initWithNativeValue:value dateFormatter:nil];
}

- (nonnull instancetype)initWithNativeValue:(nonnull id)value dateFormatter:(nullable NSDateFormatter *)dateFormatter {
    self = [self init];
    if (self) {
        _native = value;
        _dateFormatter = dateFormatter;
    }
    return self;
}

- (JCJSONType)type {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSArray class]]) {
            return JCJSONTypeArray;
        } else if ([native isKindOfClass:[NSDictionary class]]) {
            return JCJSONTypeObject;
        } else if ([native isKindOfClass:[NSNull class]]) {
            return JCJSONTypeNull;
        } else if ([native isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)native;
            if (strcmp([number objCType], @encode(BOOL)) == 0) {
                return JCJSONTypeBool;
            } else if (strcmp([number objCType], @encode(NSInteger)) == 0 || strcmp([number objCType], @encode(NSUInteger)) == 0) {
                return JCJSONTypeInteger;
            } else if (strcmp([number objCType], @encode(double)) == 0) {
                return JCJSONTypeDouble;
            }
        } else if ([native isKindOfClass:[NSString class]]) {
            return JCJSONTypeString;
        }
    }
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
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[native count]];
            for (id item in native) {
                [result addObject:[[JCJSON alloc] initWithValue:item dateFormatter:_dateFormatter]];
            }
            return result;
        } else if ([native isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[native count]];
            for (NSString *key in native) {
                result[key] = [[JCJSON alloc] initWithValue:native[key] dateFormatter:_dateFormatter];
            }
            return result;
        } else {
            return native;
        }
    }
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
    id native = _native;
    if (native) {
        return [native isKindOfClass:[NSNull class]] ? native : nil;
    }
    try {
        return _json.is_null() ? [NSNull null] : nil;
    } catch (const std::exception& e) {
        return nil;
    }
}

- (BOOL)booleanValue {
    id native = _native;
    if (native) {
        return [native isKindOfClass:[NSNumber class]] ? [native boolValue] : NO;
    }
    try {
        return _json.as_bool();
    } catch (const std::exception& e) {
        return false;
    }
}

- (NSInteger)integerValue {
    id native = _native;
    if (native) {
        return [native isKindOfClass:[NSNumber class]] ? [native integerValue] : 0;
    }
    try {
        return _json.as_integer<NSInteger>();
    } catch (const std::exception& e) {
        return 0;
    }
}

- (double)doubleValue {
    id native = _native;
    if (native) {
        return [native isKindOfClass:[NSNumber class]] ? [native doubleValue] : 0;
    }
    try {
        return _json.as_double();
    } catch (const std::exception& e) {
        return 0;
    }
}

- (NSString *)stringValue {
    id native = _native;
    if (native) {
        return [native isKindOfClass:[NSString class]] ? native : nil;
    }
    try {
        return [[NSString alloc] initWithUTF8String:_json.as_cstring()];
    } catch (const std::exception& e) {
        return nil;
    }
}

- (NSArray<JCJSON *> *)arrayValue {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[native count]];
            for (id item in native) {
                [result addObject:[[JCJSON alloc] initWithValue:item dateFormatter:_dateFormatter]];
            }
            return result;
        }
        return nil;
    }
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
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[native count]];
            for (NSString *key in native) {
                result[key] = [[JCJSON alloc] initWithValue:native[key] dateFormatter:_dateFormatter];
            }
            return result;
        }
        return nil;
    }
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

- (NSInteger)size {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSArray class]]) {
            return [native count];
        } else if ([native isKindOfClass:[NSDictionary class]]) {
            return [native count];
        } else if ([native isKindOfClass:[NSNull class]]) {
            return 0;
        }
    }
    return static_cast<NSInteger>(_json.size());
}

- (JCJSON *)valueAtIndex:(NSInteger)index {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSArray class]]) {
            if (index >= 0 && index < [native count]) {
                return [[JCJSON alloc] initWithValue:native[index] dateFormatter:_dateFormatter];
            }
        }
        return nil;
    }
    if (index < 0 || index >= _json.size() || !_json.is_array()) {
        return nil;
    }
    try {
        const auto& jsonItem = _json.at(index);
        return [[JCJSON alloc] initWithJSON:jsonItem];
    } catch (const std::exception& e) {
        return nil;
    }
}

- (JCJSON *)valueForKey:(NSString *)key {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSDictionary class]]) {
            return [[JCJSON alloc] initWithValue:native[key] dateFormatter:_dateFormatter];
        }
        return nil;
    }
    if (!_json.is_object()) {
        return nil;
    }
    try {
        const auto& jsonItem = _json.at(key.UTF8String);
        return [[JCJSON alloc] initWithJSON:jsonItem];
    } catch (const std::exception& e) {
        return nil;
    }
}

- (NSArray<NSString *> *)keys {
    id native = _native;
    if (native) {
        if ([native isKindOfClass:[NSDictionary class]]) {
            return [native allKeys];
        }
        return nil;
    }
    if (!_json.is_object()) {
        return nil;
    }
    NSMutableArray *keysArray = [[NSMutableArray alloc] initWithCapacity:_json.size()];
    for (const auto& item : _json.object_range()) {
        [keysArray addObject:[NSString stringWithUTF8String:item.key().c_str()]];
    }
    return keysArray;
}

- (NSData *)serializedData {
    [self loadJSON];
    std::string jsonString;
    _json.dump(jsonString);
    NSString *nsJsonString = [[NSString alloc] initWithUTF8String:jsonString.c_str()];
    return [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];
}

- (JCJSON *)queryWithString:(NSString *)string error:(NSError **)error {
    try {
        [self loadJSON];
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

- (void)loadJSON {
    if (_native) {
        _json = convertValue(_native, _dateFormatter);
        _native = nil;
        _dateFormatter = nil;
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if ([other isKindOfClass:[JCJSON class]]) {
        [self loadJSON];
        [other loadJSON];
        return _json == ((JCJSON *)other)->_json;
    } else {
        return NO;
    }
}

// Helper function for combining hash values
static inline size_t hash_combine(size_t seed, size_t value) {
    return seed ^ (value + 0x9e3779b9 + (seed << 6) + (seed >> 2));
}

// Static inline function to hash a json value, limited to one level deep
static inline size_t hash_json(const jsoncons::json& j, int depth) {
    switch (j.type()) {
        case jsoncons::json_type::bool_value:
            return j.as_bool() ? 1 : 0;

        case jsoncons::json_type::int64_value:
            return std::hash<int64_t>()(j.as_integer<int64_t>());

        case jsoncons::json_type::uint64_value:
            return std::hash<uint64_t>()(j.as_integer<uint64_t>());

        case jsoncons::json_type::half_value:
        case jsoncons::json_type::double_value:
            return std::hash<double>()(j.as_double());

        case jsoncons::json_type::string_value: {
            const std::string& str = j.as_string();
            return std::hash<std::string_view>()(std::string_view(str.c_str(), str.size()));
        }

        case jsoncons::json_type::byte_string_value: {
            const auto& byte_string = j.as_byte_string();
            return std::hash<std::string_view>()(std::string_view(reinterpret_cast<const char*>(byte_string.data()), byte_string.size()));
        }

        case jsoncons::json_type::array_value: {
            if (depth == 1) {
                return std::hash<size_t>()(j.size());
            } else {
                size_t seed = 0;
                for (const auto& item : j.array_range()) {
                    seed = hash_combine(seed, hash_json(item, depth + 1));
                }
                return seed;
            }
        }

        case jsoncons::json_type::object_value: {
            if (depth == 1) {
                return std::hash<size_t>()(j.size());
            } else {
                size_t object_hash = 0;
                for (const auto& item : j.object_range()) {
                    const std::string& key = item.key();
                    size_t key_hash = std::hash<std::string_view>()(std::string_view(key.c_str(), key.size()));
                    size_t value_hash = hash_json(item.value(), depth + 1);
                    size_t key_value_hash = hash_combine(key_hash, value_hash);
                    object_hash ^= key_value_hash; // XOR makes it order-independent
                }
                return object_hash;
            }
        }

        default:
            return 0; // Null and unexpected types
    }
}

- (NSUInteger)hash {
    [self loadJSON];
    return hash_json(_json, 0);
}

@end
