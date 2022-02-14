//
//  AnswerView.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import SwiftUI

struct AnswerView: View {
  @Environment(\.managedObjectContext) private var viewContext

  let expression: String

  var body: some View {
    Text(compute())
  }

  func compute() -> String {
    do {
      let answer = try evaluate(expression)
      let output = "\(expression) = \(answer)"
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()
      newItem.answer = output
      try viewContext.save()
      return output
    } catch ParsingError.invalidCharacter(let index) {
      return error("Invalid character: ", expression, index)
    } catch ParsingError.closeWithoutOpen(let index) {
      return error("Missing open parentheses: ", expression, index)
    } catch ParsingError.openWithoutClose(let index) {
      return error("Missing close parentheses: ", expression, index)
    } catch ParsingError.emptyParentheses(let index) {
      return error("Empty parentheses: ", expression, index)
    } catch ParsingError.expectedSymbol(let index) {
      return error("Expected a symbol: ", expression, index)
    } catch ParsingError.expectedNumber(let index) {
      return error("Expected a number: ", expression, index)
    } catch {
      fatalError("This is impossible.")
    }
  }

  private func error(_ errorString: String, _ expression: String, _ index: Int) -> String {
    var emphasized = expression
    emphasized.insert("`", at: emphasized.index(emphasized.startIndex, offsetBy: index))
    emphasized.insert("`", at: emphasized.index(emphasized.startIndex, offsetBy: index + 2))
    return "\(errorString)\(emphasized)"
  }
}
