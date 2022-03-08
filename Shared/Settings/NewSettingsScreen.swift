//
//  NewSettingsScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import SwiftUI

struct NewSettingsScreen: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingsActiveLanguagesView()) {
                    Text("Active Languages")
                }
                NavigationLink(destination: SettingsServicesView()) {
                    Text("Translation and speech synthesizer")
                }
                NavigationLink(destination: SettingsAppearanceView()) {
                    Text("Appereance")
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct SettingsAppearanceView: View {
    @Preference(\.colorScheme) var storedColorScheme
    @State var colorScheme: ColorSchemePreference = .auto

    var body: some View {
        Form {
            Section {
                Picker("Color Scheme", selection: $colorScheme) {
                    ForEach([ColorSchemePreference.auto, ColorSchemePreference.dark, ColorSchemePreference.light], id: \.self) {
                        Text(NSLocalizedString($0.rawValue, comment: $0.rawValue))
                            .tag($0)
                    }
                }
            }
        }
        .onChange(of: colorScheme) {
            storedColorScheme = $0
        }
        .onAppear {
            colorScheme = storedColorScheme
        }
    }
}

struct SettingsServicesView: View {
    @Preference(\.servicePreferences) var storedServicePreferences
    @State var servicePreferences: ServicePreferences = .init(preferGoogleTranslationEngine: false, preferGoogleTTSEngine: false)
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Translation")) {
                    Toggle(isOn: $servicePreferences.preferGoogleTTSEngine) {
                        Text("Prefer Google text-to-speech")
                    }
                }
                Section(header: Text("Speech synthesizer")) {
                    Toggle(isOn: $servicePreferences.preferGoogleTranslationEngine) {
                        Text("Prefer Google Translator")
                    }
                }
            }
        }
        .navigationTitle("Translation and speech synthesizer")
        .onChange(of: servicePreferences) {
            storedServicePreferences = $0
        }
        .onAppear {
            servicePreferences = storedServicePreferences
        }
    }
}

struct SettingsActiveLanguagesView: View {
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    @State var filteredLanguages: [Language] = []
    
    @Preference(\.languages) var languages
    @State var activeLanguages: [Language] = []
    
    @State var editMode: EditMode = .inactive
    
    func delete(at offsets: IndexSet) {
        activeLanguages.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        activeLanguages.move(fromOffsets: source, toOffset: destination)
    }
    
    func changeFilteredLanguages(language: Language) {
        let isLanguageVisible = filteredLanguages.contains(language)
        filteredLanguages = activeLanguages.filter { lang in
            if lang == language {
                return !isLanguageVisible
            }
            return filteredLanguages.contains(lang)
        }
    }
    
    var body: some View {
        List {
            ForEach(activeLanguages, id: \.self.code) { lang in
                HStack {
                    Text(lang.name)
                    
                    Spacer()
                    
                    Button(action: {
                        changeFilteredLanguages(language: lang)
                    }) {
                        Image(
                            systemName: filteredLanguages.contains(lang) ? "eye.fill" : "eye.slash.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onDelete(perform: delete)
            .onMove(perform: move)
        }
        .onAppear {
            activeLanguages = languages
            filteredLanguages = storedFilteredLanguages
        }
        .onChange(of: activeLanguages) {
            languages = $0
        }
        .onChange(of: filteredLanguages) {
            storedFilteredLanguages = $0
        }
        .environment(\.editMode, self.$editMode)
        .navigationTitle("Active Languages")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    editMode = editMode == .inactive ? .active : .inactive
                }) {
                    Image(systemName: editMode == .inactive ? "pencil.circle" : "checkmark.circle")
                }
                NavigationLink(destination: {
                    ScrollView {
                        LanguageFilter(languages: Language.all, selectOne: true, hideSelected: true, selected: $activeLanguages)
                            .padding(.horizontal)
                            .padding(.bottom, 60)
                    }
                    .navigationTitle("Add active language")
                }) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}

struct NewSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewSettingsScreen()
    }
}
