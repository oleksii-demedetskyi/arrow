import XCTest
@testable import Parser

extension StateIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let components = value.components(separatedBy: " ")
        self = StateIdentifier(name: components.map { Substring($0)})
    }
}

extension TestIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        if value.isEmpty {
            self = TestIdentifier(name: [])
        } else {
            let components = value.components(separatedBy: " ")
            self = TestIdentifier(name: components.map { Substring($0)})
        }
    }
}

class TestInterpeterTests: XCTestCase {
    func testExample() {
        let program = Fixture.Counter.program
        
        let testInterpreter = TestInterpreter(program: program)
        var actualResults = testInterpreter.runAllTests()
        
        let expectedResults = TestInterpreter.Results(tests: [
            "Counter" : [
                "": .ok,
                "Simple increment": .ok,
                "Symmetric actions": .ok,
                "Increment by value": .ok,
            ]
        ])
        
        for (state, expectedStateResults) in expectedResults.tests {
            guard var actualStateResults = actualResults.tests[state] else {
                XCTFail("Missing \(state) in results")
                continue
            }
            
            for (testName, expectedTestResult) in expectedStateResults {
                guard let actualTestResult = actualStateResults[testName] else {
                    XCTFail("Missing \(testName) in results")
                    continue
                }
                
                XCTAssertEqual(actualTestResult, expectedTestResult)
                
                actualStateResults[testName] = nil
            }
            
            actualResults.tests[state] = nil
            
            guard actualStateResults.isEmpty else {
                XCTFail("Extra tests: \(actualStateResults)")
                continue
            }
        }
        
        guard actualResults.tests.isEmpty else {
            XCTFail("Extra states: \(actualResults.tests)")
            return
        }
    }
}
