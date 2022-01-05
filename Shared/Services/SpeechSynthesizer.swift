//
//  SpeechSynthesizer.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 25.11.21.
//

import AVFAudio
import AVFoundation

enum SpeechEngine: String, Codable {
    case auto
    case voiceOver
    case googleTTS
}

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer? = nil
    private let ttsService: TextToSpeechService = PolyglotTTSService.shared
    
    func speakVoiceOver(string: String, language: String, ignoreCheck: Bool = false) -> Bool {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        guard let actualLanguage = utterance.voice?.language else {
            return false
        }
        if !ignoreCheck && actualLanguage.split(separator: "-")[0].lowercased() != language.split(separator: "-")[0].lowercased() {
            return false
        }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
        
        return true
    }
    
    func speakTTSService(string: String, language: String) {
        ttsService.Generate(text: string, language: language) { result in
            switch result {
            case .success(let data):
                self.audioPlayer = try? AVAudioPlayer(data: data!, fileTypeHint: AVFileType.mp3.rawValue)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func speak(string: String, language: String, engine: SpeechEngine = .auto) {
        if engine == .voiceOver || engine == .auto {
            if speakVoiceOver(string: string, language: language, ignoreCheck: engine == .voiceOver) {
                return
            }
        }
        
        if engine == .googleTTS || engine == .auto {
            speakTTSService(string: string, language: language)
        }
    }
}
