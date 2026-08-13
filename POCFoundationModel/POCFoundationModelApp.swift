//
//  POCFoundationModelApp.swift
//  POCFoundationModel
//
//  Created by Pedro Henrique Castro da Silva on 06/08/26.
//

import SwiftUI

@main
struct POCFoundationModelApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environment(ArchiveViewModel())
        }
    }
}
