//
//  Parentheses.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import Foundation

fileprivate typealias CompressedMathItem = (rawValue: Int, item: MathItem)

func evaluateParentheses(_ parens: [Parenthesis]) throws -> Float {
  var expressions: [(openIndex: Int, expression: [CompressedMathItem])] = [(-1, [])]
  for (index, paren) in parens.enumerated() {
    switch paren {
    case .open:
      expressions.append((index, []))
    case .item(let item):
      guard let (openIndex, expression) = expressions.popLast() else {
        // `expressions is guaranteed to be non-empty at this point.
        fatalError("This is impossible.")
      }
      var newExpression = expression
      newExpression.append((1, item))
      expressions.append((openIndex, newExpression))
    case .close:
      guard let (openIndex, expression) = expressions.popLast() else {
        // `expressions` starts with one expression.
        // Every time we pop from a close we consolidate up one level (below).
        // If at that step there is nothing up one level, then we throw.
        // Hence we are guaranteed that `expressions` is non-empty at this point.
        fatalError("This is impossible.")
      }

      guard let (prevOpenIndex, prevExpression) = expressions.popLast() else {
        throw ParsingError.closeWithoutOpen(index)
      }

      do {
        let value = try evaluatePEMDAS(expression.map{ $0.item })
        let rawCount = expression.count + 2 // Add 2 for open and close parentheses.
        var newPrevExpression = prevExpression
        newPrevExpression.append((rawCount, .number(value)))
        expressions.append((prevOpenIndex, newPrevExpression))
      } catch {
        throw propogateError(error, openIndex: openIndex, compressedItems: expression)
      }
    }
  }

  if expressions.count > 1 {
    throw ParsingError.openWithoutClose(expressions.last!.openIndex)
  }

  // `expressions is guaranteed to have exactly one element at this point.
  let (openIndex, expression) = expressions.first!

  do {
    return try evaluatePEMDAS(expression.map{ $0.item })
  } catch {
    throw propogateError(error, openIndex: openIndex, compressedItems: expression)
  }
}

fileprivate func propogateError(_ error: Error,
                                openIndex: Int,
                                compressedItems: [CompressedMathItem]) -> ParsingError {
  switch error {
  case ParsingError.emptyParentheses(_):
    return ParsingError.emptyParentheses(openIndex)
  case ParsingError.expectedSymbol(let violationIndex):
    return ParsingError.expectedSymbol(trueIndexOfViolation(startIndex: openIndex,
                                                            compressedItems: compressedItems,
                                                            violatioinIndex: violationIndex))
  case ParsingError.expectedNumber(let violationIndex):
    return ParsingError.expectedNumber(trueIndexOfViolation(startIndex: openIndex,
                                                            compressedItems: compressedItems,
                                                            violatioinIndex: violationIndex))
  default:
    return error as! ParsingError
  }
}

fileprivate func trueIndexOfViolation(startIndex: Int,
                                      compressedItems: [CompressedMathItem],
                                      violatioinIndex: Int) -> Int {
  var trueIndex = startIndex
  for i in 0 ..< violatioinIndex {
    trueIndex += compressedItems[i].rawValue
  }
  return trueIndex + 1
}
