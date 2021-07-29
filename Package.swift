// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//@f:0
let package = Package(
    name: "Chadakoin",
    platforms: [ .macOS(.v10_15), .tvOS(.v13), .iOS(.v13), .watchOS(.v6), ],
    products: [ .library(name: "Chadakoin", targets: [ "Chadakoin", ]), ],
    dependencies: [],
    targets: [
        .target(name: "Chadakoin", dependencies: [ "Rubicon", ], exclude: [ "Info.plist", ]),
        .testTarget(name: "ChadakoinTests", dependencies: [ "Chadakoin", ], exclude: [ "Info.plist", ]),
    ]
)
//@f:1
