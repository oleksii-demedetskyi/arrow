import XCTest
@testable import Parser

class Integrations: XCTestCase {
    func testPerformanceExample() {
        self.measure {
            let lexer = Lexer(string: Fixture.Counter.text)
            let lexems = lexer.scan()
            let tokens = lexems.map { $0.token }
            var parser = TokenStream(stream: tokens)
            let ast = try? parser.parseProgram()
            
            XCTAssertNotNil(ast)
        }
    }

}
