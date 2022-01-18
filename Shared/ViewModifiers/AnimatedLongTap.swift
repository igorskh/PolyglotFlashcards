//
//  AnimatedLongTap.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.01.22.
//

import SwiftUI

struct AnimatedLongTap: ViewModifier {
    @State var timer: Timer?
    
    @State var scaleValue: CGFloat = 1.0
    
    var onDismiss: () -> Void
    var onFinished: () -> Void
    
    func feedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleValue)
            .onLongPressGesture(maximumDistance: 100, pressing: { state in
                scaleValue = 1.0
                if state {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        scaleValue += 0.001
                    }
                } else {
                    timer?.invalidate()
                    scaleValue = 1.0
                    onDismiss()
                }
                }) {
                    scaleValue = 1.0
                    feedback()
                    onFinished()
                }
            
    }
}

extension View {
    func animatedLongTap(onDismiss: @escaping () -> Void, onFinished: @escaping () -> Void) -> some View {
        modifier(AnimatedLongTap(onDismiss: onDismiss, onFinished: onFinished))
    }
}
