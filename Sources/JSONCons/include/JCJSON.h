//
//  JCJSON.h
//  JSONCons
//
//  Created by Cory Kilger on 9/7/24.
//

#import <Foundation/Foundation.h>

/// The domain for errors occurring during JSON parsing.
///
/// Use this constant to differentiate JSON-related errors from other errors.
/// - Note: In Swift, this constant is referred to as `JSONErrorDomain`.
NS_SWIFT_NAME(JSONErrorDomain)
extern NSString * _Nonnull const JCJSONErrorDomain;

/// Error codes for JSON parsing and querying failures.
///
/// These errors are specific to issues encountered when working with JSON data.
typedef NS_ENUM(NSInteger, JCJSONError) {
    /// Error indicating that parsing the JSON failed.
    /// - Swift equivalent: `JSONError.failedToParseJSON`
    JCJSONErrorFailedToParseJSON NS_SWIFT_NAME(failedToParseJSON) = 1001,
    
    /// Error indicating that querying the JSON structure failed.
    /// - Swift equivalent: `JSONError.failedToQueryJSON`
    JCJSONErrorFailedToQueryJSON NS_SWIFT_NAME(failedToQueryJSON),
} NS_SWIFT_NAME(JSONError);

/// The types of JSON values that can be encountered.
///
/// This enum defines the possible types for values in a JSON structure.
typedef NS_CLOSED_ENUM(NSInteger, JCJSONType) {
    /// Represents a `null` value in JSON.
    /// - Swift equivalent: `JSONType.null`
    JCJSONTypeNull NS_SWIFT_NAME(null),
    
    /// Represents a `boolean` value in JSON (`true` or `false`).
    /// - Swift equivalent: `JSONType.boolean`
    JCJSONTypeBool NS_SWIFT_NAME(boolean),
    
    /// Represents an integer value in JSON.
    /// - Swift equivalent: `JSONType.integer`
    JCJSONTypeInteger NS_SWIFT_NAME(integer),
    
    /// Represents a double or floating-point value in JSON.
    /// - Swift equivalent: `JSONType.double`
    JCJSONTypeDouble NS_SWIFT_NAME(double),
    
    /// Represents a string value in JSON.
    /// - Swift equivalent: `JSONType.string`
    JCJSONTypeString NS_SWIFT_NAME(string),
    
    /// Represents an array of values in JSON.
    /// - Swift equivalent: `JSONType.array`
    JCJSONTypeArray NS_SWIFT_NAME(array),
    
    /// Represents an object (or dictionary) in JSON.
    /// - Swift equivalent: `JSONType.object`
    JCJSONTypeObject NS_SWIFT_NAME(object)
} NS_SWIFT_NAME(JSONType);

/// A class representing a parsed JSON structure.
///
/// Instances of this class provide access to the underlying JSON data, and allow
/// querying the structure or retrieving specific values.
///
/// This class is marked as `final` in Swift, meaning it cannot be subclassed.
NS_SWIFT_NAME(JSON) NS_SWIFT_SENDABLE
__attribute__((objc_subclassing_restricted))
@interface JCJSON : NSObject

/// The type of the JSON value (e.g., `null`, `boolean`, `string`, etc.).
///
/// - SeeAlso: `JCJSONType` for the full list of possible types.
@property (assign, readonly) JCJSONType type;

/// The `null` value if this JSON object represents `null`, otherwise `nil`.
@property (strong, readonly, nonnull) id value;

/// The `null` value if this JSON object represents `null`, otherwise `nil`.
@property (strong, readonly, nullable) NSNull *nullValue;

/// The boolean value if this JSON object represents a boolean, otherwise `false`.
@property (assign, readonly) BOOL booleanValue;

/// The integer value if this JSON object represents an integer, otherwise `0`.
@property (assign, readonly) NSInteger integerValue;

/// The double value if this JSON object represents a double, otherwise `0.0`.
@property (assign, readonly) double doubleValue;

/// The string value if this JSON object represents a string, otherwise `nil`.
@property (strong, readonly, nullable) NSString *stringValue;

/// The array of JSON values if this JSON object represents an array, otherwise `nil`.
@property (strong, readonly, nullable) NSArray<JCJSON *> *arrayValue;

/// The dictionary of JSON key-value pairs if this JSON object represents an object, otherwise `nil`.
@property (strong, readonly, nullable) NSDictionary<NSString *, JCJSON *> *objectValue;

/// Unavailable. Use `initWithData:error:` to create an instance.
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initializes a `JCJSON` object with the provided JSON data.
///
/// - Parameters:
///   - data: The raw JSON data to parse.
///   - error: A pointer to an error object that will be set if parsing fails.
/// - Returns: A `JCJSON` instance if parsing is successful, or `nil` if an error occurs.
- (nullable instancetype)initWithData:(nonnull NSData *)data error:(NSError * _Nullable * _Nullable)error;

