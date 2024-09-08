# JSONCons

**JSONCons** is a Swift package for working with JSON data using Objective-C and Swift. It provides an easy way to parse, query, and extract values from JSON structures using JSONPath queries.

This package includes an Objective-C class, `JCJSON`, which represents a parsed JSON structure and allows for efficient querying and manipulation of JSON data.

## Features

- Parse JSON data into a structured format.
- Query JSON using **JSONPath** expressions.
- Extract individual or multiple values from JSON.

## Installation

To include JSONCons in your Swift project, add the following to your `Package.swift`:

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "YourProjectName",
    dependencies: [
        .package(url: "https://github.com/cmkilger/JSONCons.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "YourProjectName",
            dependencies: [
                "JSONCons",
            ]
        ),
    ]
)
```

Then run `swift build` to download and compile the package.

## Usage

Here's an example of how to use **JSONCons** to parse JSON and query values using JSONPath expressions.

### Parsing JSON

You can initialize a `JSON` object with raw JSON data:

```swift
import Foundation
import JSONCons

// Sample JSON data
let jsonData = """
{
    "store": {
        "book": [
            { "title": "Swift Programming" },
            { "title": "Advanced Swift" }
        ]
    }
}
""".data(using: .utf8)!

do {
    let json = try JSON(data: jsonData)
    // Successfully parsed JSON
} catch {
    print("Failed to parse JSON: \(error.localizedDescription)")
}
```

### Querying JSON with JSONPath

Once you have a JSON object, you can use JSONPath to query specific values from the JSON structure.

```swift
do {
    let json = try JSON(data: jsonData)
    
    // Querying JSONPath for book titles
    if let result = try json.query("$.store.book[*].title") {
        if result.type == .array {
            for item in result.arrayValue ?? [] {
                print("Title: \(item.stringValue ?? "Unknown")")
            }
        }
    }
} catch {
    print("Query failed: \(error.localizedDescription)")
}
```

In the above example:

* The JSONPath query `$.store.book[*].title` retrieves all the titles from the books array.
* The result is an array of JSON objects, each representing a title.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.