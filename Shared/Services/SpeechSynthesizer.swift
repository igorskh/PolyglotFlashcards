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

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer? = nil
    private let ttsService: TextToSpeechService = PolyglotTTSService.shared
    private var avSessionCategory: AVAudioSession.Category
    
    init(avSessionCategory: AVAudioSession.Category = .playback) {
        self.avSessionCategory = avSessionCategory
        super.init()
        
        self.synthesizer.delegate = self
    }
    
    private func duckAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(avSessionCategory, options: .duckOthers)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func unduckAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, options: .mixWithOthers)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.unduckAudioSession()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.unduckAudioSession()
    }
    
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
        duckAudioSession()
        synthesizer.speak(utterance)
        
        return true
    }
    
    func speakTTSService(string: String, language: String) {
        ttsService.Generate(text: string, language: language) { result in
            switch result {
            case .success(let data):
                self.audioPlayer = try? AVAudioPlayer(data: data!, fileTypeHint: AVFileType.mp3.rawValue)
                
                self.audioPlayer?.delegate = self
                self.duckAudioSession()
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
