//
//  SpeechSynthesizer.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 25.11.21.
//

import AVFoundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(string: String, language: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
    }
}
