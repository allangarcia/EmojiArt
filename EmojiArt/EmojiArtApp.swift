//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Allan Garcia on 14/11/2020.
//

import SwiftUI


@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            let storeName = "Emoji Art"
            let store = EmojiArtDocumentStore(named: storeName)
            EmojiArtDocumentChooserView()
                .environmentObject(store)
        }
    }
}
