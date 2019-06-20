# Tablier

[![Build Status](https://travis-ci.com/akkyie/Tablier.svg?branch=master)](https://travis-ci.com/akkyie/Tablier)
[![codecov](https://codecov.io/gh/akkyie/Tablier/branch/master/graph/badge.svg)](https://codecov.io/gh/akkyie/Tablier)

A micro-framework for [*Table Driven Tests*](https://github.com/golang/go/wiki/TableDrivenTests).

![A screenshot to see how it works](https://user-images.githubusercontent.com/1528813/59867231-9b508b00-93c8-11e9-8489-127d441c2a5b.png)

## Features

- ☑️ Dead simple syntax
- ☑️ Run async tests in parallel
- ☑️ No additional dependency aside from XCTest
- ️️☑️ Use with Quick, or any other XCTest-based testing framework
- ☑️ Fully tested

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/akkyie/Tablier", from: "0.0.1")
```

CocoaPods and Carthage installation will soon be supported.

### Usage

You can define a *test recipe* to test your classes, structs or functions.

```swift
final class MyParseTests: XCTestCase {
    func testMyParse() {
        let recipe = Recipe<String, Int>(sync: { input in
            // `myParse` here is what you want to test
            let output: Int = try myParse(input) // test fails if an error is thrown
            return output
        })

...
```

Then you can list inputs and expected outputs for the recipe, to run the actual test for it.

```swift
...

        recipe.assert(with: self) {
            $0.when("1").expect(1)
            $0.when("1234567890").expect(1234567890)
            $0.when("-0x42").expect(-0x42)
        }
    }
}
```

Defining a recipe with async functions is also supported.

```swift
let recipe = Recipe<String, Int>(async: { input, complete in
    myComplexAndSlowParse(input) { (result: Int?, error: Error?) in
        complete(result, error)
    }
})
```

#### Note
When an error is thrown in sync initalizer,  or the completion handler is called with an error, the test case is considered as failed for now. Testing errors will be supported in future.

### Examples

- [SyncExample.swift](/akkyie/Tablier/blob/master/Examples/Tests/ExampleTests/SyncExample.swift): A simple example with a sync function.
- [AsyncExample.swift](/akkyie/Tablier/blob/master/Examples/Tests/ExampleTests/AsyncExample.swift): An example with an async function.
- [RxTestExample.swift](/akkyie/Tablier/blob/master/Examples/Tests/ExampleTests/RxTestExample.swift): A more real-world-ish example. Test a view model, with RxSwift and RxTest.
- [QuickExample.swift](/akkyie/Tablier/blob/master/Examples/Tests/ExampleTests/QuickExample.swift): An example to show Tablier works in a QuickSpec with no hassle.

### License
MIT. See LICENSE.