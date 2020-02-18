//
//  ProgramTests.swift
//  ParserTests
//
//  Created by Alexey Demedetskii on 2/18/20.
//  Copyright © 2020 Alexey Demedetskiy. All rights reserved.
//

import XCTest
@testable import Parser

class ProgramTests: XCTestCase {
    var program = Program()
    
    override func setUp() {
        program = Program()
    }
    
    func testStateAppending() throws {
        let counter = StateDefinition(name: "Counter", type: "Int", value: "0")
        try program.append(state: counter)
        
        XCTAssertEqual(program.state[StateIdentifier(name: ["Counter"])], counter)
    }
    
    func testDuplicatedDeclaration() throws {
        let counter = StateDefinition(name: "Counter", type: "Int", value: "0")
        let counter2 = StateDefinition(name: "Counter", type: "Float", value: "10")
        
        try program.append(state: counter)
        XCTAssertThrowsError(try program.append(state: counter2))
    }
    
    func testActionAppending() throws {
        let action = ActionDefinition(name: ["Increment", "by", "value"], type: nil)
        try program.append(action: action)
        
        XCTAssertEqual(program.actions[ActionIdentifier(name: ["Increment", "by", "value"])], action)
    }
    
    func testDuplicatingActionAppending() throws {
        let action = ActionDefinition(name: ["Increment", "by", "value"], type: nil)
        let action2 = ActionDefinition(name: ["Increment", "by", "value"], type: "Int")

        try program.append(action: action)
        XCTAssertThrowsError(try program.append(action: action2))
    }
    
    func testReducerAppending() throws {
        let counter = StateDefinition(name: "Counter", type: "Int", value: "0")
        let action = ActionDefinition(name: ["Increment"], type: nil)
        
        let incrementReducer = SingleReduceDefinition(action: ["Increment"], expressions: [])
        
        let reducer = try StateReducersDefinition(
            state: "Counter",
            reducers: [incrementReducer].asNonEmpty())
        
        try program.append(state: counter)
        try program.append(action: action)
        try program.append(reducer: reducer)
        
        XCTAssertEqual(program.reducers[action.identifier]?[counter.identifier], [incrementReducer])
    }
    
    func testCounterExampleAppending() throws {
        var parser = Parser(stream: Fixture.Counter.tokens)
        let counter = try parser.parseProgram()
        
        try program.append(topLevelDefinitions: counter)
        
        XCTAssertEqual(program.state.count, 1)
        XCTAssertEqual(program.actions.count, 4)
        XCTAssertEqual(program.reducers.count, 4)
    }
}
