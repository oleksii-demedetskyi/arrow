import XCTest
@testable import Parser

/*
 action Increment
 action Decrement

 state Counter: Int = 0

 reduce Counter with Increment {
   state += 1
 }

 reduce Counter with Decrement {
   state -= 1
 }

 test Simple increment for Counter {
   assert state is 0
   state = 10
   reduce Increment
   assert state is 11
 }

 test for Counter {
   reduce Decrement
   assert state is -1
 }

 test Symmetric actions for Counter {
   reduce Increment
   reduce Decrement
   
   assert state is 0
 }


 action Increment by value: Int
 action Decrement by value: Int

 reduce Counter {
   with Increment by value {
     state += action
   }
   
   with Decrement by value {
     state -= action
   }
 }

 test Increment by value for Counter {
   reduce Increment
   reduce Increment by value: 10
   assert state is 11
 }
 */

class ParserIntegratedTest: XCTestCase {
    let counter = TokenStream(stream: [
        .action, "Increment",
        .action, "Decrement",
        
        .state, "Counter", .colon, "Int", .equals, "0",
        
        .reduce, "Counter", .with, "Increment", .openCurlyBrace,
            .state, .plus, .equals, "1",
        .closedCurlyBrace,
        
        .reduce, "Counter", .with, "Decrement", .openCurlyBrace,
            .state, .minus, .equals, "1",
        .closedCurlyBrace,
        
        .test, "Simple", "increment", .for, "Counter", .openCurlyBrace,
            .assert, .state, .is, "0",
            .state, .equals, "10",
            .reduce, "Increment",
            .assert, .state, .is, "11",
        .closedCurlyBrace,
        
        .test, .for, "Counter", .openCurlyBrace,
            .reduce, "Decrement",
            .assert, .state, .is, .minus, "1",
        .closedCurlyBrace,
        
        .test, "Symmetric", "actions", .for, "Counter", .openCurlyBrace,
            .reduce, "Increment",
            .reduce, "Decrement",
            .assert, .state, .is, "0",
        .closedCurlyBrace,
        
        .action, "Increment", "by", "value", .colon, "Int",
        .action, "Decrement", "by", "value", .colon, "Int",
        
        .reduce, "Counter", .openCurlyBrace,
            .with, "Increment", "by", "value", .openCurlyBrace,
                .state, .plus, .equals, .action,
            .closedCurlyBrace,
            
            .with, "Decrement", "by", "value", .openCurlyBrace,
                .state, .minus, .equals, .action,
            .closedCurlyBrace,
        .closedCurlyBrace,
        
        .test, "Increment", "by", "value", .for, "Counter", .openCurlyBrace,
            .reduce, "Increment",
            .reduce, "Increment", "by", "value", .colon, "10",
            .assert, .state, .is, "11",
        .closedCurlyBrace
    ])
    
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
