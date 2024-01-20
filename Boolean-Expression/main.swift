// help from ChatGPT

import Foundation

enum TokenType {
    case variable(String)
    case operatorToken(String)
    case openParenthesis
    case closeParenthesis
}

class Node {
    var value: String
    var children: [Node]

    init(value: String) {
        self.value = value
        self.children = []
    }
}

func tokenize(_ expression: String) -> [TokenType] {
    var tokens: [TokenType] = []
    var currentToken = ""
    let operatorMapping = ["and": "∧", "or": "∨", "not": "¬", "xor": "⊕", "imply": "→", "true": "⊤", "false": "⊥"]

    func addTokenIfNeeded() {
        if !currentToken.isEmpty {
            if let mappedOperator = operatorMapping[currentToken.lowercased()] {
                tokens.append(.operatorToken(mappedOperator))
            } else {
                tokens.append(.variable(currentToken))
            }
            currentToken = ""
        }
    }

    for char in expression.lowercased() {
        if char.isLetter || char.isNumber {
            currentToken.append(char)
        } else if ["(", ")", "=", "≠"].contains(String(char)) {
            addTokenIfNeeded()
            switch char {
            case "(":
                tokens.append(.openParenthesis)
            case ")":
                tokens.append(.closeParenthesis)
            default:
                break
            }
        } else if char.isWhitespace {
            addTokenIfNeeded()
        } else {
            currentToken.append(char)
        }
    }

    addTokenIfNeeded()

    return tokens
}

func parse(_ tokens: [TokenType]) -> [String] {
    var outputQueue: [String] = []
    var operatorStack: [String] = []
    let precedence: [String: Int] = ["¬": 3, "∧": 2, "∨": 2, "⊕": 2, "=": 1, "≠": 1, "→": 1]

    for token in tokens {
        switch token {
        case .variable(let variable):
            outputQueue.append(variable)
        case .openParenthesis:
            operatorStack.append("(")
        case .closeParenthesis:
            while let top = operatorStack.last, top != "(" {
                outputQueue.append(operatorStack.removeLast())
            }
            _ = operatorStack.popLast()
        case .operatorToken(let operatorToken):
            while let top = operatorStack.last, let topPrecedence = precedence[top], let tokenPrecedence = precedence[operatorToken], topPrecedence >= tokenPrecedence {
                outputQueue.append(operatorStack.removeLast())
            }
            operatorStack.append(operatorToken)
        }
    }

    while !operatorStack.isEmpty {
        outputQueue.append(operatorStack.removeLast())
    }

    return outputQueue
}

func buildParseTree(_ postfixExpression: [String]) -> Node {
    var stack: [Node] = []

    for token in postfixExpression {
        if let firstChar = token.first, firstChar.isLetter {
            stack.append(Node(value: token))
        } else {
            let node = Node(value: token)
            
            if !stack.isEmpty {
                node.children.append(stack.removeLast())
            }
            
            if token != "¬" && !stack.isEmpty {
                node.children.append(stack.removeLast())
            }
            
            stack.append(node)
        }
    }

    return stack[0]
}

func evaluate(_ node: Node, _ variableValues: [String: Bool]) -> Bool {
    if let firstChar = node.value.first, firstChar.isLetter {
        return variableValues[node.value.lowercased()] ?? false
    } else if node.value == "¬" {
        if !node.children.isEmpty {
            return !evaluate(node.children[0], variableValues)
        }
    } else if ["∧", "∨", "⊕", "=", "≠", "→"].contains(node.value) {
        if node.children.count >= 2 {
            let left = evaluate(node.children[0], variableValues)
            let right = evaluate(node.children[1], variableValues)

            switch node.value {
            case "∧":
                return left && right
            case "∨":
                return left || right
            case "⊕":
                return left != right
            case "=":
                return left == right
            case "≠":
                return left != right
            case "→":
                return !left || right
            default:
                return false
            }
        }
    }
    
    return false
}

func generateTruthTable(_ tokens: [TokenType], _ parseTree: Node) throws -> [[String: Bool]] {
    var table: [[String: Bool]] = []
    var variables: [String: Bool] = [:]

    for token in tokens {
        switch token {
        case .variable(let variable):
            variables[variable.lowercased()] = true
        default:
            break
        }
    }

    let sortedVariables = variables.keys.sorted()

    for i in 0..<(1 << sortedVariables.count) {
        var row: [String: Bool] = [:]
        let binaryRepr = String(i, radix: 2).padLeft(toLength: sortedVariables.count, withPad: "0")

        for j in 0..<sortedVariables.count {
            let variable = sortedVariables[j]
            row[variable] = binaryRepr[binaryRepr.index(binaryRepr.startIndex, offsetBy: j)] == "1"
        }

        row["Result"] = evaluate(parseTree, row)
        table.append(row)
    }

    print("\nTruth Table:")
    let header = sortedVariables + ["Result"]
    print(header.map { "\($0)" }.joined(separator: "\t"))

    for row in table {
        let formattedRow = header.map { row[$0]! ? "T" : "F" }
        print(formattedRow.joined(separator: "\t"))
    }

    return table
}

extension String {
    func padLeft(toLength length: Int, withPad pad: String) -> String {
        let padded = String(repeating: pad, count: max(0, length - count)) + self
        return String(padded.suffix(length))
    }
}

func main() {
    print("Please enter one or more Boolean expressions followed by a single period when done.")
    print("Accepted operators include: ∧, ∨, ¬, ⊕, =, ≠, →, ⊤, ⊥, (, )")
    print("Variables must consist of one or more lowercase characters.")

    var expressions: [String] = []
    var input = ""

    repeat {
        do {
            input = readLine() ?? ""
            expressions.append(input)

            if input.lowercased().contains(".") {
                expressions.removeLast() // Remove the trailing period
            }

            let tokens = try tokenize(input)
            let postfixExpression = try parse(tokens)
            let parseTree = buildParseTree(postfixExpression)

            print("=============================")
            print("Expression: \(input)")
            print("=============================")

            _ = try generateTruthTable(tokens, parseTree)
        } catch {
            print("Error: Invalid expression")
        }
    } while !input.lowercased().contains("")
}


main()
