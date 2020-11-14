//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Allan Garcia on 14/11/2020.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .font(Font.system(size: self.defaultEmojiSize))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
