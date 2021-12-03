//
//  BouncingIcon.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 04.12.21.
//

import SwiftUI

struct BouncingIcon: View {
    @Binding var trigger: Bool
    var color: Color
    var systemName: String
    
    var body: some View {
        Image(systemName:systemName)
            .foregroundColor(color)
            .scaleEffect(trigger ? 1.5 : 1)
            .frame(width: 50)
            .font(.title)
            .animation(
                .easeInOut(duration: 0.2),
                value: trigger
            )
            .onChange(of: trigger) {
                if $0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        trigger = false
                    }
                }
            }
    }
}
