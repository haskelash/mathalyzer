//
//  PEMDAS.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import Foundation

func evaluatePEMDAS(_ items: [MathItem]) throws -> Float {
  if items.isEmpty {
    throw ParsingError.emptyParentheses(-1)
  } else if case .symbol(_) = items.first {
    throw ParsingError.expectedNumber(0)
  } else if case .symbol(_) = items.last {
    throw ParsingError.expectedNumber(items.count - 1)
  }
  try items.enumerated().forEach { index, item in
    if index % 2 == 0 { // expect a number
      if case .symbol(_) = item { throw ParsingError.expectedNumber(index) }
    } else { // expect a symbol
      if case .number(_) = item { throw ParsingError.expectedSymbol(index) }
    }
  }
  /*
   At this point `items` is guaranteed to:
   - contain at least one item
   - start and end with a number
   - alternate between numbers and symbols
   */

  let orderOfOperations: [[Symbol]] = [[.exponentiate], [.multiply, .divide], [.add, .subtract]]
  return evaluatePEMDASRecursive(items, orderOfOperations: orderOfOperations)
}

fileprivate func evaluatePEMDASRecursive(_ items: [MathItem], orderOfOperations: [[Symbol]]) -> Float {
  guard let symbols = orderOfOperations.last else {
    // We've processed all operations.
    guard items.count == 1, case .number(let answer) = items.first else {
      // If we've processed all operations then `items` must contain exactly one number.
      fatalError("This is impossible.")
    }
    return answer
  }

  let isInSymbols: (MathItem) -> Bool = {
    guard case .symbol(let symbol) = $0 else { return false }
    return symbols.contains(symbol)
  }

  // Get a list of all the terms.
  var terms = items.split{ isInSymbols($0) }.map{ Array($0) }

  // Get a list of all the operators we split by.
  var splits = items.split{ !isInSymbols($0) }.flatMap{ $0 }.map{ (item: MathItem) -> (Symbol) in
    // We just split by items that are not in the symbol list. So `item` must be in the symbol list.
    guard case .symbol(let symbol) = item else { fatalError("This is impossible.") }
    return symbol
  }

  var answer: Float!
  while terms.count > 0 {
    let term = terms.removeFirst()
    let operations = Array(orderOfOperations[0..<orderOfOperations.count-1])
    let value = evaluatePEMDASRecursive(term, orderOfOperations: operations)
    if answer == nil {
      answer = value
    } else {
      let symbol = splits.removeFirst()
      answer = symbol.operation(answer, value)
    }
  }

  return answer
}
