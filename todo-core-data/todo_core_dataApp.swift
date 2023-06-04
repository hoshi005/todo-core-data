//
//  todo_core_dataApp.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import SwiftUI

@main
struct todo_core_dataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
