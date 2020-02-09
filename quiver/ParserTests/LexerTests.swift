import XCTest
@testable import Parser



class LexerTests: XCTestCase {
    func testTrivial() {
        let lexemes = Lexer(string: "action Increment").scan()
        
        XCTAssertEqual(lexemes.count, 2)
        XCTAssertEqual(lexemes[0].token, .action)
        XCTAssertEqual(lexemes[1].token, "Increment")
    }
    
    func testCounterExample() {
        let example = Fixture.Counter.text
        var actualTokens = Lexer(string: example).scan().map { $0.token }
        var expectedTokens = Fixture.Counter.tokens
        
        
        while !actualTokens.isEmpty {
            XCTAssertEqual(actualTokens.removeFirst(), expectedTokens.removeFirst())
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            testCounterExample()
        }
    }

}
