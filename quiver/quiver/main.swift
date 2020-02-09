import Foundation
@testable import Parser

let filePath = CommandLine.arguments[1]

var file = try String(contentsOfFile: filePath)

let lexer = Lexer(string: file)
let lexems = lexer.scan()
let tokens = lexems.map { $0.token }
var parser = TokenStream(stream: tokens)
let ast = try parser.parseProgram()

dump(file)
dump(tokens)
dump(ast)
