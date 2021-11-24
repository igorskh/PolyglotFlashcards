//
//  LanguagePicker.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct LanguagePicker<T: PickerStyle>: View {
    @Binding var selection: Language
    var style: T
    var showUnknown: Bool = false
    
    var body: some View {
        Picker("Primary Language", selection: $selection) {
            if showUnknown {
                Text("\(Language.Unknown.flag)")
                    .tag(Language.Unknown)
            }
            ForEach(Language.all, id: \.self) {
                Text("\($0.flag)")
                    .tag($0)
            }
        }.pickerStyle(style)
    }
}
