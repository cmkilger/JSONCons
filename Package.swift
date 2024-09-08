// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "JSONCons",
    products: [
        .library(
            name: "JSONCons",
            targets: [
                "JSONCons",
            ]
        ),
    ],
    targets: [
        .target(
            name: "JSONCons",
            exclude: [
                "jsoncons"
            ],
            cxxSettings: [
                .unsafeFlags(["-std=c++11"]),
                .headerSearchPath("jsoncons/include"),
            ]
        ),
        .testTarget(
            name: "JSONConsTests",
            dependencies: [
                "JSONCons",
            ]
        ),
    ]
)
