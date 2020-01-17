import XCTest
@testable import Parser

class TestTokenStream: XCTestCase {
    func testInitialCurrentItem() {
        let tokens: [Token] = [.identifier("Hello stream"), .action]
        let stream = TokenStream(stream: tokens)
        
        XCTAssertEqual(stream.current, tokens.first)
        XCTAssertNotEqual(stream.current, tokens.last)
    }
    
    func testEmptyInitialStream() {
        let stream = TokenStream(stream: [])
        
        XCTAssertNoThrow(stream.current)
        XCTAssertNil(stream.current)
    }
    
    func testConsumingToken() {
        var stream = TokenStream(stream:
            [.identifier("Hello stream"), .action]
        )
        
        stream.consume()
        XCTAssertEqual(stream.current, .action)
        
        stream.consume()
        XCTAssertNil(stream.current)
    }
    
    /// Consume and rollback right now are just +1 and -1.
    /// I believe it is not right but will work for now.
    func testRollback() {
        var stream = TokenStream(stream:
            [.identifier("Hello stream"), .action]
        )
        
        XCTAssertEqual(stream.current, .identifier("Hello stream"))
        stream.consume()
        stream.rollback()
        XCTAssertEqual(stream.current, .identifier("Hello stream"))
        
        stream.rollback()
        XCTAssertNil(stream.current)
        stream.consume()
        XCTAssertEqual(stream.current, .identifier("Hello stream"))
    }
}
