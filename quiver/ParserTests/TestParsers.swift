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
        
        XCTAssertTrue(stream.parseKeyword(.action))
        XCTAssertEqual(stream.parseIdentifier(), "Increment")
    }
    
    func testOneOfKeywordsParser() {
        var stream = TokenStream(stream: [
            .action, .equals, .state
        ])
        
        XCTAssertFalse(stream.parseOneOfKeywords(.plus, .minus))
        XCTAssertTrue(stream.parseOneOfKeywords(.action, .state))
        stream.rollback()
        XCTAssertTrue(stream.parseOneOfKeywords(.state, .equals, .action))
        
        XCTAssertEqual(stream.current, .equals)
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
    
    func testStateDefinitinSuccess() throws {
        var stream = TokenStream(stream: [
            .state, .identifier("Counter"),
            .colon, .identifier("Int"),
            .equals, .identifier("0")
        ])
        
        let definition = try stream.parseStateDefinition()
        
        XCTAssertEqual(definition?.name, "Counter")
        XCTAssertEqual(definition?.type, "Int")
        XCTAssertEqual(definition?.value, "0")
    }
    
    func testReduceDefinitionParserSuccess() throws {
        var stream = TokenStream(stream: [
            .reduce, .identifier("Counter"),
            .with, .identifier("Increment"), .openCurlyBrace,
            .state, .plus, .equals, .identifier("1"),
            .closedCurlyBrace
        ])
        
        let definition = try stream.parseReduceDefinition()
        
        XCTAssertEqual(definition?.state, "Counter")
        XCTAssertEqual(definition?.action, "Increment")
    }
    
    func testStateAssertExpressionParserSuccess() throws {
        var stream = TokenStream(stream: [
            .assert, .state, .is, .identifier("0")
        ])
        
        let definition = try stream.parseStateAssertExpression()
        
        XCTAssertEqual(definition?.value, "0")
    }
    
    func testStateAssignmentParserSuccess() throws {
        var stream = TokenStream(stream: [
            .state, .equals, .identifier("10")
        ])
        
        let definition = try stream.parseStateAssignmentExpression()
        
        XCTAssertEqual(definition?.value, "10")
    }
    
    func testReduceExpressionSuccess() throws {
        var stream = TokenStream(stream: [
            .reduce, .identifier("Increment")
        ])
        
        let definition = try stream.parseTestReduceExpression()
        
        XCTAssertEqual(definition?.action, "Increment")
    }
    
    ///```
    ///assert state is 0
    ///state = 10
    ///reduce Increment
    ///assert state is 11
    ///```
    func testTestExpressionParserSuccess() throws {
        var stream = TokenStream(stream: [
            .assert, .state, .is, .identifier("0"),
            .state, .equals, .identifier("10"),
            .reduce, .identifier("Increment"),
            .assert, .state, .is, .identifier("11")
        ])
        
        XCTAssertEqual(try stream.parseTestExpression(), .assertState(.init(value: "0")))
        XCTAssertEqual(try stream.parseTestExpression(), .assignState(.init(value: "10")))
        XCTAssertEqual(try stream.parseTestExpression(), .reduceExpression(.init(action: "Increment")))
        XCTAssertEqual(try stream.parseTestExpression(), .assertState(.init(value: "11")))
    }
}
