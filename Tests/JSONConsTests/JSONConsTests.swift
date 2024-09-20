import Testing
@testable import JSONCons

@Test func parseDataSuccess() async throws {
    #expect(throws: Never.self) {
        try JSON(data: #"{"key": "value"}"#.data(using: .utf8)!)
    }
}

@Test func parseDataFailure() async throws {
    #expect(throws: NSError.self) {
        try JSON(data: #"{"key"}"#.data(using: .utf8)!)
    }
}

@Test func parseStringSuccess() async throws {
    #expect(throws: Never.self) {
        try JSON(jsonString: #"{"key": "value"}"#)
    }
}

@Test func parseStringFailure() async throws {
    #expect(throws: NSError.self) {
        try JSON(jsonString: #"{"key"}"#)
    }
}

@Test func createNull() async throws {
    let json = JSON.null()
    #expect(json.type == .null)
}

@Test func createBooleanTrue() async throws {
    let json = JSON(booleanValue: true)
    #expect(json.type == .boolean)
    #expect(json.booleanValue == true)
}

@Test func createBooleanFalse() async throws {
    let json = JSON(booleanValue: false)
    #expect(json.type == .boolean)
    #expect(json.booleanValue == false)
}

@Test func createInteger() async throws {
    let json = JSON(integerValue: 42)
    #expect(json.type == .integer)
    #expect(json.integerValue == 42)
}

@Test func createDouble() async throws {
    let json = JSON(doubleValue: 1.2)
    #expect(json.type == .double)
    #expect(json.doubleValue == 1.2)
}

@Test func createString() async throws {
    let json = JSON(stringValue: "hello")
    #expect(json.type == .string)
    #expect(json.stringValue == "hello")
}

@Test func createArray() async throws {
    let json = JSON(arrayValue: [
        JSON(stringValue: "a"),
        JSON(stringValue: "b"),
    ])
    #expect(json.type == .array)
    
    let arrayValue = json.arrayValue
    #expect(arrayValue?.count == 2)
    #expect(arrayValue?.first?.stringValue == "a")
    #expect(arrayValue?.last?.stringValue == "b")
}

@Test func createObject() async throws {
    let json = JSON(objectValue: [
        "a": JSON(integerValue: 1),
        "b": JSON(integerValue: 2),
    ])
    #expect(json.type == .object)
    
    let objectValue = json.objectValue
    #expect(objectValue?.count == 2)
    #expect(objectValue?["a"]?.integerValue == 1)
    #expect(objectValue?["b"]?.integerValue == 2)
}

