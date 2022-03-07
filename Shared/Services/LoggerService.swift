//
//  LoggerService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.01.22.
//

import Foundation
import os

struct AppLoggerMessage {
    let level: OSLogType
    let message: String
}

extension OSLogType {
    var title: String {
        switch self {
        case .error:
            return "Error"
        case .debug:
            return "Debug"
            
        case .info:
            return "Information"
            
        case .fault:
            return "Fatal"
            
        default:
            return "Unknown"
        }
    }
}

class AppLogger: ObservableObject {
    static var shared = AppLogger()
    
    private var logger = Logger()
    @Published var history: [AppLoggerMessage] = []
    @Published var showAlert = false
    
    func log(level: OSLogType, message: String, show: Bool = false) {
        history.append(AppLoggerMessage(level: level, message: message))
        logger.log(level: level, "\(message)")
        
        if show {
            showAlert = true
        }
    }
    
    func debug(_ msg: String, show: Bool = false) {
        log(level: .debug, message: msg, show: show)
    }
    
    func info(_ msg: String, show: Bool = false) {
        log(level: .info, message: msg, show: show)
    }
    
    func error(_ msg: String, show: Bool = true) {
        log(level: .error, message: msg, show: show)
    }
    
    func fatal(_ msg: String, show: Bool = true) {
        log(level: .fault, message: msg, show: show)
    }
}
