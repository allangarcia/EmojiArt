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
        VStack {
            
            // MARK: -- Palette
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            .onDrag {
                                return NSItemProvider(object: emoji as NSString)
                            }
                    }
                }
            }
            .padding(.horizontal)
            
            // MARK: -- Draw
            
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(
                            OptionalImage(uiImage: self.document.backgroundImage)
                                .scaleEffect(self.zoomScale)
                                .offset(self.panOffset)
                        )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                        .onTapGesture {
                            self.selectedEmojis.removeAll()
                        }
                    if self.isLoading {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .imageScale(.large)
                            .spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .selected(isSelected: self.selectedEmojis.contains(emoji))
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .scaleEffect(self.selectedEmojis.contains(emoji) ? self.gestureEmojiScale : 1.0)
                                .offset(self.selectedEmojis.contains(emoji) ? self.gestureEmojiOffset : .zero)
                                .position(self.position(for: emoji, in: geometry.size))
                                .onTapGesture {
                                    if self.selectedEmojis.contains(emoji) {
                                        self.unselectEmoji(emoji)
                                    } else {
                                        self.selectEmoji(emoji)
                                    }
                                }
                                .onLongPressGesture {
                                    self.emojiToRemove = emoji
                                    self.alertToRemoveEmoji = true
                                }
                        }
                    }
                }
                .clipped()
                .gesture(self.selectedEmojis.count > 0 ? self.emojiMoveGesture() : nil)
                .gesture(self.panGesture())
                .gesture(self.selectedEmojis.count > 0 ? self.emojiResizeGesture() : nil)
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .alert(isPresented: $alertToRemoveEmoji, content: {
                    Alert(
                        title: Text("Remove Emoji"),
                        message: Text("Are you sure?"),
                        primaryButton: .destructive(Text("YES"), action: {
                            if let emoji = self.emojiToRemove {
                                if self.selectedEmojis.contains(emoji) {
                                    self.unselectEmoji(emoji)
                                }
                                self.document.removeEmoji(emoji)
                                self.emojiToRemove = nil
                            }
                        }),
                        secondaryButton: .cancel()
                    )
                })
            }
        }
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @State private var selectedEmojis: [EmojiArt.Emoji] = [] {
        didSet {
            print("selected emojis= \(selectedEmojis)")
        }
    }
    
    private func selectEmoji(_ emoji: EmojiArt.Emoji) {
        selectedEmojis.append(emoji)
    }
    
    private func unselectEmoji(_ emoji: EmojiArt.Emoji) {
        if let index = selectedEmojis.firstIndex(matching: emoji) {
            selectedEmojis.remove(at: index)
        }
    }
    
    @State private var emojiToRemove: EmojiArt.Emoji?
    @State private var alertToRemoveEmoji = false
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }
    
    @GestureState private var gestureEmojiScale: CGFloat = 1.0
    
    private func emojiResizeGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureEmojiScale) { latestGestureScale, gestureEmojiScale, transaction in
                gestureEmojiScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.selectedEmojis.forEach { emoji in
                    self.document.scaleEmoji(emoji, by: finalGestureScale)
                }
                self.selectedEmojis.removeAll()
            }
    }

    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { lastestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = lastestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    @GestureState private var gestureEmojiOffset: CGSize = .zero
    
    private func emojiMoveGesture() -> some Gesture {
        DragGesture()
            .updating($gestureEmojiOffset) { lastestDragGestureValue, gestureEmojiOffset, transaction in
                gestureEmojiOffset = lastestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.selectedEmojis.forEach { emoji in
                    self.document.moveEmoji(emoji, by: finalDragGestureValue.translation / self.zoomScale)
                }
                self.selectedEmojis.removeAll()
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped: \(url)")
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


