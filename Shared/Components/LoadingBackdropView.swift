//
//  LoadingBackdropView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import SwiftUI

struct LoadingBackdropView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                    .foregroundColor(.white)
                    .scaleEffect(2.0)
                Spacer()
            }
            Spacer()
        }
        .background(Color.primary.colorInvert().opacity(0.6))
        .ignoresSafeArea()
    }
}

struct LoadingBackdropView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingBackdropView()
    }
}
