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

enum SpeechSynthesizerState {
    case started
    case stopped
}

typealias SpeechSynthesizerStateCallback = (SpeechSynthesizerState, String?) -> Void

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer? = nil
    private let ttsService: TextToSpeechService = PolyglotTTSService.shared
    private var avSessionCategory: AVAudioSession.Category
    
    private let stateCallback: SpeechSynthesizerStateCallback?
    private var currentSessionID: String? = nil
    
    init(avSessionCategory: AVAudioSession.Category = .ambient, stateCallback: SpeechSynthesizerStateCallback? = nil) {
        self.avSessionCategory = avSessionCategory
        self.stateCallback = stateCallback
        super.init()
        
        self.synthesizer.delegate = self
    }
    
    private func startAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(avSessionCategory, options: .duckOthers)
            stateCallback?(.started, currentSessionID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func releaseAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, options: .mixWithOthers)
            stateCallback?(.stopped, currentSessionID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.releaseAudioSession()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.releaseAudioSession()
    }
    
    func speakVoiceOver(string: String, language: String, ignoreCheck: Bool = false, sessionID: String = "") -> Bool {
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
            if currentSessionID != nil, sessionID != "", currentSessionID == sessionID {
                return true
            }
        }
        currentSessionID = sessionID
        
        startAudioSession()
        synthesizer.speak(utterance)
        
        return true
    }
    
    func speakTTSService(string: String, language: String, sessionID: String = "") {
        if audioPlayer != nil, currentSessionID != nil, sessionID != "", audioPlayer!.isPlaying, currentSessionID == sessionID {
            audioPlayer!.stop()
            return
        }
        currentSessionID = sessionID
        
        ttsService.Generate(text: string, language: language) { result in
            switch result {
            case .success(let data):
                self.audioPlayer = try? AVAudioPlayer(data: data!, fileTypeHint: AVFileType.mp3.rawValue)
                
                self.audioPlayer?.delegate = self
                self.startAudioSession()
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func speak(string: String, language: String, engine: SpeechEngine = .auto, sessionID: String = "") {
        if engine == .voiceOver || engine == .auto {
            if speakVoiceOver(string: string, language: language, ignoreCheck: engine == .voiceOver, sessionID: sessionID) {
                return
            }
        }
        
        if engine == .googleTTS || engine == .auto {
            speakTTSService(string: string, language: language, sessionID: sessionID)
        }
    }
}
