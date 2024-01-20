enum Lexeme {
    
    enum LexemeError: Error {
        case noLexemeFound
    }
    
    case variableDeclaration
    case constantDeclaration
    case operatorAssignment
    case literalIntegers(value:Int)
    case identifier(name: String)

    static func nextLexeme(from line: String) throws -> (lexeme: Lexeme,
                                                         text: Substring,
                                                         charactersConsumed: Int){
        
        if let match = try /\s*var\s/.predfixMatch(in: line) {
            return (lexeme: .variableDeclaration, text: match.1, charactersConsumed: match.0.count)
        }
        else if let match = try /\s*let\s/.prefixMatch(in: line){
            return (lexeme: .constantDeclaration, text: match.1, charactersConsumed: match.0.count)
        }
        else if let match = try /\s*=\s/.prefixMatch(in: line){
            return (lexeme: .operationAssignment, text: match.1, charactersConsumed: match.0.count)
        }
        else if let match = try /\s*[0-9]+/.prefixMatch(in: line){
            return (lexeme: .literalIntegers(value: Int(match:1)!), text: match.1, charactersConsumed: match.0.count)
        }
        else{
            throw LexemeError.notLexemeFound
        }

    }
    
}

struct LexemeSource{
    let lexeme: Lexeme
    let text: String
    let lineIndex: Int
    let columnIndex: Int

    static func lex(line: String) throws{
        var workingLine = Substring(line)
        while workingLine.count > 0 {
            let (lexeme, text, charactersConsumed) = try Lexeme.nextLexeme(from: workingLine)
            workingline = workingLine.dropFirst(charactersConsumed)
            dump(lexeme)
        }
    }
    
}



func main() {
    do{
        let line = "  var iable alpha = 3"
        print(try Token.nextLexeme(from: line))
    } catch {
        print("Failed because : \(error)")
    }
}

main()
