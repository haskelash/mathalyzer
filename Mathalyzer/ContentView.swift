//
//  ContentView.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Item>

  @State private var input = ""

  var body: some View {
    NavigationView {
      VStack {
        HStack {
          TextField("Type some math...", text: $input)
          NavigationLink {
            AnswerView(expression: input
                        .components(separatedBy: .whitespacesAndNewlines)
                        .joined(separator: ""))
          } label: {
            Text("Compute")
          }.disabled(input.isEmpty)
        }.padding([.leading, .trailing])
        Spacer()
        Spacer()
        List {
          ForEach(items) { item in
            NavigationLink {
              Text("Item at \(item.timestamp!, formatter: itemFormatter)")
            } label: {
              Text(item.timestamp!, formatter: itemFormatter)
            }
          }
          .onDelete(perform: deleteItems)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
          ToolbarItem {
            Button(action: addItem) {
              Label("Add Item", systemImage: "plus")
            }
          }
        }
      }
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()

      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items[$0] }.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

struct AnswerView: View {
  let expression: String

  var body: some View {
    Text(compute())
  }

  func compute() -> String {
    do {
      let answer = try evaluate(expression)
      let output = "\(expression) = \(answer)"
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

fileprivate let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