@Test func queryNull() async throws {
    let json = try JSON(data: #"{"key": [0, null]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .null)
    #expect(array?[0].nullValue == NSNull())
}

@Test func queryBool() async throws {
    let json = try JSON(data: #"{"key": [false, true]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .boolean)
    #expect(array?[0].booleanValue == true)
}

@Test func queryNegativeInteger() async throws {
    let json = try JSON(data: #"{"key": [-1, -2, -3]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .integer)
    #expect(array?[0].integerValue == -2)
}

@Test func queryPositiveInteger() async throws {
    let json = try JSON(data: #"{"key": [1, 2, 3]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .integer)
    #expect(array?[0].integerValue == 2)
}

@Test func queryDouble() async throws {
    let json = try JSON(data: #"{"key": [1.0, 2.0, 3.0]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .double)
    #expect(array?[0].doubleValue == 2.0)
}

@Test func queryString() async throws {
    let json = try JSON(data: #"{"key": ["a", "b", "c"]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .string)
    #expect(array?[0].stringValue == "b")
}

@Test func queryArray() async throws {
    let json = try JSON(data: #"{"key": [["a"], ["b"], ["c"]]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .array)
    
    let arrayValue = array?[0].arrayValue
    #expect(arrayValue?.count == 1)
    #expect(arrayValue?.first?.type == .string)
    #expect(arrayValue?.first?.stringValue == "b")
}

@Test func queryObject() async throws {
    let json = try JSON(data: #"{"key": [{"a": 1}, {"b": 2}]}"#.data(using: .utf8)!)
    let result = try json.query("$.key[1]")
    #expect(result.type == .array)
    
    let array = result.arrayValue
    #expect(array?.count == 1)
    #expect(array?[0].type == .object)
    
    let objectValue = array?[0].objectValue
    #expect(objectValue?.count == 1)
    #expect(objectValue?.keys.first == "b")
    #expect(objectValue?.values.first?.type == .integer)
    #expect(objectValue?.values.first?.integerValue == 2)
}

@Test func equalNull() async throws {
    let a = JSON.null()
    let b = JSON.null()
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func equalBooleanTrue() async throws {
    let a = JSON(booleanValue: true)
    let b = JSON(booleanValue: true)
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func equalBooleanFalse() async throws {
    let a = JSON(booleanValue: false)
    let b = JSON(booleanValue: false)
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualBoolean() async throws {
    let a = JSON(booleanValue: true)
    let b = JSON(booleanValue: false)
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func equalInteger() async throws {
    let a = JSON(integerValue: 4)
    let b = JSON(integerValue: 4)
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualInteger() async throws {
    let a = JSON(integerValue: 4)
    let b = JSON(integerValue: 5)
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func equalDouble() async throws {
    let a = JSON(doubleValue: 1.2)
    let b = JSON(doubleValue: 1.2)
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualDouble() async throws {
    let a = JSON(doubleValue: 1.2)
    let b = JSON(doubleValue: 2.1)
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func equalString() async throws {
    let a = JSON(stringValue: "Hello")
    let b = JSON(stringValue: "Hello")
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualString() async throws {
    let a = JSON(stringValue: "Hello")
    let b = JSON(stringValue: "Goodbye")
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func equalArray() async throws {
    let a = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "World"),
    ])
    let b = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "World"),
    ])
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualArray() async throws {
    let a = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "World"),
    ])
    let b = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "Goodbye"),
    ])
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func equalObject() async throws {
    let a = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "World"),
    ])
    let b = JSON(arrayValue: [
        JSON(stringValue: "Hello"),
        JSON(stringValue: "World"),
    ])
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualObject() async throws {
    let a = JSON(objectValue: [
        "a": JSON(stringValue: "Hello"),
        "b": JSON(stringValue: "World"),
    ])
    let b = JSON(objectValue: [
        "a": JSON(stringValue: "Hello"),
        "b": JSON(stringValue: "Goodbye"),
    ])
    #expect(a != b)
    #expect(a.hashValue != b.hashValue)
}

@Test func notEqualDeepArray() async throws {
    let a = JSON(arrayValue: [
        JSON(arrayValue: [
            JSON(integerValue: 1),
            JSON(integerValue: 2),
        ]),
        JSON(arrayValue: [
            JSON(integerValue: 3),
            JSON(integerValue: 4),
        ])
    ])
    let b = JSON(arrayValue: [
        JSON(arrayValue: [
            JSON(integerValue: 5),
            JSON(integerValue: 6),
        ]),
        JSON(arrayValue: [
            JSON(integerValue: 7),
            JSON(integerValue: 8),
        ])
    ])
    #expect(a != b)
    #expect(a.hashValue == b.hashValue)
}

@Test func notEqualDeepObject() async throws {
    let a = JSON(objectValue: [
        "a": JSON(objectValue: [
            "c": JSON(integerValue: 1),
            "d": JSON(integerValue: 2),
        ]),
        "b": JSON(objectValue: [
            "e": JSON(integerValue: 3),
            "f": JSON(integerValue: 4),
        ])
    ])
    let b = JSON(objectValue: [
        "a": JSON(objectValue: [
            "c": JSON(integerValue: 5),
            "d": JSON(integerValue: 6),
        ]),
        "b": JSON(objectValue: [
            "e": JSON(integerValue: 7),
            "f": JSON(integerValue: 8),
        ])
    ])
    #expect(a != b)
    #expect(a.hashValue == b.hashValue)
}