/// Initializes a `JCJSON` object with the provided JSON string.
///
/// This initializer parses a JSON string into a valid JSON structure and stores it within a `JCJSON` object.
/// The provided `NSString` will be automatically converted to a UTF-8 encoded C string before parsing.
///
/// - Parameters:
///   - string: A valid `NSString` representing JSON data. The string will be converted to a UTF-8 encoded C string
///             for parsing.
///   - error: A pointer to an error object that will be set if parsing the JSON string fails.
///            If an error occurs, `error` will contain detailed information about the issue.
///            Pass `nil` if you do not want to capture any errors.
/// - Returns: A `JCJSON` instance if the string is successfully parsed and initialized, or `nil` if an error occurs.
///
/// - Note: If the JSON string is invalid or cannot be parsed, an `NSError` with the `JCJSONErrorFailedToParseJSON` code
///         will be provided via the error pointer. The error message will include details about the failure.
///
/// - Important: The `NSString` is converted to a UTF-8 encoded C string using the `[NSString UTF8String]` method
///              before being passed to the underlying parser. Ensure the `NSString` is valid and well-formed for this conversion.
- (nullable instancetype)initWithJSONString:(nonnull NSString *)string error:(NSError * _Nullable * _Nullable)error;

/// Creates a `JCJSON` object representing a `null` value in JSON.
///
/// - Returns: A `JCJSON` instance with a `null` value.
+ (nonnull instancetype)null;

/// Initializes a `JCJSON` object with a boolean value.
///
/// - Parameter value: The boolean value (`true` or `false`) to initialize the object with.
/// - Returns: A `JCJSON` instance representing the boolean value.
- (nonnull instancetype)initWithBooleanValue:(BOOL)value;

/// Initializes a `JCJSON` object with an integer value.
///
/// - Parameter value: The integer value to initialize the object with.
/// - Returns: A `JCJSON` instance representing the integer value.
- (nonnull instancetype)initWithIntegerValue:(NSInteger)value;

/// Initializes a `JCJSON` object with a double or floating-point value.
///
/// - Parameter value: The double value to initialize the object with.
/// - Returns: A `JCJSON` instance representing the double value.
- (nonnull instancetype)initWithDoubleValue:(double)value;

/// Initializes a `JCJSON` object with a string value.
///
/// - Parameter value: The string to initialize the object with.
/// - Returns: A `JCJSON` instance representing the string value.
- (nonnull instancetype)initWithStringValue:(nonnull NSString *)value;

/// Initializes a `JCJSON` object with an array of `JCJSON` values.
///
/// - Parameter value: The array of `JCJSON` objects to initialize the object with.
/// - Returns: A `JCJSON` instance representing the array value.
- (nonnull instancetype)initWithArrayValue:(nonnull NSArray<JCJSON *> *)value;

/// Initializes a `JCJSON` object with a dictionary of key-value pairs, where keys are strings and values are `JCJSON` objects.
///
/// - Parameter value: The dictionary of key-value pairs to initialize the object with.
/// - Returns: A `JCJSON` instance representing the object (dictionary) value.
- (nonnull instancetype)initWithObjectValue:(nonnull NSDictionary<NSString *, JCJSON *> *)value;

/// Serializes the JSON structure into `NSData`.
///
/// This method converts the `JCJSON` object into raw JSON data, which can then be saved to a file,
/// transmitted over a network, or processed further. The serialized data is in a format that can be
/// understood by JSON parsers or deserialized back into a `JCJSON` object.
///
/// - Returns: A `NSData` object containing the serialized JSON data.
///            If the JSON structure is invalid or cannot be serialized, this method may return `nil`.
- (nonnull NSData *)serializedData;

/// Queries the JSON structure using a JSONPath query string.
///
/// This method allows you to extract one or more JSON values based on a JSONPath query string.
/// JSONPath is a query language for JSON that enables selecting and filtering elements from a JSON structure.
///
/// - Parameters:
///   - string: A JSONPath query string used to locate the desired JSON values.
///             The query string must conform to JSONPath syntax and may return one or more values.
///   - error: A pointer to an error object that will be set if the query fails.
/// - Returns: The `JCJSON` object representing the result of the query, or `nil` if no match is found or the query is invalid.
///            If the query returns multiple values, they will be represented as a `JCJSONTypeArray`.
///
/// - Example:
///   To query a nested value from the JSON:
///   ```json
///   {
///     "books": [
///       { "title": "Swift Programming" },
///       { "title": "Advanced Swift" }
///     ]
///   }
///   ```
///   Use the following JSONPath query:
///   ```objc
///   [json queryWithString:@"$.books[*].title" error:&error]
///   ```
///   This query would return a `JCJSONTypeArray` containing both titles, "Swift Programming" and "Advanced Swift".
- (nullable JCJSON *)queryWithString:(nonnull NSString *)string error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(query(_:));

@end
