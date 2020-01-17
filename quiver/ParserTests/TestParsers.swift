import XCTest
@testable import Parser

class TestParser: XCTestCase {
    func testIdentifierParserFail() {
        var stream = TokenStream(stream: [.action])
        
        XCTAssertNil(stream.parseIdentifier())
        XCTAssertEqual(stream.current, .action)
    }
    
    func testIdentifierParserSuccess() {
        var stream = TokenStream(stream: [.identifier("test"), .action])
        
        XCTAssertEqual(stream.parseIdentifier(), "test")
        XCTAssertEqual(stream.current, .action)
    }
    
    func testActionParser() {
        var stream = TokenStream(stream: [
            .action, .identifier("Increment")]
        )
        
        XCTAssertTrue(stream.parseActionKeyword())
        XCTAssertEqual(stream.parseIdentifier(), "Increment")
    }
    
    func testActionDefinitionParserSuccess() throws {
        var stream = TokenStream(stream: [
            .action, .identifier("Increment")
        ])
        
        let definition = try stream.parseActionDefinition()
        XCTAssertEqual(definition?.identifier, "Increment")
    }
    
    func testActionDefinitionNotDetectAction() {
        var stream = TokenStream(stream: [
            .identifier("Increment")
        ])
        
        XCTAssertNil(try stream.parseActionDefinition())
    }
    
    func testActionDefinitionUnableToConstruct() {
        var stream = TokenStream(stream: [
            .action, .action, .identifier("Increment")
        ])
        
        XCTAssertThrowsError(try stream.parseActionDefinition())
    }
}
