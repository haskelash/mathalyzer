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

  @State private var shook = false

  var body: some View {
    NavigationView {
      VStack {
        Divider()
        HStack {
          TextField("Type some math...", text: $input)
          NavigationLink(isActive: $shook, destination: {
            AnswerView(expression: input
                        .components(separatedBy: .whitespacesAndNewlines)
                        .joined(separator: ""))
          }, label: { Text("Shake to compute") })
            .disabled(input.isEmpty)
        }.padding([.leading, .trailing])
        Divider()
        HStack {
          Text("Previous results")
          Spacer()
        }.padding()
        List {
          ForEach(items) { item in
            Text(item.answer!)
          }
          .onDelete(perform: deleteItems)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
        }
      }.navigationTitle("Mathalyzer")
    }
    .navigationViewStyle(.stack)
    .onShake{
      if !input.isEmpty {
        shook = true
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
