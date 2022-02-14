//
//  Enums.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import Foundation

enum Symbol: RawRepresentable {
  case add, subtract, multiply, divide, exponentiate

  init?(rawValue: Character) {
    switch rawValue {
    case "+":
      self = .add
    case "-":
      self = .subtract
    case "*":
      self = .multiply
    case "/":
      self = .divide
    case "^":
      self = .exponentiate
    default:
      return nil
    }
  }
  var rawValue: Character {
    switch self {
    case .add:
      return "+"
    case .subtract:
      return "-"
    case .multiply:
      return "*"
    case .divide:
      return "/"
    case .exponentiate:
      return "^"
    }
  }

  var operation: (Float, Float) -> (Float) {
    switch self {
    case .add:
      return (+)
    case .subtract:
      return (-)
    case .multiply:
      return (*)
    case .divide:
      return (/)
    case .exponentiate:
      return pow
    }
  }
}

enum MathItem {
  case number(Float), symbol(Symbol)
}

enum Parenthesis {
  case open, item(MathItem), close
}

enum ParsingError: Error {
  case invalidCharacter(Int)
  case closeWithoutOpen(Int)
  case openWithoutClose(Int)
  case emptyParentheses(Int)
  case expectedSymbol(Int)
  case expectedNumber(Int)
}
