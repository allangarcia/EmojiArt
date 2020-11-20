//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by Allan Garcia on 20/11/2020.
//

import SwiftUI

struct PaletteChooserView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    self.chosenPalette = self.document.palette(after: self.chosenPalette)
                },
                onDecrement: {
                    self.chosenPalette = self.document.palette(before: self.chosenPalette)
                },
                label: { EmptyView() }
            )
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
