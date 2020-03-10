import XCTest
@testable import Parser

class InterpreterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStandaloneReduce() {
        let interpreter = Interpreter(program: Fixture.Counter.program)
        
        var state = StateValue(type: "Int", value: "1")
        let action = ActionValue(
            type: ActionIdentifier(name: ["Increment"]),
            payload: ActionPayload(value: "2"))
        
        
        let actionReducer = SingleReduceDefinition(
            action: ["Increment"],
            expressions: [
                ExpressionDefintion(operator: .increment, value: .action)
        ])
        
        interpreter.reduce(state: &state, action: action, reducer: actionReducer)
        
        XCTAssertEqual(state.value, "3")
        
        interpreter.reduce(state: &state, action: action, reducer: actionReducer)
        
        XCTAssertEqual(state.value, "5")
        
        let identifierReducer = SingleReduceDefinition(
            action: ["Increment"],
            expressions: [
                ExpressionDefintion(operator: .decrement, value: .identifier("1"))
        ])
        
        interpreter.reduce(state: &state, action: action, reducer: identifierReducer)
        
        XCTAssertEqual(state.value, "4")
    }
    
    func testIncrement() throws {
        let interpreter = Interpreter(program: Fixture.Counter.program)
        
        var counterValue: String {
            interpreter.state[StateIdentifier(name: ["Counter"])]!.value
        }
        
        let increment = ActionValue(type: ActionIdentifier(name: ["Increment"]), payload: nil)
        let decrement = ActionValue(type: ActionIdentifier(name: ["Decrement"]), payload: nil)
        
        let incrementByValue = ActionValue(
            type: ActionIdentifier(name: ["Increment", "by", "value"]),
            payload: ActionPayload(value: "10"))
        
        let decrementByValue = ActionValue(
            type: ActionIdentifier(name: ["Decrement", "by", "value"]),
            payload: ActionPayload(value: "5"))
        
        XCTAssertEqual("0", counterValue)
        
        try interpreter.dispatch(action: increment)
        XCTAssertEqual("1", counterValue)
        
        try interpreter.dispatch(action: incrementByValue)
        XCTAssertEqual("11", counterValue)
        
        try interpreter.dispatch(action: decrementByValue)
        XCTAssertEqual("6", counterValue)
        
        try interpreter.dispatch(action: decrement)
        XCTAssertEqual("5", counterValue)
    }

    func testPerformanceExample() {
        let interpreter = Interpreter(program: Fixture.Counter.program)
        let increment = ActionValue(type: ActionIdentifier(name: ["Increment"]), payload: nil)
        
        self.measure {
            for _ in 0...1000 {
                try! interpreter.dispatch(action: increment)
            }
        }
    }

}
