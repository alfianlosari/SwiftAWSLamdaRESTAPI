//
//  TodoApp.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import SwiftUI

@main
struct TodoApp: App {
    var body: some Scene {
        let viewContext = TodoProvider.shared.persistentContainer.viewContext
        
        return WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
