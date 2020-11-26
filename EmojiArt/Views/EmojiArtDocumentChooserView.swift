//
//  EmojiArtDocumentChooserView.swift
//  EmojiArt
//
//  Created by Allan Garcia on 21/11/2020.
//

import SwiftUI

struct EmojiArtDocumentChooserView: View {
    
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(Text(self.store.name(for: document)))
                    ) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
                
            }
            .navigationBarTitle(Text(self.store.name))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: { self.store.addDocument() },
                    label: { Image(systemName: "plus").imageScale(.large) }
                )
            )
            .listStyle(PlainListStyle())
            .environment(\.editMode, $editMode)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        
    }
}
