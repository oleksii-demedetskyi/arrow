import XCTest
@testable import Parser

class TestParser: XCTestCase {
    func testIdentifierParserFail() {
        var stream = Parser(stream: [.action])
        
        XCTAssertNil(stream.parseIdentifier())
        XCTAssertEqual(stream.current, .action)
    }
    
    func testIdentifierParserSuccess() {
        var stream = Parser(stream: [.identifier("test"), .action])
        
        XCTAssertEqual(stream.parseIdentifier(), "test")
        XCTAssertEqual(stream.current, .action)
    }
    
    func testActionParser() {
        var stream = Parser(stream: [
            .action, .identifier("Increment")]
        )
        
        XCTAssertTrue(stream.parseKeyword(.action))
        XCTAssertEqual(stream.parseIdentifier(), "Increment")
    }
    
    func testOneOfKeywordsParser() {
        var stream = Parser(stream: [
            .action, .equals, .state
        ])
        
        XCTAssertFalse(stream.parseOneOfKeywords(.plus, .minus))
        XCTAssertTrue(stream.parseOneOfKeywords(.action, .state))
        stream.rollback()
        XCTAssertTrue(stream.parseOneOfKeywords(.state, .equals, .action))
        
        XCTAssertEqual(stream.current, .equals)
    }
    
    func testActionDefinitionParserSuccess() throws {
        var stream = Parser(stream: [
            .action, .identifier("Increment")
        ])
        
        let definition = try stream.parseActionDefinition()
        XCTAssertEqual(definition?.name, ["Increment"])
    }
    
    func testActionDefinitionNotDetectAction() {
        var stream = Parser(stream: [
            .identifier("Increment")
        ])
        
        XCTAssertNil(try stream.parseActionDefinition())
    }
    
    func testActionDefinitionUnableToConstruct() {
        var stream = Parser(stream: [
            .action, .action, .identifier("Increment")
        ])
        
        XCTAssertThrowsError(try stream.parseActionDefinition())
    }
    
    func testStateDefinitinSuccess() throws {
        var stream = Parser(stream: [
            .state, .identifier("Counter"),
            .colon, .identifier("Int"),
            .equals, .identifier("0")
        ])
        
        let definition = try stream.parseStateDefinition()
        
        XCTAssertEqual(definition?.name, "Counter")
        XCTAssertEqual(definition?.type, "Int")
        XCTAssertEqual(definition?.value, "0")
    }
    
    func testStateAssertExpressionParserSuccess() throws {
        var stream = Parser(stream: [
            .assert, .state, .is, .identifier("0")
        ])
        
        let definition = try stream.parseStateAssertExpression()
        
        XCTAssertEqual(definition?.value.value, "0")
    }
    
    func testStateAssignmentParserSuccess() throws {
        var stream = Parser(stream: [
            .state, .equals, .identifier("10")
        ])
        
        let definition = try stream.parseStateAssignmentExpression()
        
        XCTAssertEqual(definition?.value.value, "10")
    }
    
    func testReduceExpressionSuccess() throws {
        var stream = Parser(stream: [
            .reduce, .identifier("Increment")
        ])
        
        let definition = try stream.parseTestReduceExpression()
        
        XCTAssertEqual(definition?.action, ["Increment"])
    }
    
    ///```
    ///assert state is 0
    ///state = 10
    ///reduce Increment
    ///assert state is 11
    ///```
    func testTestExpressionParserSuccess() throws {
        var stream = Parser(stream: [
            .assert, .state, .is, .identifier("0"),
            .state, .equals, .identifier("10"),
            .reduce, .identifier("Increment"),
            .assert, .state, .is, .identifier("11")
        ])
        
        XCTAssertEqual(try stream.parseTestExpression(), .assertState(.init(value: .init(sign: nil, value: "0"))))
        XCTAssertEqual(try stream.parseTestExpression(), .assignState(.init(value: .init(sign: nil, value: "10"))))
        XCTAssertEqual(try stream.parseTestExpression(), .reduceExpression(.init(action: ["Increment"], value: nil)))
        XCTAssertEqual(try stream.parseTestExpression(), .assertState(.init(value: .init(sign: nil, value: "11"))))
    }
    
    func testUnnamedTest() throws {
        var stream = Parser(stream: [
            .test, .for, .identifier("Counter"),
            .openCurlyBrace,
            .reduce, .identifier("Increment"),
            .reduce, .identifier("Decrement"),
            .assert, .state, .is, .identifier("-1"), // Negative number will come shortly,
            .closedCurlyBrace
        ])
        
        let definition = try stream.parseTestDefinition()
        
        XCTAssertEqual(definition?.state, "Counter")
        XCTAssertEqual(definition?.name, [])
    }
    
    func testValueDefinitionParser() {
        var stream = Parser(stream: [
            .identifier("100"),
            .minus, .identifier("0"),
            .plus, .identifier("asd")
        ])
        
        XCTAssertEqual(stream.parseValue(), ValueDefinition(sign: nil, value: "100"))
        XCTAssertEqual(stream.parseValue(), ValueDefinition(sign: .minus, value: "0"))
        XCTAssertEqual(stream.parseValue(), ValueDefinition(sign: .plus, value: "asd"))
    }
    
    func testValueDefinitionParserRollback() {
        var stream = Parser(stream: [
            .minus, .test
        ])
        
        XCTAssertNil(stream.parseValue())
        XCTAssertEqual(stream.current, .minus)
    }
    
    func testActionWithTypeParserSucces() throws {
        /// `action Increment by value: Int`
        var stream = Parser(stream: [
            .action, .identifier("Increment"), .identifier("by"), .identifier("value"),
            .colon, .identifier("Int")
        ])
        
        let definition = try stream.parseActionDefinition()
        
        XCTAssertEqual(definition?.name, ["Increment", "by", "value"])
        XCTAssertEqual(definition?.type, "Int")
    }
    
    func testPartialReducerDefinition() throws {
        var stream = Parser(stream: [
            .reduce, .identifier("Counter"), .openCurlyBrace,
                .with, .identifier("Increment"), .identifier("by"), .identifier("value"),
                    .openCurlyBrace, .state, .plus, .equals, .action, .closedCurlyBrace,
                .with, .identifier("Decrement"), .identifier("by"), .identifier("value"),
                    .openCurlyBrace, .state, .minus,. equals, .action, .closedCurlyBrace,
            .closedCurlyBrace
        ])
        
        let definition = try stream.parseStateReducersDefinition()
        
        XCTAssertNotNil(definition)
        XCTAssertEqual(definition?.state, "Counter")
        XCTAssertEqual(definition?.reducers.count, 2)
        
        let reducers = definition!.reducers
        
        XCTAssertEqual(reducers.first!.action, ["Increment", "by", "value"])
    }
    
    func testReduceCompoundActionInTestDefinition() throws {
        var stream = Parser(stream: [
            .reduce, "Increment", "by", "value", .colon, "10"
        ])
        
        let expression = try stream.parseTestReduceExpression()
        
        XCTAssertNil(stream.current)
        XCTAssertEqual(expression?.action, ["Increment", "by", "value"])
        XCTAssertEqual(expression?.value, "10")
    }
}
