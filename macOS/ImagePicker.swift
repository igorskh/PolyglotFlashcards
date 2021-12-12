//
//  ImagePicker.swift
//  PolyglotFlashcards (macOS)
//
//  Created by Igor Kim on 12.12.21.
//

import SwiftUI
import Quartz

struct ImagePicker: View {
    @Binding var isOpen: Bool
    @Binding var selectedImage: UIImage
    
    var body: some View {
        VStack {
            
        }.onAppear {
            let openPanel = NSOpenPanel()
            openPanel.prompt = "Select File"
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.canChooseFiles = true
            openPanel.allowedFileTypes = ["png","jpg","jpeg"]
            
            openPanel.begin { (result) -> Void in
                if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                    if let url = openPanel.url,
                       FileManager.default.fileExists(atPath: url.path),
                       let data = try? Data(contentsOf: url),
                       let image = NSImage(data: data){
                        selectedImage = image
                    }
                }
                isOpen = false
            }
        }
    }
}
