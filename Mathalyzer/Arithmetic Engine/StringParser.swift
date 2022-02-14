//
//  StringParser.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import Foundation

func evaluate(_ string: String) throws -> Float {
  let constants: [Character: Float] = [
    "e": Float(Darwin.M_E),
    "π": Float.pi
  ]
  let digits = "0123456789"
  let symbols = "+-*/^"
  var numberInProgress = ""
  var parens: [Parenthesis] = []
  for (index, character) in string.enumerated() {
    if !digits.contains(character) && numberInProgress.count > 0 {
      parens.append(.item(.number(Float(numberInProgress)!)))
      numberInProgress = ""
    }
    switch character {
    case _ where digits.contains(character):
      numberInProgress.append(character)
    case "(":
      parens.append(.open)
    case ")":
      parens.append(.close)
    case _ where symbols.contains(character):
      parens.append(.item(.symbol(.init(rawValue: character)!)))
    case _ where constants.keys.contains(character):
      parens.append(.item(.number(constants[character]!)))
    default:
      throw ParsingError.invalidCharacter(index)
    }
  }

  if numberInProgress.count > 0 {
    parens.append(.item(.number(Float(numberInProgress)!)))
  }

  do {
    return try evaluateParentheses(parens)
  } catch {
    throw propogateError(error, parens)
  }
}

fileprivate func propogateError(_ error: Error, _ parens: [Parenthesis]) -> ParsingError {
  switch error {
  case ParsingError.closeWithoutOpen(let index):
    return .closeWithoutOpen(trueIndexOfViolation(index, parens))
  case ParsingError.openWithoutClose(let index):
    return .openWithoutClose(trueIndexOfViolation(index, parens))
  case ParsingError.emptyParentheses(let index):
    return .emptyParentheses(trueIndexOfViolation(index, parens))
  case ParsingError.expectedSymbol(let index):
    return .expectedSymbol(trueIndexOfViolation(index, parens))
  case ParsingError.expectedNumber(let index):
    return .expectedNumber(trueIndexOfViolation(index, parens))
  default:
    return error as! ParsingError
  }
}

fileprivate func trueIndexOfViolation(_ index: Int, _ parens: [Parenthesis]) -> Int {
  var trueIndex = -1
  for i in 0 ..< index {
    guard case .item(let item) = parens[i] else { trueIndex += 1 ; continue }
    guard case .number(let number) = item else { trueIndex += 1 ; continue }
    trueIndex += String(Int(number)).count
  }
  return trueIndex + 1
}
