//
//  SelectedViewModifier.swift
//  EmojiArt
//
//  Created by Allan Garcia on 17/11/2020.
//

import SwiftUI

struct SelectedViewModifier: ViewModifier {
    
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        Group {
            if isSelected {
                content
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow, lineWidth: 3)
                    )
            } else {
                content
            }
        }
    }
}

extension View {
    func selected(isSelected: Bool) -> some View {
        self.modifier(SelectedViewModifier(isSelected: isSelected))
    }
}
