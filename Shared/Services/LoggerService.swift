//
//  LoggerService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.01.22.
//

import Foundation
import os

class AppLogger: ObservableObject {
    static var shared = AppLogger()
    
    private var logger = Logger()
    @Published var history: [String] = []
    @Published var showAlert = false
    
    func log(level: OSLogType, message: String) {
        history.append(message)
        logger.log(level: level, "\(message)")
    }
    
    func debug(_ msg: String) {
        log(level: .debug, message: msg)
    }
    
    func info(_ msg: String) {
        log(level: .info, message: msg)
    }
    
    func error(_ msg: String) {
        log(level: .error, message: msg)
        showAlert = true
    }
    
    func fatal(_ msg: String) {
        log(level: .fault, message: msg)
        showAlert = true
    }
}
