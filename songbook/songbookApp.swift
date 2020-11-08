//
//  songbookApp.swift
//  songbook
//
//  Created by Paul Himes on 11/7/20.
//

import SwiftUI

@main
struct songbookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
