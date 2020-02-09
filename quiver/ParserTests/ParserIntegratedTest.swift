import XCTest
@testable import Parser

class ParserIntegratedTest: XCTestCase {
    let counter = TokenStream(stream: Fixture.Counter.tokens)
    
    func testCounterExample() throws {
        var stream = counter
        
        var parsedProgram = try stream.parseProgram()
        
        func check(_ definition: TopLevelDefinition, line: UInt = #line) {
            XCTAssertEqual(parsedProgram.removeFirst(), definition, line: line)
        }
        
        check(.action(ActionDefinition(identifier: ["Increment"], type: nil)))
        check(.action(ActionDefinition(identifier: ["Decrement"], type: nil)))
        check(.state(StateDefinition(name: "Counter", type: "Int", value: "0")))
        
        check(.reduce(StateReducersDefinition(
            state: "Counter",
            reducers: [SingleReduceDefinition(
                action: ["Increment"],
                expressions: [ExpressionDefintion(
                    operator: .increment,
                    value: .identifier("1"))])])))
        
        check(.reduce(StateReducersDefinition(
            state: "Counter",
            reducers: [SingleReduceDefinition(
                action: ["Decrement"],
                expressions: [ExpressionDefintion(
                    operator: .decrement,
                    value: .identifier("1"))])])))
        
        check(.test(TestDefinition(
            name: ["Simple", "increment"],
            state: "Counter",
            expressions: [
                .assertState(StateAssertExpression(
                    value: ValueDefinition(sign: nil, value: "0"))),
                .assignState(StateAssignmentExpression(
                    value: ValueDefinition(sign: nil, value: "10"))),
                .reduceExpression(ReduceExpression(
                    action: ["Increment"],
                    value: nil)),
                .assertState(StateAssertExpression(
                    value: ValueDefinition(sign: nil, value: "11")))])))
        
        check(.test(TestDefinition(
            name: [],
            state: "Counter",
            expressions: [
                .reduceExpression(ReduceExpression(action: ["Decrement"], value: nil)),
                .assertState(StateAssertExpression(
                    value: ValueDefinition(sign: .minus, value: "1")))])))
        
        check(.test(TestDefinition(
            name: ["Symmetric", "actions"],
            state: "Counter",
            expressions: [
                .reduceExpression(ReduceExpression(action: ["Increment"], value: nil)),
                .reduceExpression(ReduceExpression(action: ["Decrement"], value: nil)),
                .assertState(StateAssertExpression(
                    value: ValueDefinition(sign: nil, value: "0")))])))
        
        check(.action(ActionDefinition(
            identifier: ["Increment", "by", "value"], type: "Int")))
        
        check(.action(ActionDefinition(
            identifier: ["Decrement", "by", "value"], type: "Int")))
        
        check(.reduce(StateReducersDefinition(
            state: "Counter",
            reducers: [
                SingleReduceDefinition(
                    action: ["Increment", "by", "value"],
                    expressions: [ExpressionDefintion(
                        operator: .increment,
                        value: .action)]),
                SingleReduceDefinition(
                action: ["Decrement", "by", "value"],
                expressions: [ExpressionDefintion(
                    operator: .decrement,
                    value: .action)])
        ])))
        
        check(.test(TestDefinition(
            name: ["Increment", "by", "value"],
            state: "Counter",
            expressions: [
                .reduceExpression(ReduceExpression(action: ["Increment"], value: nil)),
                .reduceExpression(ReduceExpression(
                    action: ["Increment", "by", "value"],
                    value: "10")),
                .assertState(StateAssertExpression(value:
                    ValueDefinition(sign: nil, value: "11")))
        ])))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            for _ in 0...1000 { try! testCounterExample() }
        }
    }
}
