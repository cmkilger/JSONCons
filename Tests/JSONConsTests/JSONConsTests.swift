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
