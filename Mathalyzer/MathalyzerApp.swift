//
//  MathalyzerApp.swift
//  Mathalyzer
//
//  Created by Haskel Ash on 2/14/22.
//

import SwiftUI

@main
struct MathalyzerApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
