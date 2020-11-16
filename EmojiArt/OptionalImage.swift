//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Allan Garcia on 16/11/2020.
//

import SwiftUI

struct OptionalImage: View {
    
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
