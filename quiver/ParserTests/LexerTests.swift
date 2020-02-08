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
        let example = """
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
        """
        
        var actualTokens = Lexer(string: example).scan().map { $0.token }
        
        var expectedTokens = [
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
        ] as [Token]
        
        
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
