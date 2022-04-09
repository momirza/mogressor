//
//  MogressorApp.swift
//  Mogressor
//
//  Created by Mo Mirza on 09/04/2022.
//

import SwiftUI

@main
struct MogressorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
