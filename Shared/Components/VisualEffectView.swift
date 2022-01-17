//
//  VisualEffectView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 16.01.22.
//

import SwiftUI

// https://stackoverflow.com/questions/59111075/semi-transparent-blurry-like-visualeffectview-of-the-view-behind-the-current-v
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
