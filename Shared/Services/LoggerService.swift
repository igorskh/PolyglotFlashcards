//
//  LoggerService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.01.22.
//

import Foundation
import os

class AppLogger {
    static var shared = AppLogger()
    
    private var logger = Logger()
    
    func debug(_ msg: String) {
        logger.debug("\(msg)")
    }
    
    func info(_ msg: String) {
        logger.info("\(msg)")
    }
    
    func warning(_ msg: String) {
        logger.warning("\(msg)")
    }
    
    func error(_ msg: String) {
        logger.error("\(msg)")
    }
    
    func fatal(_ msg: String) {
        logger.fault("\(msg)")
    }
    
}
