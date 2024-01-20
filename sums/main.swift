typealias OperationType = (_ index: Int) -> Int
    


func odd(atIndex index: Int) -> Int{
    return 2 * index + 1
}
func even(atIndex index: Int) ->Int{
    return 2 * index
}
func square(atIndex index: Int) -> Int{
    return index * index
}
func cube(atIndex index: Int) ->Int{
    return index * index * index 
}

func sum(from: Int, through:Int, operation: OperationType) -> Int{
    var accumulator = 0
    for index in from ... through {
        accumulator += operation(index)
    }
    return accumulator
}

print(sum(from: 5, through: 10, operation: even))
print(sum(from: 5, through: 10, operation: { (_ index: Int) in return 2*index} ))
print(sum(from: 2, through: 7, operation: {2*$0*$0+1}))
print(sum(from: 5, through: 10){2*$0})

// func sumEvens(from: Int, through: Int) ->Int{
//     var accumulator = 0
//     for index in from ... through{
//         accumulator += even(atIndex: index)
//     }
//     return accumulator
// }

// func sumOdds(from: Int, through: Int) ->Int{
//     var accumulator = 0
//     for index in from ... through{
//         accumulator += odd(atIndex: index)
//     }
//     return accumulator
// }

// func sumSquares(from: Int, through: Int) ->Int{
//     var accumulator = 0
//     for index in from ... through{
//         accumulator += square(atIndex: index)
//     }
//     return accumulator
// }

// func sumCubes(from: Int, through: Int) ->Int{
//     var accumulator = 0
//     for index in from ... through{
//         accumulator += cube(atIndex: index)
//     }
//     return accumulator
// }

// print(sumEvens(from: 5, through: 10))
// print(sumOdds(from: 5, through: 10))
// print(sumSquares(from: 5, through: 10))
// print(sumCubes(from: 5, through: 10))
