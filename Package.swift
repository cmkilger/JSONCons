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
                "jsoncons",
            ],
            cSettings: [
                .headerSearchPath("jsoncons/include"),
            ]
        ),
        .testTarget(
            name: "JSONConsTests",
            dependencies: [
                "JSONCons",
            ]
        ),
    ],
    cxxLanguageStandard: .cxx11
)
